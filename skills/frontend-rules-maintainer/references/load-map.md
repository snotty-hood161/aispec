# 任务类型 -> 规则文件映射（按需加载）

用此表将需求映射到最小读取集合，避免一次性通读全部规则。

## A. 技术栈与依赖选型
- 主文件：`rules/frontend/common/stack-baseline.md`
- 关联文件：`rules/frontend/applications/*.md`

## B. 项目结构与边界
- 主文件：`rules/frontend/project-structure/<target>.md`
- 关联文件：`rules/frontend/common/project-structure.md`, `rules/frontend/common/naming.md`
- 关联文件：`rules/frontend/applications/<target>.md`

## C. 样式、Token、组件适配
- 主文件：`rules/frontend/common/componentization-and-adaptation.md`
- 关联文件：`rules/frontend/common/normalization.md`, `rules/frontend/common/naming.md`

## D. 小程序专项（图标、包体、分包、平台适配）
- 主文件：`rules/frontend/applications/miniprogram.md`
- 关联文件：`rules/frontend/project-structure/miniprogram.md`, `rules/frontend/common/tooling.md`, `rules/frontend/common/normalization.md`

## E. H5 专项（微信能力、活动页）
- 主文件：`rules/frontend/applications/wechat-h5.md`
- 关联文件：`rules/frontend/project-structure/wechat-h5.md`, `rules/frontend/common/componentization-and-adaptation.md`

## F. 后台管理专项
- 主文件：`rules/frontend/applications/admin-console.md`
- 关联文件：`rules/frontend/project-structure/admin-console.md`, `rules/frontend/common/stack-baseline.md`

## G. 命名与目录命名
- 主文件：`rules/frontend/common/naming.md`
- 关联文件：`rules/frontend/common/project-structure.md`, `rules/frontend/project-structure/<target>.md`

## H. 工具链、CI、门禁
- 主文件：`rules/frontend/common/tooling.md`
- 关联文件：`rules/frontend/common/workflow.md`, `rules/frontend/common/stack-baseline.md`

## I. 流程、风险确认、交付格式
- 主文件：`rules/frontend/common/workflow.md`
- 关联文件：`rules/frontend/common/governance.md`

## J. 规则新增/改造方法
- 主文件：`rules/frontend/common/governance.md`
- 关联文件：`rules/frontend/index.md`

## K. 前后端协作（API 契约/联调/发布回滚）
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件：`rules/frontend/common/tooling.md`, `rules/frontend/common/workflow.md`

## L. 框架选型与编码（Vue3 / React）
- 主文件：`rules/frontend/frameworks/vue3-typescript.md`（Vue3 项目）或 `rules/frontend/frameworks/react-typescript.md`（React 项目）
- 关联文件：`rules/frontend/common/stack-baseline.md`, `rules/frontend/applications/<target>.md`

## M. 性能优化与监控
- 主文件：`rules/frontend/common/performance.md`
- 关联文件：`rules/frontend/common/error-monitoring.md`, `rules/frontend/common/tooling.md`

## N. 错误监控与上报
- 主文件：`rules/frontend/common/error-monitoring.md`
- 关联文件：`rules/frontend/common/performance.md`, `rules/frontend/common/workflow.md`

## O. PR 评审标准
- 主文件：`rules/templates/frontend/pr-review-checklist.md`
- 关联文件：`rules/frontend/common/governance.md`, `rules/frontend/common/tooling.md`

## P. 编码基线（TypeScript / 注释 / 调试代码）
- 主文件：`rules/frontend/common/baseline.md`
- 关联文件：`rules/frontend/common/tooling.md`, `rules/frontend/common/governance.md`

## Q. 框架与应用端组合覆盖
- 主文件：`rules/frontend/matrix/combination-overrides.md`
- 关联文件：`rules/frontend/frameworks/<framework>.md`, `rules/frontend/applications/<target>.md`

## R. ESLint / Prettier 配置
- 主文件：`rules/templates/frontend/eslint-prettier-baseline.md`
- 关联文件：`rules/frontend/common/tooling.md`, `rules/frontend/frameworks/<framework>.md`

## S. 权限命名规范（admin-console）
- 主文件：`rules/templates/frontend/permission-naming.md`
- 关联文件：`rules/frontend/applications/admin-console.md`, `rules/frontend/common/naming.md`

## T. uni.request 请求封装（H5 + 小程序）
- 主文件：`rules/templates/frontend/uni-request-wrapper.md`
- 关联文件：`rules/frontend/applications/wechat-h5.md`, `rules/frontend/applications/miniprogram.md`

## U. 小程序审核自查
- 主文件：`rules/templates/frontend/miniprogram-review-checklist.md`
- 关联文件：`rules/frontend/applications/miniprogram.md`

## V. Tailwind + Element Plus 集成（admin-console）
- 主文件：`rules/templates/frontend/tailwind-element-plus.md`
- 关联文件：`rules/frontend/applications/admin-console.md`, `rules/frontend/common/componentization-and-adaptation.md`

## W. 微信授权与分享流程（H5）
- 主文件：`rules/templates/frontend/wechat-auth-share-flow.md`
- 关联文件：`rules/frontend/applications/wechat-h5.md`, `rules/frontend-backend-collaboration.md`

## X. 规范例外申请
- 主文件：`rules/templates/exception-request-template.md`
- 关联文件：`rules/frontend/common/governance.md`

## Y. Schema-Driven 表格与富文本（admin-console）
- 主文件：`rules/templates/frontend/pro-table.md`, `rules/templates/frontend/tiptap-editor.md`
- 关联文件：`rules/frontend/applications/admin-console.md`

## Z. 依赖管理与脚手架清单
- 主文件：`rules/templates/frontend/dependency-management.md`
- 关联文件：`rules/frontend/common/stack-baseline.md`, `rules/frontend/common/tooling.md`

## AA. 三端组件示例与适配层
- 主文件：`rules/templates/frontend/component-patterns.md`
- 关联文件：`rules/frontend/common/componentization-and-adaptation.md`

## AB. 规范化改造工具包
- 主文件：`rules/templates/frontend/normalization-toolkit.md`
- 关联文件：`rules/frontend/common/normalization.md`

## AC. 交付流程工具包
- 主文件：`rules/templates/frontend/workflow-toolkit.md`
- 关联文件：`rules/frontend/common/workflow.md`

## AD. 小程序 CI 检查脚本
- 主文件：`rules/templates/frontend/miniprogram-ci-checks.md`
- 关联文件：`rules/frontend/applications/miniprogram.md`, `rules/frontend/common/tooling.md`

## AE. 命名规范工具包
- 主文件：`rules/templates/frontend/naming-toolkit.md`
- 关联文件：`rules/frontend/common/naming.md`

## AF. 微信 H5 工具包
- 主文件：`rules/templates/frontend/wechat-h5-toolkit.md`
- 关联文件：`rules/frontend/applications/wechat-h5.md`

## AG. Git 工作流（分支/提交/合并）
- 主文件：`rules/frontend/common/git-workflow.md`
- 关联文件：`rules/frontend/common/workflow.md`, `rules/frontend/common/tooling.md`

## AH. 测试策略与覆盖率
- 主文件：`rules/frontend/common/testing.md`
- 关联文件：`rules/frontend/common/tooling.md`, `rules/frontend/frameworks/<framework>.md`

## AI. 前端安全基线
- 主文件：`rules/frontend/common/security.md`
- 关联文件：`rules/frontend/common/baseline.md`, `rules/frontend/common/env-config.md`

## AJ. 环境配置与 Feature Flag
- 主文件：`rules/frontend/common/env-config.md`
- 关联文件：`rules/frontend/common/stack-baseline.md`, `rules/frontend/common/security.md`

## AK. CI 流水线配置
- 主文件：`rules/templates/frontend/ci-pipeline.md`
- 关联文件：`rules/frontend/common/tooling.md`, `rules/frontend/common/workflow.md`, `rules/frontend/common/testing.md`

## AKa. Git 工作流配置（commitlint / husky / 分支保护）
- 主文件：`rules/templates/frontend/git-workflow-config.md`
- 关联文件：`rules/frontend/common/git-workflow.md`, `rules/frontend/common/tooling.md`

## AKb. 测试工具包（Vitest / testing-library）
- 主文件：`rules/templates/frontend/testing-toolkit.md`
- 关联文件：`rules/frontend/common/testing.md`, `rules/frontend/common/tooling.md`

## AKc. 安全工具包（CSP / DOMPurify / 依赖审计）
- 主文件：`rules/templates/frontend/security-toolkit.md`
- 关联文件：`rules/frontend/common/security.md`, `rules/frontend/common/baseline.md`

## AL. 新人快速上手
- 主文件：`rules/frontend/quickstart.md`
- 关联文件：`rules/frontend/index.md`, `rules/frontend/common/governance.md`

## 冲突决策
1. 应用端规则优先于通用规则。
2. 同一 uni-app 应用同时启用 H5 与小程序规则时，取更严格条款。
3. 同级冲突按“更严格且可验证”处理。
