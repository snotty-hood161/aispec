# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（ESLint/TypeScript）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、编码基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | TypeScript `strict` 模式开启 | 静态扫描：检查 tsconfig.json |
| BL-02 | P0 | 无无边界 `any`（确需使用有注释） | 静态扫描：`@typescript-eslint/no-explicit-any` |
| BL-03 | P0 | 导出函数/类/Hook 有显式类型声明 | 静态扫描：`@typescript-eslint/explicit-module-boundary-types` |
| BL-04 | P0 | 接口调用通过 services 层 | 模式匹配：组件文件中无 axios/fetch/uni.request 直接调用 |
| BL-05 | P0 | 全局状态仅跨页面共享数据 | 人工审查 |
| BL-06 | P0 | 副作用可清理 | 人工审查：检查 onUnmounted/cleanup |
| BL-07 | P0 | 函数/组件/Hook 有中文注释 | 模式匹配：导出声明前有中文注释 |
| BL-08 | P0 | 文件头部有模块用途说明 | 模式匹配：文件前 5 行含注释 |

## 二、命名规范（common/naming.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| NM-01 | P0 | 变量/函数 camelCase | 静态扫描：ESLint naming-convention |
| NM-02 | P0 | 类型/组件 PascalCase | 静态扫描 |
| NM-03 | P0 | 常量 UPPER_SNAKE_CASE | 静态扫描 |
| NM-04 | P0 | 目录与普通文件 kebab-case | 模式匹配：文件路径检查 |
| NM-05 | P0 | 禁止弱语义命名（temp/data2/newList） | 模式匹配：关键词黑名单 |
| NM-06 | P0 | 组合函数 useXxx / 事件处理 onXxx | 模式匹配 |

## 三、Git 工作流（common/git-workflow.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| GW-01 | P0 | 分支名符合 feature/fix/release/hotfix + kebab-case | 模式匹配：分支名正则 |
| GW-02 | P0 | 提交消息 Conventional Commits | 静态扫描：commitlint |
| GW-03 | P0 | main 分支保护开启 | 人工审查 |

## 四、工具链与 CI（common/tooling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TL-01 | P0 | 提供 lint/typecheck/test/build 四脚本 | 模式匹配：检查 package.json scripts |
| TL-02 | P0 | lint/typecheck/test 失败阻断合并 | 人工审查：检查 CI 配置 |
| TL-03 | P0 | 构建产物移除 console/debugger/注释 | 模式匹配：检查构建配置 |
| TL-04 | P0 | 核心依赖符合 stack-baseline | 模式匹配：检查 package.json dependencies |

## 五、测试（common/testing.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TS-01 | P0 | 工具函数/composable/service 有单元测试 | 模式匹配：对应 .test/.spec 文件存在 |
| TS-02 | P0 | 核心覆盖率 ≥ 80%，整体 ≥ 60%，增量 ≥ 80% | 静态扫描：覆盖率报告 |
| TS-03 | P0 | 公共组件有 testing-library 测试 | 模式匹配 |
| TS-04 | P0 | 测试确定性，无外部依赖 | 人工审查 |
| TS-05 | P0 | 外部 API Mock，被测模块不 Mock | 人工审查 |

## 六、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 禁止 v-html 直接渲染用户输入 | 模式匹配：v-html/dangerouslySetInnerHTML 使用检查 |
| SC-02 | P0 | 禁止 eval/new Function/document.write | 静态扫描：ESLint no-eval |
| SC-03 | P0 | Token 不存 localStorage | 模式匹配：localStorage.setItem + token 关键词 |
| SC-04 | P0 | 敏感信息脱敏显示 | 人工审查 |
| SC-05 | P0 | 禁止硬编码密钥 | 模式匹配：密钥/密码/secret 关键词扫描 |
| SC-06 | P0 | 依赖漏洞扫描 Critical/High 阻断 | 静态扫描：npm audit / snyk |

## 七、环境配置（common/env-config.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EC-01 | P0 | .env.local 在 .gitignore 中 | 模式匹配：检查 .gitignore |
| EC-02 | P0 | 客户端变量使用正确前缀 | 模式匹配：VITE_ / VUE_APP_ |
| EC-03 | P0 | 生产密钥不在 .env 中 | 模式匹配 |
| EC-04 | P0 | 禁止硬编码 API 地址 | 模式匹配：http(s):// 硬编码检查 |
| EC-05 | P0 | 新增变量同步 env.d.ts 和 .env.example | 人工审查 |

## 八、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | 单路由 chunk ≤ 200KB (gzip) | 静态扫描：构建产物分析 |
| PF-02 | P0 | 路由级组件懒加载 | 模式匹配：路由配置中 import() |
| PF-03 | P0 | 大列表虚拟滚动或分页 | 人工审查 |
| PF-04 | P0 | 高频事件防抖/节流 | 人工审查 |
| PF-05 | P0 | 组件卸载清理副作用 | 人工审查 |
| PF-06 | P0 | 请求超时 + 页面切换取消请求 | 人工审查 |

## 九、组件化（common/componentization-and-adaptation.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CP-01 | P0 | 基础组件无业务请求 | 人工审查 |
| CP-02 | P0 | 组件 props 输入 / 事件输出 | 人工审查 |
| CP-03 | P0 | 公共组件覆盖空态/加载态/异常态 | 人工审查 |
| CP-04 | P0 | 端特有能力通过适配层封装 | 模式匹配：平台 API 直调检查 |

## 十、错误监控（common/error-monitoring.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EM-01 | P0 | 全局错误捕获已注册 | 模式匹配：errorHandler/ErrorBoundary/onerror |
| EM-02 | P0 | 接入统一错误监控平台 | 人工审查 |
| EM-03 | P0 | Source Map 不部署到生产 CDN | 人工审查：检查构建配置 |
| EM-04 | P0 | 错误上报限流 + 聚合 | 人工审查 |

## 十一、交付流程（common/workflow.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| WF-01 | P1 | .vue 文件不超过 300 行 | 静态扫描：文件行数统计 |
| WF-02 | P0 | 删除/不可逆操作前有确认 | 人工审查 |
| WF-03 | P0 | PR 包含变更说明/影响范围/回滚方案 | 模式匹配：PR 模板字段检查 |

---

## 十二、应用端专项检查

### admin-console 追加项

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AC-01 | P0 | 权限点在 permission/ 统一定义 | 模式匹配 |
| AC-02 | P0 | 列表查询参数统一模型 | 人工审查 |
| AC-03 | P0 | 高风险操作二次确认 | 人工审查 |
| AC-04 | P0 | 使用 Tailwind CSS（非内联样式） | 模式匹配 |

### wechat-h5 追加项

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| H5-01 | P0 | 微信能力封装在 platform/h5/wechat | 模式匹配 |
| H5-02 | P0 | 分享/支付有失败回退 | 人工审查 |
| H5-03 | P0 | 处理授权拒绝/签名过期/弱网超时 | 人工审查 |
| H5-04 | P0 | UnoCSS 原子类纳入构建检查 | 人工审查 |

### miniprogram 追加项

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MP-01 | P0 | 主包体积 ≤ 2MB | 静态扫描：构建产物检查 |
| MP-02 | P0 | 平台 API 封装在 platform/mp-weixin | 模式匹配 |
| MP-03 | P0 | 小程序图标禁止 SVG | 模式匹配：资源文件扩展名 |
| MP-04 | P0 | 分包策略与业务路径对齐 | 人工审查 |
| MP-05 | P0 | UnoCSS 原子类纳入构建检查 | 人工审查 |

---

## 十三、框架专项检查

### Vue3 追加项（frameworks/vue3-typescript.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| V3-01 | P0 | 使用 `<script setup lang="ts">` | 静态扫描：vue/block-order |
| V3-02 | P0 | defineProps/defineEmits 纯类型声明 | 静态扫描 |
| V3-03 | P0 | Composable 副作用可清理 | 人工审查 |
| V3-04 | P0 | 禁止 reactive 整体赋值 | 人工审查 |
| V3-05 | P0 | 超 3 字段表单 Schema 驱动 | 人工审查 |
| V3-06 | P0 | v-for 使用稳定唯一 key | 静态扫描：vue/require-v-for-key |
| V3-07 | P0 | Pinia Setup Store 语法 | 人工审查 |

### React 追加项（frameworks/react-typescript.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RC-01 | P0 | 函数组件，禁止 Class 组件 | 静态扫描 |
| RC-02 | P0 | Props 显式 interface 定义 | 静态扫描 |
| RC-03 | P0 | useEffect 依赖数组完整 | 静态扫描：react-hooks/exhaustive-deps |
| RC-04 | P0 | useEffect cleanup 释放副作用 | 人工审查 |
| RC-05 | P0 | 超 3 字段表单 Schema 驱动 | 人工审查 |
| RC-06 | P0 | ErrorBoundary 包裹页面级 | 人工审查 |
| RC-07 | P0 | 列表 key 使用业务标识 | 静态扫描：react/no-array-index-key |

## 六、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 禁止 v-html 直接渲染用户输入 | 模式匹配：v-html/dangerouslySetInnerHTML 使用检查 |
| SC-02 | P0 | 禁止 eval/new Function/document.write | 静态扫描：ESLint no-eval |
| SC-03 | P0 | Token 不存 localStorage | 模式匹配：localStorage.setItem + token 关键词 |
| SC-04 | P0 | 敏感信息脱敏 | 人工审查 |
| SC-05 | P0 | 无硬编码密钥 | 模式匹配：密钥/密码/secret 关键词扫描 |
| SC-06 | P0 | 依赖漏洞扫描通过 | 静态扫描：npm audit / CI 报告 |

## 七、环境配置（common/env-config.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EC-01 | P0 | .env.local 在 .gitignore 中 | 模式匹配：检查 .gitignore |
| EC-02 | P0 | 客户端变量使用正确前缀 | 模式匹配：VITE_ / VUE_APP_ |
| EC-03 | P0 | 生产密钥不在 .env 中 | 模式匹配 |
| EC-04 | P0 | 无硬编码 API 地址 | 模式匹配：http(s):// 硬编码检查 |
| EC-05 | P0 | 新增变量同步 env.d.ts 和 .env.example | 人工审查 |

## 八、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | 单路由 chunk ≤ 200KB (gzip) | 静态扫描：构建产物分析 |
| PF-02 | P0 | 路由级组件懒加载 | 模式匹配：路由配置中 import() |
| PF-03 | P0 | 大列表虚拟滚动或分页 | 人工审查 |
| PF-04 | P0 | 高频事件防抖/节流 | 人工审查 |
| PF-05 | P0 | 组件卸载清理副作用 | 人工审查 |
| PF-06 | P0 | 请求超时 + 页面切换取消 | 人工审查 |

## 九、组件化（common/componentization-and-adaptation.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CP-01 | P0 | 基础组件无业务请求 | 人工审查 |
| CP-02 | P0 | 组件 props 输入 / 事件输出 | 人工审查 |
| CP-03 | P0 | 公共组件覆盖空态/加载态/异常态 | 人工审查 |
| CP-04 | P0 | 端特有能力通过适配层封装 | 模式匹配：平台 API 直调检查 |

## 十、错误监控（common/error-monitoring.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EM-01 | P0 | 全局错误捕获已注册 | 模式匹配：errorHandler/ErrorBoundary/onerror |
| EM-02 | P0 | 接入统一错误监控平台 | 人工审查 |
| EM-03 | P0 | Source Map 不部署到生产 CDN | 人工审查：检查构建配置 |
| EM-04 | P0 | 错误上报限流 + 聚合 | 人工审查 |

## 十一、交付流程（common/workflow.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| WF-01 | P1 | .vue 文件不超过 300 行 | 静态扫描：文件行数统计 |
| WF-02 | P0 | 不可逆操作前有确认 | 人工审查 |
| WF-03 | P0 | PR 包含变更说明/影响范围/回滚方案 | 人工审查：PR 模板检查 |

---

## 十二、应用端专项检查

### admin-console 追加项

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AC-01 | P0 | 权限点在 permission/ 统一定义 | 模式匹配 |
| AC-02 | P0 | 列表查询参数统一模型 | 人工审查 |
| AC-03 | P0 | 高风险操作二次确认 | 人工审查 |
| AC-04 | P0 | 表单 Schema 驱动（>3 字段） | 人工审查 |

### wechat-h5 追加项

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| H5-01 | P0 | 微信能力封装在适配层 | 模式匹配：页面文件中无 JSSDK 直调 |
| H5-02 | P0 | 分享/支付有失败回退 | 人工审查 |
| H5-03 | P0 | 处理授权拒绝/签名过期/弱网 | 人工审查 |
| H5-04 | P0 | UnoCSS 原子类纳入构建检查 | 人工审查 |

### miniprogram 追加项

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MP-01 | P0 | 主包体积 ≤ 2MB | 静态扫描：构建产物检查 |
| MP-02 | P0 | 平台 API 封装在 platform/mp-weixin | 模式匹配 |
| MP-03 | P0 | 小程序无 SVG 资源 | 模式匹配：资源文件扫描 |
| MP-04 | P0 | 分包策略与业务路径对齐 | 人工审查 |
| MP-05 | P0 | UnoCSS 原子类纳入构建检查 | 人工审查 |

---

## 十三、框架专项检查

### Vue3 追加项（frameworks/vue3-typescript.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| V3-01 | P0 | 使用 `<script setup lang="ts">` | 静态扫描：vue/block-order |
| V3-02 | P0 | defineProps/defineEmits 纯类型声明 | 静态扫描 |
| V3-03 | P0 | Composable 副作用可清理 | 人工审查 |
| V3-04 | P0 | v-for 使用稳定唯一 key | 静态扫描：vue/require-v-for-key |
| V3-05 | P0 | Pinia Store 按领域划分 | 人工审查 |
| V3-06 | P0 | KeepAlive 有 include/max 限制 | 人工审查 |

### React 追加项（frameworks/react-typescript.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RC-01 | P0 | 函数组件，禁止 Class 组件 | 静态扫描 |
| RC-02 | P0 | Props 显式 interface 定义 | 静态扫描 |
| RC-03 | P0 | useEffect 依赖数组完整 | 静态扫描：react-hooks/exhaustive-deps |
| RC-04 | P0 | useEffect cleanup 释放副作用 | 人工审查 |
| RC-05 | P0 | ErrorBoundary 包裹页面级 | 人工审查 |
| RC-06 | P0 | 网络请求支持 AbortController | 人工审查 |
