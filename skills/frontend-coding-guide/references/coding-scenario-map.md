# 前端编码场景 → 规则文件映射

用此表将编码动作映射到最小规则加载集合。前端需额外考虑应用类型与框架维度。

## 始终加载（所有场景）
- `rules/frontend/common/baseline.md`
- `rules/frontend/common/naming.md`

---

## A. 新增页面（路由 + 页面组件）
- 主文件：`rules/frontend/project-structure/<target>.md`（按应用类型选择）
- 关联文件：`rules/frontend/common/project-structure.md`、`rules/frontend/common/workflow.md`
- 框架追加：`rules/frontend/frameworks/<framework>.md`
- 跨域：涉及 API 调用 → 触发 `$frontend-backend-coding-guide`

## B. 新增/修改组件
- 主文件：`rules/frontend/common/componentization-and-adaptation.md`
- 关联文件：`rules/frontend/common/performance.md`
- 框架追加：`rules/frontend/frameworks/<framework>.md`

## C. 表单开发（含校验）
- 主文件：`rules/frontend/frameworks/<framework>.md`（Schema 驱动表单）
- 关联文件：`rules/frontend/common/componentization-and-adaptation.md`、`rules/frontend/common/security.md`

## D. 列表/表格页面（数据展示 + 分页）
- 主文件：`rules/frontend/common/performance.md`
- 关联文件：`rules/frontend/frameworks/<framework>.md`
- admin-console 追加：`rules/templates/frontend/pro-table.md`

## E. 接口调用 / Service 层
- 主文件：`rules/frontend/common/stack-baseline.md`
- 关联文件：`rules/frontend/common/error-monitoring.md`
- 跨域：触发 `$frontend-backend-coding-guide`
- H5/小程序追加：`rules/templates/frontend/uni-request-wrapper.md`

## F. 状态管理（Store / 全局状态）
- 主文件：`rules/frontend/frameworks/<framework>.md`
- 关联文件：`rules/frontend/common/project-structure.md`

## G. 样式编写（CSS / Token / 主题）
- 主文件：`rules/frontend/common/componentization-and-adaptation.md`
- 关联文件：`rules/frontend/common/normalization.md`
- admin-console 追加：`rules/templates/frontend/tailwind-element-plus.md`

## H. 权限控制（路由守卫 + 按钮权限）
- 主文件：`rules/frontend/applications/admin-console.md`
- 关联文件：`rules/frontend/common/security.md`
- 模板：`rules/templates/frontend/permission-naming.md`

## I. 微信能力集成（授权/分享/支付）
- 前提：仅 wechat-h5 应用适用
- 主文件：`rules/frontend/applications/wechat-h5.md`
- 关联文件：`rules/frontend/common/error-monitoring.md`
- 模板：`rules/templates/frontend/wechat-auth-share-flow.md`

## J. 小程序专项（分包/体积/平台 API）
- 前提：仅 miniprogram 应用适用
- 主文件：`rules/frontend/applications/miniprogram.md`
- 关联文件：`rules/frontend/project-structure/miniprogram.md`、`rules/frontend/common/performance.md`

## K. 环境配置 / Feature Flag
- 主文件：`rules/frontend/common/env-config.md`
- 关联文件：`rules/frontend/common/security.md`

## L. 编写测试
- 主文件：`rules/frontend/common/testing.md`
- 关联文件：`rules/frontend/common/tooling.md`
- 模板：`rules/templates/frontend/testing-toolkit.md`

## M. Git 工作流 / PR 提交
- 主文件：`rules/frontend/common/git-workflow.md`
- 关联文件：`rules/frontend/common/workflow.md`、`rules/frontend/common/tooling.md`
- 模板：`rules/templates/frontend/git-workflow-config.md`

## N. 错误监控 / 异常上报
- 主文件：`rules/frontend/common/error-monitoring.md`
- 关联文件：`rules/frontend/common/performance.md`

## O. 安全加固（XSS/Token 存储/依赖扫描）
- 主文件：`rules/frontend/common/security.md`
- 关联文件：`rules/frontend/common/env-config.md`
- 模板：`rules/templates/frontend/security-toolkit.md`

## P. 规范化改造（Token 收敛/样式迁移）
- 主文件：`rules/frontend/common/normalization.md`
- 关联文件：`rules/frontend/common/componentization-and-adaptation.md`
- 模板：`rules/templates/frontend/normalization-toolkit.md`

## Q. 工具链 / CI 配置
- 主文件：`rules/frontend/common/tooling.md`
- 关联文件：`rules/frontend/common/workflow.md`
- 模板：`rules/templates/frontend/ci-pipeline.md`

## R. 初始化项目结构
- 主文件：`rules/frontend/project-structure/<target>.md`
- 关联文件：`rules/frontend/applications/<target>.md`、`rules/frontend/common/stack-baseline.md`
- 建议：使用 `$frontend-project-scaffold` 完成

---

## 应用类型追加规则

| 应用类型 | 额外始终加载 |
|---------|------------|
| admin-console | `rules/frontend/applications/admin-console.md` |
| wechat-h5 | `rules/frontend/applications/wechat-h5.md` |
| miniprogram | `rules/frontend/applications/miniprogram.md` |

## 场景冲突决策
1. 同时命中多个场景时，合并加载集合，去重后总量不超过 8 个。
2. 应用端规则优先于通用规则。
3. 同一 uni-app 应用同时启用 H5 与小程序规则时，取更严格条款。
4. 框架参考规则仅在应用端选型该框架时生效。
