# 前后端协作编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/frontend-backend-collaboration.md`

---

## A. 新增 API 接口（前后端同步开发）
- 主文件：`rules/frontend-backend-collaboration.md`（API 契约规范章节）
- 服务端关联（Go）：`rules/go-server/common/api-design.md`
- 服务端关联（.NET）：`rules/dotnet-server/common/api-design.md`
- 前端关联：`rules/frontend/common/stack-baseline.md`
- 模板：`rules/templates/frontend-backend/api-contract-template.md`

## B. 错误码定义与映射
- 主文件：`rules/frontend-backend-collaboration.md`（错误码与提示协同章节）
- 服务端关联（Go）：`rules/go-server/common/error-handling.md`
- 服务端关联（.NET）：`rules/dotnet-server/common/error-handling.md`
- 前端关联：`rules/frontend/common/error-monitoring.md`

## C. 鉴权与安全联动
- 主文件：`rules/frontend-backend-collaboration.md`
- 服务端关联（Go）：`rules/go-server/common/security.md`
- 服务端关联（.NET）：`rules/dotnet-server/common/security.md`
- 前端关联：`rules/frontend/common/security.md`

## D. 联调准备（自测 + 门禁）
- 主文件：`rules/frontend-backend-collaboration.md`（联调与测试章节）
- 服务端关联（Go）：`rules/go-server/common/testing-and-release.md`
- 服务端关联（.NET）：`rules/dotnet-server/common/testing-and-release.md`
- 前端关联：`rules/frontend/common/tooling.md`
- 模板：`rules/templates/frontend-backend/integration-checklist-template.md`

## E. 发布与回滚
- 主文件：`rules/frontend-backend-collaboration.md`（发布与回滚章节）
- 服务端关联（Go）：`rules/go-server/common/testing-and-release.md`
- 服务端关联（.NET）：`rules/dotnet-server/common/testing-and-release.md`
- 前端关联：`rules/frontend/common/workflow.md`
- 模板：`rules/templates/frontend-backend/release-rollback-record-template.md`

## F. 接口变更（兼容 / 非兼容）
- 主文件：`rules/frontend-backend-collaboration.md`（变更分级与流程章节）
- 关联文件：与场景 A 相同的服务端和前端文件

## G. 数据库变更联动
- 主文件：`rules/frontend-backend-collaboration.md`
- 关联文件：`rules/database/database.md`
- 服务端关联（Go）：`rules/go-server/common/database-access.md`
- 服务端关联（.NET）：`rules/dotnet-server/common/database-access.md`

---

## 加载策略
1. 根据涉及的服务端技术栈选择 Go 或 .NET 关联文件，不同时加载。
2. 仅加载当前场景命中的章节相关文件，不通读全部。
3. 已被域级 coding-guide 加载的文件不重复加载。

## 冲突优先级
1. 数据库结构冲突以 `rules/database/database.md` 为准。
2. 服务端实现细节以对应域规则为准。
3. 前端实现细节以 `rules/frontend/` 为准。
4. 跨端协作冲突以"更严格且可验证"条款为准。
