# rules/frontend/common/project-structure.md

## 文档目标
1. 定义前端项目结构的通用边界与跨项目约束。
2. 将端侧目录细节拆分到独立文件，支持按需加载，不再通读三套结构。

## 结构模型
1. `MUST`：项目边界按“应用”划分，不按“端类型”硬拆。
2. `MUST`：同一应用若同时需要 H5 与小程序，使用一个 `uni-app` 项目多端编译。
3. `MUST`：不同应用（例如员工端与 C 端）即使都用 `uni-app`，也必须拆分为不同项目。
4. `MUST`：按目标端读取对应结构文件：
5. 后台管理：`rules/frontend/project-structure/admin-console.md`
6. 公众号 H5：`rules/frontend/project-structure/wechat-h5.md`
7. 小程序：`rules/frontend/project-structure/miniprogram.md`
8. `MUST`：每个项目的业务代码只允许在本项目 `src/` 内。
9. `MUST`：跨项目不得直接引用对方业务代码，只允许复用通用 npm 包或工具包。
10. `SHOULD`：每个项目独立 CI 流水线、独立发布版本、独立回滚。

## 单项目根目录模板（MUST）
```text
<project-root>/
|-- src/
|-- tests/
|-- public/                (小程序可无此目录)
|-- scripts/
|-- package.json
|-- tsconfig.json
|-- .eslintrc.cjs
|-- .prettierrc
`-- README.md
```

## 端侧结构文件映射（MUST）
1. 后台管理项目：读取 `rules/frontend/project-structure/admin-console.md`。
2. 公众号 H5 项目：读取 `rules/frontend/project-structure/wechat-h5.md`。
3. 小程序项目：读取 `rules/frontend/project-structure/miniprogram.md`。
4. 同一 uni-app 应用同时支持 H5 + 小程序时，必须同时读取 H5 与小程序结构文件，并按更严格规则执行。

## 应用划分示例（MUST）
1. 员工端应用：`staff-app`（uni-app，目标端可包含 H5 与小程序）。
2. C 端应用：`consumer-app`（uni-app，目标端通常为小程序）。
3. 员工端与 C 端属于不同应用，必须拆分为两个项目。

## tab-host 结构约束（适用时 MUST）
1. 多 Tab 同页切换场景可使用 `tab-host` 作为宿主页目录名。
2. `tab-host` 宿主页负责 Tab 状态与切换逻辑，子视图以组件形式挂载。
3. 仅在需要独立分享链接或独立路由权限控制时，才将子 Tab 提升为独立页面。
4. 不使用 `tab-host` 时，必须在评审说明替代方案与原因。

## 命名与依赖约束
1. `MUST`：目录使用 `kebab-case`；组件文件使用 `PascalCase`；普通模块文件使用 `kebab-case`。
2. `MUST`：业务模块之间禁止循环依赖。
3. `MUST`：禁止跨层级长相对路径（如 `../../../../`），统一使用别名。
4. `MUST`：每个项目定义统一别名，至少包含：
5. `@app/*` -> `src/app/*`
6. `@pages/*` -> `src/pages/*`
7. `@components/*` -> `src/components/*`
8. `@services/*` -> `src/services/*`
9. `@utils/*` -> `src/utils/*`
10. `@stores/*` -> `src/stores/*`

## 跨端共享边界
1. `MUST`：允许共享：`eslint-config`、`tsconfig`、工具函数库、设计 token、通用 SDK 封装。
2. `MUST`：禁止共享：页面、路由、端特有交互流程、端特有 API 直接调用逻辑。
3. `MUST`：同一应用的多端差异必须通过 `src/platform/*` 适配，不得散落在页面中。
4. `SHOULD`：共享能力通过独立包发布，不直接拷贝目录。
