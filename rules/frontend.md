# rules/frontend.md

本文件保留为兼容入口，详细规则已拆分到目录化规范。

## 阅读入口
1. 总入口：`rules/frontend/index.md`
2. 治理规则：`rules/frontend/common/governance.md`
3. 通用结构边界：`rules/frontend/common/project-structure.md`
4. 后台管理结构：`rules/frontend/project-structure/admin-console.md`
5. 公众号 H5 结构：`rules/frontend/project-structure/wechat-h5.md`
6. 小程序结构：`rules/frontend/project-structure/miniprogram.md`
7. 技术栈基线：`rules/frontend/common/stack-baseline.md`
8. 通用编码规范：`rules/frontend/common/baseline.md`
9. 命名规范：`rules/frontend/common/naming.md`
10. 工具链与 CI：`rules/frontend/common/tooling.md`
11. 执行流程规范：`rules/frontend/common/workflow.md`
12. 规范化改造：`rules/frontend/common/normalization.md`
13. 组件化与适配：`rules/frontend/common/componentization-and-adaptation.md`
14. 应用端规则：`rules/frontend/applications/`
15. 框架参考规则：`rules/frontend/frameworks/`
16. 前后端协作：`rules/frontend-backend-collaboration.md`

## 使用方式
1. 项目边界按应用划分，不按端类型机械拆分。
2. 做后台管理项目时，优先读取 `project-structure/admin-console.md`。
3. 做公众号 H5 项目时，优先读取 `project-structure/wechat-h5.md`。
4. 做小程序项目时，优先读取 `project-structure/miniprogram.md`。
5. 同一应用若同时需要 H5 与小程序，可使用同一 `uni-app` 项目并叠加 H5 与小程序结构规则。
6. 不同应用（例如员工端与 C 端）必须拆分项目，即使都使用 `uni-app`。
7. 每个项目先在对应应用规则文件中锁定技术栈，再开始开发。
8. 所有项目必须遵守 `common` 编码规范与组件化适配规范。
9. 编写代码时使用 `$frontend-coding-guide` 按编码场景自动加载对应规则。
10. 跨域业务任务使用 `$task-router` 自动路由到涉及的域。
11. 规则维护任务建议使用 `$frontend-rules-maintainer`，并遵循按需加载策略。
12. 涉及跨端契约与联调任务建议使用 `$frontend-backend-coding-guide`。
