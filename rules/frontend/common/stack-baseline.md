# rules/frontend/common/stack-baseline.md

## 文档目标
1. 固化当前前端项目的技术栈与依赖基线，避免选型漂移。
2. 为评审、开发与 CI 提供统一检查依据。

## 适用范围
1. 适用于 `rules/frontend/` 覆盖的全部前端项目。
2. 本文档优先于应用文档中的“示例型”描述。

## V1 总体约束（MUST）
1. 后台管理采用 `Vue3 + TypeScript + Vite` 技术路线。
2. 移动端应用采用 `uni-app + Vue3 + TypeScript` 技术路线。
3. 当前基线不引入 `Taro` 生态依赖。
4. 同一应用如需 H5 与小程序，使用一个 `uni-app` 项目多端编译。
5. 不同应用（如员工端/C 端）必须拆分项目。

## 后台管理依赖基线（MUST）
1. UI：`Element Plus`
2. CSS：`Tailwind CSS`
3. 状态管理：`Pinia`
4. 状态持久化：`pinia-plugin-persistedstate`
5. 路由：`Vue Router`
6. 请求层：`Axios`
7. 富文本：`Tiptap`
8. 图表：`ECharts`

## uni-app 应用依赖基线（MUST）
1. UI：`uview-plus`
2. 原子化样式：`UnoCSS`（Tailwind 风格语法）
3. 状态管理：`Pinia`
4. 状态持久化：`pinia-plugin-persistedstate`（适配 `uni.setStorage`）
5. 请求层：统一封装 `uni.request`
6. H5 微信能力：`weixin-js-sdk`（仅 H5 目标端启用）
7. 小程序富文本：`editor`（编辑）+ `rich-text`（展示）
8. 小程序图表：`uCharts`

## 禁止项（MUST）
1. 禁止在 `uni-app` 项目中直接使用 `Axios` 作为页面请求入口。
2. 禁止在当前仓库新增 `Taro` 依赖（如 `@tarojs/*`）。
3. 禁止在同一项目并存两套同类核心库（双 UI 库、双状态管理库、双请求入口）。

## 合并前检查项（MUST）
1. 依赖检查：`package.json` 不出现禁止依赖，核心依赖满足本基线。
2. 架构检查：请求入口、状态管理、样式体系与应用规则一致。
3. 质量检查：通过 `lint + typecheck + test`。
4. 例外检查：如需偏离基线，必须附例外说明与回收计划。

## 检查方式与阻断
1. 检查方式：静态扫描 + CI 阻断 + 人工审查。
2. 阻断级别：本文件全部 `MUST` 条款默认为阻断合并。

## 配套模板
1. 规范例外申请模板 → `rules/templates/exception-request-template.md`
2. 依赖检查脚本 + 脚手架依赖清单 → `rules/templates/frontend/dependency-management.md`
