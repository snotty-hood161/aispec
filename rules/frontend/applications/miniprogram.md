# rules/frontend/applications/miniprogram.md

## 文档目标
1. 定义微信小程序目标端规则（基于 `uni-app`）与平台能力约束。
2. 本文件描述的是“目标端规则”，可用于独立应用，也可用于同一应用的小程序构建目标。

## 技术栈锁定（MUST，V1）
1. 框架：`uni-app + Vue3 + TypeScript`
2. UI 方案：`uview-plus`
3. 原子化样式：`UnoCSS`（使用 Tailwind 风格语法）
4. 状态管理：`Pinia`
5. 状态持久化：`pinia-plugin-persistedstate`（存储适配到 `uni.setStorage`）
6. 请求层：统一封装 `uni.request`（禁止在 uni-app 端直接使用 Axios）
7. 富文本：`editor`（编辑）+ `rich-text`（展示）
8. 图表：`uCharts`
9. `MUST`：同类库禁止并存，避免包体和心智负担失控。
10. `MUST`：禁止引入 `Taro` 相关依赖（如 `@tarojs/*`）。

## 项目结构引用（MUST）
1. 小程序结构规则以 `rules/frontend/project-structure/miniprogram.md` 为准。
2. 通用结构边界仍需遵守 `rules/frontend/common/project-structure.md`。

## 应用边界规则
1. `MUST`：同一应用如果还需要 H5 目标，可继续使用同一 `uni-app` 项目多端编译。
2. `MUST`：不同应用（如员工端与 C 端）必须拆分成不同项目，不得混在同一业务代码中。
3. `SHOULD`：多 Tab 同页场景优先采用 `tab-host` 宿主页模式，减少页面栈抖动。

## 平台规则
1. `MUST`：主包与分包目录明确，新增页面必须声明归属。
2. `MUST`：平台 API 统一在 `platform/mp-weixin` 封装，页面禁止直接写平台分支。
3. `MUST`：高频更新场景控制数据更新粒度，避免无边界刷新。
4. `MUST`：分包策略必须与业务路径对齐，禁止将低频页面放入主包。
5. `MUST`：小程序图标资源禁止使用 `SVG`，仅允许使用 `png/jpg/jpeg` 等位图格式。
6. `SHOULD`：主题色、间距、字号优先使用 token，不新增页面级硬编码样式值。
7. `SHOULD`：分享、支付、订阅消息等能力统一封装并有失败回退。

## 发布与审核
1. `MUST`：发版前执行包体积检查和敏感内容检查。
2. `MUST`：小程序主包体积不得大于 `2MB`；超过 `2MB` 时必须执行分包拆分后再发版。
3. `MUST`：提供灰度发布与紧急回滚策略。
4. `MUST`：`UnoCSS` 原子类必须纳入构建产物检查，防止动态类名丢失样式。
5. `SHOULD`：审核常见驳回项形成检查清单并纳入提测流程。

## 配套模板
1. 小程序审核清单 → `rules/templates/frontend/miniprogram-review-checklist.md`
2. uni.request 标准封装 → `rules/templates/frontend/uni-request-wrapper.md`
3. 主包体积校验 + 资源格式检查脚本 → `rules/templates/frontend/miniprogram-ci-checks.md`
4. 平台 API 适配层接口定义 → `rules/templates/frontend/component-patterns.md`（第二章）
