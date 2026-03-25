# rules/frontend/common/performance.md

## 文档目标
1. 定义三端共用的前端性能约束，不绑定具体框架。
2. 框架层性能约束（如 Vue 虚拟 DOM 优化、React memo 策略）参见 `frameworks/*.md`。
3. 应用端专项性能约束（如小程序主包 2MB、分包策略）参见 `applications/*.md`。

---

## 性能指标基线（MUST）

### Web 端（后台管理 / H5）
| 指标 | 目标值 | 说明 |
|------|--------|------|
| LCP（Largest Contentful Paint） | ≤ 2.5s | 主内容可见时间 |
| FID（First Input Delay） | ≤ 100ms | 首次交互响应延迟 |
| CLS（Cumulative Layout Shift） | ≤ 0.1 | 累计布局偏移 |
| TTI（Time to Interactive） | ≤ 3.5s | 页面可交互时间 |

1. 核心页面（首页、列表页、详情页）必须满足上述指标（Good 档位）。
2. 新页面上线前必须通过 Lighthouse 或等效工具跑分验证。
3. 后台管理允许 LCP 放宽至 ≤ 4s（数据密集型页面），但须在 PR 中说明原因。

### 小程序端
| 指标 | 目标值 | 说明 |
|------|--------|------|
| 首屏渲染 | ≤ 2s | 从 onLoad 到首屏内容可见 |
| 主包体积 | ≤ 2MB | 超出必须分包 |
| 单分包体积 | ≤ 2MB | 平台硬限制 |
| setData 单次数据量 | ≤ 256KB | 避免通信阻塞 |

检查方式：Lighthouse / 微信开发者工具性能面板 + 人工审查
阻断级别：阻断合并（MUST 指标）/ 告警记录（SHOULD 指标）

---

## Bundle 体积管控（MUST）

1. 项目必须配置构建产物分析工具（Vite 使用 `rollup-plugin-visualizer`；Webpack 使用 `webpack-bundle-analyzer`）。
2. 单个路由 chunk 不得超过 200KB（gzip 后），超出必须拆分或懒加载。
3. 第三方库引入必须评估体积影响；单个依赖 gzip 后超过 50KB 需在 PR 中说明必要性。
4. 禁止全量导入工具库（如 `import lodash`），必须按需导入（如 `import debounce from 'lodash/debounce'`）。
5. 图片资源必须压缩：PNG/JPEG 使用构建插件自动压缩；图标优先使用 Icon Font 或 SVG Sprite（小程序端除外，小程序禁止 SVG）。

### SHOULD
1. 设置 Bundle 体积预算，CI 中检测产物体积超预算时告警。
2. 定期（每月）审查依赖树，移除未使用的依赖。

检查方式：Bundle 分析工具 + CI 体积检测
阻断级别：阻断合并

---

## 资源加载策略（MUST）

1. 路由级组件必须使用懒加载（Vue: `() => import()`；React: `React.lazy`）。
2. 首屏不可见的重型组件（图表、富文本编辑器、地图）必须异步加载。
3. 图片必须使用懒加载（`loading="lazy"` 或 Intersection Observer）；首屏可视区域内的图片除外。
4. 字体文件必须使用 `font-display: swap`，避免 FOIT（Flash of Invisible Text）。
5. 静态资源必须配置强缓存（文件名含 hash） + CDN 分发。

### SHOULD
1. 关键资源使用 `<link rel="preload">`；非关键第三方脚本使用 `defer` 或 `async`。
2. 接口请求在路由切换时预取（prefetch），减少页面白屏时间。

检查方式：Lighthouse + 人工审查
阻断级别：阻断合并

---

## 渲染性能（MUST）

1. 大列表（100+ 项）必须使用虚拟滚动或分页，禁止全量 DOM 渲染。
2. 高频事件（`scroll`、`resize`、`input`、`mousemove`）必须做防抖或节流。
3. 动画优先使用 CSS `transform` / `opacity`（GPU 合成层），避免触发 Layout/Paint 的属性（`width`、`top`、`margin` 等）。
4. 禁止在滚动、动画回调中执行同步的重计算或 DOM 强制回流（如读取 `offsetHeight` 后立即写 `style`）。
5. 列表项中禁止嵌套滚动容器（滚动容器嵌套不超过 2 层）。

### SHOULD
1. 长任务（> 50ms）使用 `requestIdleCallback` 或分帧处理（`requestAnimationFrame` + 时间切片），避免阻塞主线程。
2. 复杂计算考虑 Web Worker 卸载（后台管理端适用）。

检查方式：Chrome DevTools Performance 面板 + 人工审查
阻断级别：阻断合并

---

## 网络性能（MUST）

1. 接口请求必须设置超时时间（建议默认 10s，可按接口调整）。
2. 页面切换时必须取消未完成的请求（AbortController / 框架内置取消机制）。
3. 同一页面并发请求数应控制合理（建议不超过 6 个同域并发），过多时做请求合并或排队。
4. 重复请求必须做防抖处理（如按钮连续点击、搜索框连续输入）。
5. 分页列表禁止首次加载全量数据，必须按页请求。

### SHOULD
1. 接口响应数据结构稳定的场景，考虑客户端缓存（内存缓存 / `stale-while-revalidate` 策略）。
2. 关键接口增加失败重试（限制重试次数，如最多 2 次）。

检查方式：Chrome DevTools Network 面板 + 人工审查
阻断级别：阻断合并

---

## 内存管理（MUST）

1. 组件卸载时必须清理所有副作用：事件监听、定时器（`setInterval` / `setTimeout`）、订阅、WebSocket 连接。
2. 禁止在全局作用域（`window`、模块顶层）无限累积数据（如不断 push 的数组、不清理的 Map）。
3. 大文件操作（上传/下载/预览）完成后必须释放 `URL.createObjectURL` 创建的 Blob URL。
4. 路由切换后不再使用的大对象（图表实例、编辑器实例）必须调用 `destroy/dispose` 销毁。

### SHOULD
1. 定期使用 Chrome DevTools Memory 面板做内存快照，排查潜在泄漏。
2. 长时间运行的页面（如后台管理仪表盘）设置内存告警阈值。

检查方式：Chrome DevTools Memory 面板 + 人工审查
阻断级别：阻断合并

---

## 性能评审与监控（SHOULD）

1. 核心页面变更必须包含性能评审：Lighthouse 跑分截图或关键指标对比。
2. 线上接入性能监控（如 Web Vitals 上报），持续跟踪 LCP、FID、CLS。
3. 性能劣化超过阈值（如 LCP 恶化 > 500ms）触发告警并限时修复。
4. 每季度做一次全站性能巡检，输出优化报告。

检查方式：性能监控平台 + 人工审查
阻断级别：告警记录
