# rules/frontend/common/componentization-and-adaptation.md

## 文档目标
1. 定义三端共用的组件化规范与适配规范。
2. 降低组件重复开发与端侧适配失控问题。

## 组件分层模型
1. `MUST`：基础组件（Base UI）只负责样式与基础交互，不含业务请求。
2. `MUST`：业务组件（Business Component）负责业务展示与业务交互，可依赖 `services`。
3. `MUST`：页面组件（Page Container）负责路由参数、页面编排、数据装配。
4. `MUST`：禁止页面组件被其他页面直接复用。

## 组件设计约束
1. `MUST`：组件输入通过 `props`/参数，输出通过事件/回调，禁止隐式依赖全局变量。
2. `MUST`：每个公共组件必须有明确的“空态/加载态/异常态”。
3. `MUST`：组件对外 API 稳定后必须做向后兼容，破坏性变更需要版本说明。
4. `MUST`：组件默认样式必须可映射到 token，不允许主题值硬编码。
5. `SHOULD`：组件提供最小可用 API，避免“万能组件”。

## 适配策略（跨端共性）
1. `MUST`：先定义目标端基线再开发，不允许“写完再补适配”。
2. `MUST`：适配分三类处理：布局适配、交互适配、能力适配。
3. `MUST`：端特有能力必须经适配层封装，页面不得直接调用平台 API。
4. `MUST`：uni-app 项目中，端差异能力必须落在 `src/platform/h5` 或 `src/platform/mp-weixin`。
5. `SHOULD`：同一业务在不同端允许 UI 不一致，但交互语义必须一致。

## 响应式与尺寸基线
1. `MUST`：后台管理默认桌面优先（建议最小宽度 1280）。
2. `MUST`：后台管理样式体系使用 `Tailwind CSS`。
3. `MUST`：uni-app 目标端（H5/小程序）样式体系使用 `UnoCSS`。
4. `MUST`：uni-app 小程序端按平台单位体系实现（如 `rpx`），禁止直接复用 H5 的 px 规则。
5. `SHOULD`：统一设计 token（字号、间距、圆角、色板）驱动三端样式。

## 可复用组件准入标准
1. `MUST`：进入公共组件库前，至少在两个页面或两个模块复用。
2. `MUST`：提供最少一个使用示例和参数说明。
3. `MUST`：提供回归测试用例（单测或快照）。
4. `SHOULD`：高频组件补性能基准（渲染耗时、重渲染次数）。

## 配套模板
1. 三端组件示例 + 适配层接口 + 文档生成 → `rules/templates/frontend/component-patterns.md`
