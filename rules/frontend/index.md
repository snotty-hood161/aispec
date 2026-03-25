# rules/frontend/index.md

## 目的
1. 统一前端工程约束，覆盖后台管理、公众号 H5、小程序三类项目。
2. 采用"按应用拆分项目 + 公共编码规范"模式，降低复杂度并提升可执行性。
3. 所有规则优先强调"可执行、可检查、可追踪"。

## 适用范围
1. 适用于后台管理、公众号 H5、小程序三类前端项目。
2. 默认使用 TypeScript；JavaScript 项目需先完成迁移计划后再接入本规范。
3. 若需例外，必须在评审中记录原因、边界、回收时间，并绑定责任人。

## 规则组成
1. `common`：所有前端项目必须遵守。
2. `project-structure`：按应用端选择的项目结构规则。
3. `applications`：按应用端选择的技术栈与业务规则。
4. `frameworks`：按框架选择的专用约束（Vue3/React）。
5. 跨端协作：`rules/frontend-backend-collaboration.md`（前后端契约与联调）。

## 适用方式
1. 后台管理：`common + project-structure/admin-console + applications/admin-console + (可选)对应 framework 参考规则`
2. uni-app 应用（仅 H5 目标）：`common + project-structure/wechat-h5 + applications/wechat-h5`
3. uni-app 应用（仅小程序目标）：`common + project-structure/miniprogram + applications/miniprogram`
4. uni-app 应用（同时 H5 + 小程序）：`common + project-structure/wechat-h5 + project-structure/miniprogram + applications/wechat-h5 + applications/miniprogram`
5. 每个应用项目先在 `applications/*.md` 锁定技术栈，再按 `project-structure/*.md` 落地目录结构。

## Skill 协作（推荐）
1. 编写前端代码时优先使用 `$frontend-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 规则新增、修改、重构、审计任务，优先使用 `$frontend-rules-maintainer`。
4. Skill 执行时必须按需加载规则文件，不得一次性通读全部规范。
5. 涉及前后端 API 契约、联调、发布回滚时，优先使用 `$frontend-backend-coding-guide`。

## 冲突优先级
1. 端侧结构文件（`project-structure/*.md`）在结构主题内优先于 `common/project-structure.md`。
2. 应用端规则优先于通用规则。
3. 同一 uni-app 应用同时启用 `wechat-h5` 和 `miniprogram` 时，以"目标端更严格规则"为准。
4. 框架参考规则仅在应用端选型该框架时生效。
5. 通用规则仅定义共性，不覆盖端侧专项要求。
6. 前后端协作相关条款以 `rules/frontend-backend-collaboration.md` 为准。
7. 当存在同级冲突时，以"更严格且可验证"的条款为准。

---

## 目录索引

### 快速上手
0. `quickstart.md` — 新人阅读路径、第一个 PR 指引、MUST 规则速查卡

### 通用规则（common）— 所有前端项目必须遵守
1. `common/governance.md` — 规则分级（MUST/SHOULD/MAY）、治理流程、版本策略
2. `common/project-structure.md` — 跨应用通用结构边界、别名约束、跨端共享
3. `common/stack-baseline.md` — 技术栈与依赖基线（Vue3/uni-app）、禁用项
4. `common/baseline.md` — TypeScript 基线、注释规范、API 约束、调试代码清理
5. `common/naming.md` — 命名规范（变量/组件/Token/tab-host）
6. `common/tooling.md` — 脚本契约、CI 标准、构建产物清理配置、依赖校验
7. `common/workflow.md` — 交付流程、按需加载策略、危险操作确认
8. `common/normalization.md` — 规范化改造流程（Token 优先、样式重构）
9. `common/componentization-and-adaptation.md` — 组件分层、设计约束、端适配策略
10. `common/performance.md` — 性能指标基线、Bundle 体积、加载策略、渲染/网络/内存
11. `common/error-monitoring.md` — 异常捕获、错误上报、接口监控、行为埋点
12. `common/git-workflow.md` — Git 分支命名、Conventional Commits、合并策略、Tag 规范
13. `common/testing.md` — 测试策略、覆盖率要求、Mock 规范、文件组织
14. `common/security.md` — 前端安全基线（XSS/Token 存储/CORS/依赖扫描/密钥管理）
15. `common/env-config.md` — 环境配置（.env 规范/多环境隔离/Feature Flag）

### 项目结构规则 — 按应用端选择
16. `project-structure/admin-console.md` — 后台管理目录结构与分层边界
17. `project-structure/wechat-h5.md` — 公众号 H5 目录结构与平台分层
18. `project-structure/miniprogram.md` — 小程序目录结构与分包边界

### 应用端规则 — 按应用端选择
19. `applications/admin-console.md` — 后台管理技术栈锁定与业务规则
20. `applications/wechat-h5.md` — 公众号 H5 技术栈与微信生态规则
21. `applications/miniprogram.md` — 小程序技术栈、平台规则、发布审核

### 框架参考规则 — 按技术栈选择
22. `frameworks/vue3-typescript.md` — Vue3 + TypeScript 专用约束（SFC/Pinia/表单/性能/ESLint）
23. `frameworks/react-typescript.md` — React + TypeScript 专用约束（Hooks/状态/表单/性能/ESLint）

### 跨端协作
24. `rules/frontend-backend-collaboration.md` — 前后端契约、联调、发布回滚

### 历史兼容
25. `matrix/combination-overrides.md` — 框架与应用端组合覆盖规则（按需加载）

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/frontend/pr-review-checklist.md` — 前端 PR 评审清单
- `templates/frontend/eslint-prettier-baseline.md` — ESLint / Prettier 配置基线
- `templates/frontend/permission-naming.md` — 权限点命名规范（admin-console）
- `templates/frontend/uni-request-wrapper.md` — uni.request 标准封装（H5 + 小程序）
- `templates/frontend/miniprogram-review-checklist.md` — 小程序审核清单
- `templates/frontend/tailwind-element-plus.md` — Tailwind + Element Plus 组合约束
- `templates/frontend/wechat-auth-share-flow.md` — 微信授权与分享流程规范
- `templates/frontend/pro-table.md` — Schema-Driven 表格（ProTable）
- `templates/frontend/tiptap-editor.md` — Tiptap 富文本编辑器封装
- `templates/frontend/dependency-management.md` — 依赖管理与脚手架依赖清单
- `templates/frontend/component-patterns.md` — 三端组件示例与适配层
- `templates/frontend/normalization-toolkit.md` — 规范化改造工具包
- `templates/frontend/workflow-toolkit.md` — 交付流程工具包
- `templates/frontend/miniprogram-ci-checks.md` — 小程序 CI 检查脚本
- `templates/frontend/naming-toolkit.md` — 命名规范工具包
- `templates/frontend/wechat-h5-toolkit.md` — 微信 H5 工具包
- `templates/frontend/git-workflow-config.md` — commitlint / husky / 分支保护配置
- `templates/frontend/testing-toolkit.md` — Vitest 配置 / testing-library 样板
- `templates/frontend/security-toolkit.md` — CSP / DOMPurify / 依赖审计脚本
- `templates/frontend/ci-pipeline.md` — GitHub Actions 完整 CI 流水线
