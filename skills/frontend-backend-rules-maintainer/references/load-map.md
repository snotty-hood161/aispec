# 任务类型 -> 规则文件映射（跨端按需加载）

## 统一入口（必须读取）
- `rules/frontend-backend-collaboration.md`

## A. API 契约变更（字段/路径/方法）
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件（前端）：`rules/frontend/common/stack-baseline.md`
- 关联文件（Go 服务端）：`rules/go-server/common/api-design.md`
- 关联文件（.NET 服务端）：`rules/dotnet-server/common/api-design.md`

## B. 错误码与提示协同
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件（前端）：`rules/frontend/common/baseline.md`
- 关联文件（Go 服务端）：`rules/go-server/common/error-handling.md`
- 关联文件（.NET 服务端）：`rules/dotnet-server/common/error-handling.md`

## C. 鉴权与安全联动
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件（前端）：`rules/frontend/applications/wechat-h5.md` 或 `rules/frontend/applications/miniprogram.md`
- 关联文件（Go 服务端）：`rules/go-server/common/security.md`
- 关联文件（.NET 服务端）：`rules/dotnet-server/common/security.md`

## D. 联调与测试门禁
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件（前端）：`rules/frontend/common/tooling.md`, `rules/frontend/common/workflow.md`
- 关联文件（Go 服务端）：`rules/go-server/common/testing-and-release.md`
- 关联文件（.NET 服务端）：`rules/dotnet-server/common/testing-and-release.md`

## E. 发布顺序与回滚
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件（前端）：`rules/frontend/common/workflow.md`
- 关联文件（Go 服务端）：`rules/go-server/common/testing-and-release.md`
- 关联文件（.NET 服务端）：`rules/dotnet-server/common/testing-and-release.md`

## F. 数据库结构联动
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件（数据库）：`rules/database/database.md`
- 关联文件（Go 服务端）：`rules/go-server/common/database-access.md`
- 关联文件（.NET 服务端）：`rules/dotnet-server/common/database-access.md`

## G. 协作文档与模板落地
- 主文件：`rules/frontend-backend-collaboration.md`
- 模板文件：`rules/templates/frontend-backend/api-contract-template.md`
- 模板文件：`rules/templates/frontend-backend/integration-checklist-template.md`
- 模板文件：`rules/templates/frontend-backend/release-rollback-record-template.md`

## H. 规范例外申请
- 主文件：`rules/frontend-backend-collaboration.md`
- 模板文件：`rules/templates/exception-request-template.md`
- 说明：处理无法符合跨端约定的特殊场景（如第三方 API 兼容性限制）

## 冲突优先级
1. 数据库结构冲突：以 `rules/database/database.md` 为准。
2. 前端实现细节冲突：以 `rules/frontend/` 为准。
3. 服务端实现细节冲突：以对应服务端规则域（`rules/go-server/` 或 `rules/dotnet-server/`）为准。
4. 跨端协作冲突无法消解：采用更严格且可验证条款。