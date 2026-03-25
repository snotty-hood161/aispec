# .NET 服务端编码场景 → 规则文件映射

用此表将编码动作映射到最小规则加载集合。

## 始终加载（所有场景）
- `rules/dotnet-server/common/baseline.md`
- `rules/dotnet-server/common/forbidden.md`

---

## A. 新增 API 接口（Controller + 路由）
- 主文件：`rules/dotnet-server/common/api-design.md`
- 关联文件：`rules/dotnet-server/common/error-handling.md`、`rules/dotnet-server/common/code-style.md`、`rules/dotnet-server/common/security.md`
- Profile：当前 profile 的 `project-structure.md`
- 跨域：涉及前端调用 → 触发 `$frontend-backend-coding-guide`

## B. 修改/新增数据库查询或模型（EF Core / Dapper）
- 主文件：`rules/dotnet-server/common/database-access.md`
- 关联文件：`rules/dotnet-server/common/code-style.md`、`rules/dotnet-server/common/performance.md`
- 跨域：涉及 schema 变更 → 触发 `$database-coding-guide`

## C. 新增/修改 Service 层业务逻辑
- 主文件：`rules/dotnet-server/common/code-style.md`
- 关联文件：`rules/dotnet-server/common/error-handling.md`、`rules/dotnet-server/common/observability.md`

## D. 添加后台任务 / Worker Service / 定时作业
- 主文件：`rules/dotnet-server/common/scheduled-tasks.md`
- 关联文件：`rules/dotnet-server/common/concurrency-and-resource.md`、`rules/dotnet-server/common/observability.md`

## E. 接入缓存（IMemoryCache / IDistributedCache / Redis）
- 主文件：`rules/dotnet-server/common/caching.md`
- 关联文件：`rules/dotnet-server/common/database-access.md`、`rules/dotnet-server/common/observability.md`

## F. 文件上传下载 / 对象存储
- 主文件：`rules/dotnet-server/common/file-storage.md`
- 关联文件：`rules/dotnet-server/common/api-design.md`、`rules/dotnet-server/common/security.md`

## G. 添加/修改中间件（鉴权、限流、CORS、异常过滤器）
- 主文件：`rules/dotnet-server/common/security.md`
- 关联文件：`rules/dotnet-server/common/api-design.md`、`rules/dotnet-server/common/error-handling.md`

## H. 添加日志、监控、链路追踪
- 主文件：`rules/dotnet-server/common/observability.md`
- 关联文件：`rules/dotnet-server/common/component-initialization.md`

## I. 修改配置管理（appsettings / IOptions / 环境变量）
- 主文件：`rules/dotnet-server/common/configuration.md`
- 关联文件：`rules/dotnet-server/common/component-initialization.md`

## J. 异步编程 / 资源管理 / 优雅停机
- 主文件：`rules/dotnet-server/common/concurrency-and-resource.md`
- 关联文件：`rules/dotnet-server/common/component-initialization.md`、`rules/dotnet-server/common/observability.md`

## K. 编写测试 / 配置 CI
- 主文件：`rules/dotnet-server/common/testing-and-release.md`
- 关联文件：`rules/dotnet-server/common/code-style.md`
- 模板：`rules/templates/dotnet-server/pr-review-checklist.md`

## L. 依赖注入 / 组件生命周期（IServiceCollection / IHost）
- 主文件：`rules/dotnet-server/common/component-initialization.md`
- 关联文件：`rules/dotnet-server/common/concurrency-and-resource.md`

## M. 性能优化（Profiling、内存、查询调优）
- 主文件：`rules/dotnet-server/common/performance.md`
- 关联文件：`rules/dotnet-server/common/database-access.md`、`rules/dotnet-server/common/caching.md`

## N. 初始化项目结构
- 主文件：当前 profile 的 `project-structure.md`
- 关联文件：`rules/dotnet-server/common/code-style.md`、`rules/dotnet-server/common/component-initialization.md`
- 建议：使用 `$dotnet-server-project-scaffold` 完成

---

## 场景冲突决策
1. 同时命中多个场景时，合并加载集合，去重后总量不超过 8 个。
2. `profile` 规则优先于 `common` 中同主题的描述。
3. 数据库迁移冲突以 `rules/database/database.md` 为准。
