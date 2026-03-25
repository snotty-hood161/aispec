# rules/frontend/matrix/combination-overrides.md

## 文档目标
1. 本文件用于历史方案兼容，不是当前默认路径。
2. 当前默认路径为”按应用拆分 + 端侧结构独立文件 + 应用端锁栈 + 公共编码规范”。
3. 本文件记录每种”框架 × 应用端”组合下的额外约束、禁用/推荐清单与示例项目。

## 适用方式
1. 仅在确实需要”多端复用同一业务实现”时再启用本文件。
2. 正常项目可忽略本文件。
3. 组合约束优先级：组合约束 > 应用端规则 > 框架规则 > 通用规则。

## 条目模板
1. 组合 ID：如 `MATRIX-VUE-ADMIN-001`。
2. 背景：为什么在该组合下需要额外规则。
3. 规则内容：新增约束或冲突裁决。
4. 优先级：相对框架规则/应用端规则的覆盖关系。
5. 检查方式：CI、Lint、测试、人工评审。
6. 风险与回滚：落地失败时的降级方案。

---

## 一、Vue3 + 后台管理（admin-console）

### 组合约束

| ID | 级别 | 约束 | 背景 | 检查方式 | 阻断 |
|----|------|------|------|----------|------|
| MATRIX-VUE-ADMIN-001 | MUST | Element Plus 组件必须通过按需导入（`unplugin-vue-components`），禁止全量注册 | 后台管理页面多，全量注册导致首屏 chunk 过大 | 静态扫描：检查 main.ts 无 `app.use(ElementPlus)` | 是 |
| MATRIX-VUE-ADMIN-002 | MUST | Tailwind CSS 必须配置 `content` 扫描范围，排除 node_modules 中非 Element Plus 的路径 | 避免 Tailwind 与 Element Plus 样式冲突和产物膨胀 | 静态扫描：检查 tailwind.config | 是 |
| MATRIX-VUE-ADMIN-003 | MUST | Pinia Store 中的列表查询状态必须使用统一的 `ListQueryState<T>` 泛型接口 | 后台管理列表页多，查询参数模型不统一导致维护成本高 | 人工审查 | 是 |
| MATRIX-VUE-ADMIN-004 | MUST | 路由守卫中权限校验必须使用 `permission/` 下的统一函数，禁止在守卫中硬编码权限字符串 | 权限散落导致审计困难 | 模式匹配 | 是 |
| MATRIX-VUE-ADMIN-005 | MUST | ECharts 必须按需导入（`echarts/core` + 注册器），禁止 `import * as echarts` | 图表库体积大，全量导入严重影响 bundle | 模式匹配 | 是 |
| MATRIX-VUE-ADMIN-006 | MUST | 表格组件必须使用 ProTable Schema 驱动模式，禁止在页面中手写 `<el-table-column>` 超过 5 列 | 后台表格列多且重复，手写维护成本高 | 人工审查 | 是 |
| MATRIX-VUE-ADMIN-007 | MUST | 富文本编辑器统一使用 Tiptap 封装，禁止引入 wangEditor/CKEditor/Quill 等替代方案 | 避免多套富文本并存 | 模式匹配：package.json 依赖检查 | 是 |
| MATRIX-VUE-ADMIN-008 | SHOULD | 复杂表单（超过 10 个字段）的 Schema 定义应拆分到独立 `schemas/` 文件 | 避免页面文件过长 | 人工审查 | 否 |
| MATRIX-VUE-ADMIN-009 | SHOULD | 导出功能必须使用后端流式下载，前端禁止在内存中拼装大文件 | 大数据量导出导致浏览器 OOM | 人工审查 | 否 |
| MATRIX-VUE-ADMIN-010 | SHOULD | 菜单配置与路由配置保持单一来源，禁止菜单和路由各维护一份 | 菜单与路由不同步是后台管理高频 bug | 人工审查 | 否 |

### 禁用清单
| 库/工具 | 原因 |
|---------|------|
| `ant-design-vue` | 与 Element Plus 同类，禁止并存 |
| `vuex` | 已锁定 Pinia |
| `wangEditor` / `CKEditor` / `Quill` | 已锁定 Tiptap |
| `windicss` | 已锁定 Tailwind CSS |
| `less` / `sass`（作为主样式方案） | 已锁定 Tailwind CSS，仅允许用于 Element Plus 主题覆盖 |

### 推荐清单
| 库/工具 | 用途 |
|---------|------|
| `unplugin-vue-components` + `unplugin-auto-import` | Element Plus 按需导入 |
| `@vueuse/core` | 通用 Composable 工具集 |
| `dayjs` | 日期处理（Element Plus 默认依赖） |
| `xlsx` / `exceljs`（仅轻量导出场景） | 前端简单导出 |

### 示例项目
- 脚手架模板：待建立（使用 `$frontend-project-scaffold` Skill 生成）

---

## 二、Vue3 + 公众号 H5（wechat-h5）

### 组合约束

| ID | 级别 | 约束 | 背景 | 检查方式 | 阻断 |
|----|------|------|------|----------|------|
| MATRIX-VUE-H5-001 | MUST | uni-app 条件编译中 H5 专用代码必须使用 `#ifdef H5` 包裹 | 避免 H5 专用逻辑泄漏到小程序构建 | 模式匹配 | 是 |
| MATRIX-VUE-H5-002 | MUST | weixin-js-sdk 调用必须封装在 `platform/h5/wechat/` 适配层，页面禁止直接 import | 适配层统一处理签名、降级、错误 | 模式匹配 | 是 |
| MATRIX-VUE-H5-003 | MUST | 微信授权流程必须处理三种异常：用户拒绝、签名过期、网络超时 | 线上高频故障来源 | 人工审查 | 是 |
| MATRIX-VUE-H5-004 | MUST | UnoCSS 动态类名必须使用 safelist 或静态提取，禁止运行时拼接类名 | 动态类名在构建时被 tree-shake 导致样式丢失 | 模式匹配 | 是 |
| MATRIX-VUE-H5-005 | MUST | 活动页面放 `pages/scenes/`，活动结束后可独立归档下线 | 活动页生命周期短，混入常规页面导致代码膨胀 | 模式匹配：文件路径检查 | 是 |
| MATRIX-VUE-H5-006 | MUST | 首屏资源体积预算：HTML + CSS + JS ≤ 300KB (gzip) | 公众号 H5 用户网络环境差，首屏体积直接影响转化 | 静态扫描：构建产物分析 | 是 |
| MATRIX-VUE-H5-007 | MUST | 图片必须使用 CDN 地址 + WebP 格式（带 fallback），禁止本地大图 | 减少包体积，加速加载 | 模式匹配 | 是 |
| MATRIX-VUE-H5-008 | SHOULD | 分享配置（标题/描述/图片）统一在路由 meta 中声明，由全局 mixin 自动注入 | 避免每个页面重复写分享逻辑 | 人工审查 | 否 |
| MATRIX-VUE-H5-009 | SHOULD | 页面骨架屏使用 `uni-skeleton` 或自定义组件，关键路径必须有加载占位 | 避免白屏感知 | 人工审查 | 否 |
| MATRIX-VUE-H5-010 | SHOULD | 微信支付回调必须有超时兜底（≤ 10s），超时后引导用户手动查询 | 支付回调丢失是高频客诉 | 人工审查 | 否 |

### 禁用清单
| 库/工具 | 原因 |
|---------|------|
| `axios` | uni-app 端必须使用 uni.request 封装 |
| `@tarojs/*` | 已锁定 uni-app |
| `element-plus` | 非后台管理项目 |
| `tailwindcss`（直接使用） | uni-app 端使用 UnoCSS |
| `vant` / `nutui` | 已锁定 uview-plus |

### 推荐清单
| 库/工具 | 用途 |
|---------|------|
| `uview-plus` | UI 组件库 |
| `weixin-js-sdk` | 微信 JSSDK（仅 H5 端） |
| `@dcloudio/uni-app` | uni-app 核心 |
| `pinia` + `pinia-plugin-persistedstate` | 状态管理 |

### 示例项目
- 脚手架模板：待建立（使用 `$frontend-project-scaffold` Skill 生成）

---

## 三、Vue3 + 小程序（miniprogram）

### 组合约束

| ID | 级别 | 约束 | 背景 | 检查方式 | 阻断 |
|----|------|------|------|----------|------|
| MATRIX-VUE-MP-001 | MUST | uni-app 条件编译中小程序专用代码必须使用 `#ifdef MP-WEIXIN` 包裹 | 避免小程序专用逻辑泄漏到 H5 构建 | 模式匹配 | 是 |
| MATRIX-VUE-MP-002 | MUST | 小程序图标资源禁止 SVG，仅允许 png/jpg/jpeg | 微信小程序不支持 SVG 渲染 | 模式匹配：资源扩展名 | 是 |
| MATRIX-VUE-MP-003 | MUST | 主包体积 ≤ 2MB，超出必须执行分包拆分 | 微信平台硬限制 | 静态扫描：构建产物 | 是 |
| MATRIX-VUE-MP-004 | MUST | 分包页面禁止引用主包 components/ 下的业务组件，仅允许引用基础组件 | 分包引用主包业务组件导致主包体积失控 | 模式匹配 | 是 |
| MATRIX-VUE-MP-005 | MUST | UnoCSS 动态类名必须使用 safelist 或静态提取 | 同 H5 端，动态类名构建时丢失 | 模式匹配 | 是 |
| MATRIX-VUE-MP-006 | MUST | `setData` 粒度控制：禁止一次性传递超过 256KB 的数据 | 微信小程序 setData 性能瓶颈 | 人工审查 | 是 |
| MATRIX-VUE-MP-007 | MUST | 平台 API 统一封装在 `platform/mp-weixin/`，页面禁止直接调用 `wx.*` | 统一错误处理与降级 | 模式匹配 | 是 |
| MATRIX-VUE-MP-008 | SHOULD | 分包预下载配置（`preloadRule`）覆盖高频跳转路径 | 减少分包页面首次打开白屏时间 | 人工审查 | 否 |
| MATRIX-VUE-MP-009 | SHOULD | 长列表使用 `recycle-view` 或虚拟列表，禁止无边界 `v-for` | 小程序内存有限，长列表易 OOM | 人工审查 | 否 |
| MATRIX-VUE-MP-010 | SHOULD | 提审前执行 `miniprogram-review-checklist.md` 自查 | 减少审核驳回率 | 人工审查 | 否 |

### 禁用清单
| 库/工具 | 原因 |
|---------|------|
| `axios` | uni-app 端必须使用 uni.request 封装 |
| `@tarojs/*` | 已锁定 uni-app |
| `element-plus` | 非后台管理项目 |
| `echarts`（完整版） | 小程序端使用 uCharts |
| `vant-weapp` | 已锁定 uview-plus |

### 推荐清单
| 库/工具 | 用途 |
|---------|------|
| `uview-plus` | UI 组件库 |
| `uCharts` | 图表（小程序优化） |
| `@dcloudio/uni-app` | uni-app 核心 |
| `pinia` + `pinia-plugin-persistedstate` | 状态管理（适配 uni.setStorage） |

### 示例项目
- 脚手架模板：待建立（使用 `$frontend-project-scaffold` Skill 生成）

---

## 四、React + 后台管理（admin-console）

### 组合约束

| ID | 级别 | 约束 | 背景 | 检查方式 | 阻断 |
|----|------|------|------|----------|------|
| MATRIX-REACT-ADMIN-001 | MUST | UI 库锁定 Ant Design，禁止引入 Material UI / Chakra UI 等替代方案 | 同类库禁止并存 | 模式匹配：package.json | 是 |
| MATRIX-REACT-ADMIN-002 | MUST | 状态管理锁定 Zustand 或 Redux Toolkit（二选一），项目内禁止混用 | 避免状态管理方案碎片化 | 模式匹配：package.json | 是 |
| MATRIX-REACT-ADMIN-003 | MUST | 数据获取统一使用 `react-query`（TanStack Query），禁止页面内直接 fetch/axios | 统一缓存、重试、loading 态管理 | 模式匹配 | 是 |
| MATRIX-REACT-ADMIN-004 | MUST | 路由守卫中权限校验使用 `permission/` 下的统一函数 | 同 Vue3 版本 | 模式匹配 | 是 |
| MATRIX-REACT-ADMIN-005 | MUST | 表格组件使用 ProTable Schema 驱动或 TanStack Table，禁止手写超过 5 列的 `<table>` | 后台表格列多且重复 | 人工审查 | 是 |
| MATRIX-REACT-ADMIN-006 | MUST | 表单使用 `react-hook-form` + Schema 驱动，禁止手写超过 3 字段的表单 | 统一表单管理 | 人工审查 | 是 |
| MATRIX-REACT-ADMIN-007 | MUST | 页面级必须包裹 ErrorBoundary，提供重试入口 | 避免白屏 | 人工审查 | 是 |
| MATRIX-REACT-ADMIN-008 | SHOULD | 复杂表单 Schema 拆分到独立 `schemas/` 文件 | 避免页面文件过长 | 人工审查 | 否 |
| MATRIX-REACT-ADMIN-009 | SHOULD | 菜单配置与路由配置保持单一来源 | 同 Vue3 版本 | 人工审查 | 否 |
| MATRIX-REACT-ADMIN-010 | SHOULD | 导出功能使用后端流式下载 | 同 Vue3 版本 | 人工审查 | 否 |

### 禁用清单
| 库/工具 | 原因 |
|---------|------|
| `material-ui` / `@mui/*` | 已锁定 Ant Design |
| `mobx` | 已锁定 Zustand 或 Redux Toolkit |
| `swr`（与 react-query 并存时） | 数据获取方案禁止并存 |
| `formik` | 已锁定 react-hook-form |

### 推荐清单
| 库/工具 | 用途 |
|---------|------|
| `antd` | UI 组件库 |
| `@tanstack/react-query` | 数据获取与缓存 |
| `react-hook-form` | 表单管理 |
| `zustand` 或 `@reduxjs/toolkit` | 全局状态 |
| `dayjs` | 日期处理 |
| `recharts` 或 `@ant-design/charts` | 图表 |

### 示例项目
- 脚手架模板：待建立

---

## 五、React + 公众号 H5（wechat-h5）

> 说明：React + 公众号 H5 为非主推组合。当前团队主推 uni-app（Vue3）方案用于 H5 与小程序多端复用。仅在已有 React 技术栈且无多端需求时使用。

### 组合约束

| ID | 级别 | 约束 | 背景 | 检查方式 | 阻断 |
|----|------|------|------|----------|------|
| MATRIX-REACT-H5-001 | MUST | 微信 JSSDK 调用封装在 `platform/h5/wechat/` 适配层 | 统一签名、降级、错误处理 | 模式匹配 | 是 |
| MATRIX-REACT-H5-002 | MUST | 微信授权流程处理三种异常：用户拒绝、签名过期、网络超时 | 线上高频故障 | 人工审查 | 是 |
| MATRIX-REACT-H5-003 | MUST | 首屏资源体积预算：HTML + CSS + JS ≤ 300KB (gzip) | 公众号用户网络环境差 | 静态扫描 | 是 |
| MATRIX-REACT-H5-004 | MUST | CSS 方案锁定 Tailwind CSS 或 CSS Modules（二选一），禁止混用 | 样式方案统一 | 模式匹配 | 是 |
| MATRIX-REACT-H5-005 | MUST | 图片使用 CDN + WebP（带 fallback） | 减少包体积 | 模式匹配 | 是 |
| MATRIX-REACT-H5-006 | MUST | 活动页面放 `pages/scenes/`，可独立归档 | 活动页生命周期短 | 模式匹配 | 是 |
| MATRIX-REACT-H5-007 | MUST | 页面级包裹 ErrorBoundary | 避免白屏 | 人工审查 | 是 |
| MATRIX-REACT-H5-008 | SHOULD | 分享配置统一在路由 meta 中声明 | 避免重复分享逻辑 | 人工审查 | 否 |
| MATRIX-REACT-H5-009 | SHOULD | 关键路径有骨架屏或加载占位 | 避免白屏感知 | 人工审查 | 否 |
| MATRIX-REACT-H5-010 | SHOULD | 微信支付回调超时兜底（≤ 10s） | 支付回调丢失是高频客诉 | 人工审查 | 否 |

### 禁用清单
| 库/工具 | 原因 |
|---------|------|
| `uni-app` 相关依赖 | React 项目不使用 uni-app |
| `antd`（完整版） | H5 端应使用移动端 UI 库 |
| `element-plus` | Vue 生态库 |

### 推荐清单
| 库/工具 | 用途 |
|---------|------|
| `antd-mobile` 或 `react-vant` | 移动端 UI |
| `weixin-js-sdk` | 微信 JSSDK |
| `@tanstack/react-query` | 数据获取 |
| `react-router-dom` | 路由 |

### 示例项目
- 脚手架模板：待建立

---

## 六、React + 小程序（miniprogram）

> 说明：React + 小程序基于 Taro 框架。当前团队主推 uni-app（Vue3）方案。仅在已有 React 技术栈且团队 React 经验远强于 Vue 时使用。

### 组合约束

| ID | 级别 | 约束 | 背景 | 检查方式 | 阻断 |
|----|------|------|------|----------|------|
| MATRIX-REACT-MP-001 | MUST | 框架锁定 Taro（React 模式），禁止混用 uni-app | 跨端框架禁止并存 | 模式匹配：package.json | 是 |
| MATRIX-REACT-MP-002 | MUST | 小程序图标资源禁止 SVG | 微信平台限制 | 模式匹配 | 是 |
| MATRIX-REACT-MP-003 | MUST | 主包体积 ≤ 2MB | 微信平台硬限制 | 静态扫描 | 是 |
| MATRIX-REACT-MP-004 | MUST | 平台 API 封装在 `platform/mp-weixin/`，禁止直接调用 `Taro.*` 平台方法 | 统一错误处理与降级 | 模式匹配 | 是 |
| MATRIX-REACT-MP-005 | MUST | CSS 方案使用 Taro 内置 CSS Modules 或配置 UnoCSS | 样式方案统一 | 模式匹配 | 是 |
| MATRIX-REACT-MP-006 | MUST | 分包页面禁止引用主包业务组件 | 控制主包体积 | 模式匹配 | 是 |
| MATRIX-REACT-MP-007 | MUST | `setData` 粒度控制：单次数据传输 ≤ 256KB | 小程序性能瓶颈 | 人工审查 | 是 |
| MATRIX-REACT-MP-008 | SHOULD | 分包预下载覆盖高频跳转路径 | 减少白屏时间 | 人工审查 | 否 |
| MATRIX-REACT-MP-009 | SHOULD | 长列表使用虚拟列表 | 小程序内存有限 | 人工审查 | 否 |
| MATRIX-REACT-MP-010 | SHOULD | 提审前执行审核自查清单 | 减少驳回率 | 人工审查 | 否 |

### 禁用清单
| 库/工具 | 原因 |
|---------|------|
| `@dcloudio/uni-app` | 已锁定 Taro |
| `echarts`（完整版） | 使用 `@antv/f2` 或 Taro 兼容图表方案 |
| `antd` | 非移动端 UI |
| `axios` | Taro 端使用 Taro.request 封装 |

### 推荐清单
| 库/工具 | 用途 |
|---------|------|
| `@tarojs/taro` | Taro 核心 |
| `@tarojs/components` | Taro 组件 |
| `nutui-react-taro` | 移动端 UI（京东出品，Taro 适配好） |
| `zustand` | 状态管理（轻量） |
| `@antv/f2` | 移动端图表 |

### 示例项目
- 脚手架模板：待建立

---

## 冲突裁决原则
1. 组合约束优先于单独的应用端规则或框架规则。
2. 同一组合内 MUST 约束之间冲突时，取更严格且可验证的条款。
3. 跨组合冲突（如同一 uni-app 项目同时编译 H5 和小程序）时，取两端约束的并集（更严格）。
4. 组合约束与 `common/*.md` 通用规则冲突时，组合约束优先，但必须在本文件中注明覆盖理由。
