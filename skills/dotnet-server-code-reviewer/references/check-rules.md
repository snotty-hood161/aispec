# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（Roslyn analyzers/.editorconfig）/ `模式匹配`（正则/语法树）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、编码基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | .NET SDK ≥ 8.0，global.json 中明确声明版本 | 静态扫描：检查 global.json |
| BL-02 | P0 | 启用 Nullable Reference Types（`<Nullable>enable</Nullable>`） | 静态扫描：检查 .csproj 配置 |
| BL-03 | P0 | 使用最新稳定 C# 语言版本特性（record、pattern matching、file-scoped namespace） | 静态扫描：Roslyn analyzers |
| BL-04 | P0 | .editorconfig 文件存在且配置 Roslyn 代码风格规则 | 静态扫描：检查 .editorconfig 存在性 |
| BL-05 | P1 | CI 中启用 `dotnet format --verify-no-changes`，零格式差异 | 静态扫描：dotnet format |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 类型/方法/属性使用 PascalCase，局部变量/参数使用 camelCase | 静态扫描：.editorconfig 命名规则 |
| CS-02 | P0 | 使用 file-scoped namespace 声明（C# 10+） | 静态扫描：Roslyn analyzer IDE0161 |
| CS-03 | P1 | 单个方法不超过 80 行，类不超过 500 行 | 静态扫描：Roslyn analyzers / StyleCop |
| CS-04 | P1 | XML Doc 注释覆盖所有 public API | 静态扫描：CS1591 warning |
| CS-05 | P0 | 分层架构：Controller → Service → Repository，禁止跨层调用 | 人工审查：检查 using 依赖方向 |

## 三、组件初始化（common/component-initialization.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CI-01 | P0 | DI 注册使用正确生命周期（AddScoped/AddSingleton/AddTransient） | 模式匹配：搜索 DI 注册调用 |
| CI-02 | P0 | 启用 ValidateOnBuild 校验 DI 容器完整性 | 模式匹配：搜索 ValidateOnBuild 配置 |
| CI-03 | P1 | HealthChecks 注册并覆盖外部依赖（DB/Redis/MQ） | 模式匹配：搜索 AddHealthChecks 调用 |
| CI-04 | P1 | 服务注册集中于 Extension Methods，按功能模块分组 | 人工审查：检查 Program.cs 结构 |
| CI-05 | P0 | 禁止在构造函数中执行异步操作或复杂初始化逻辑 | 模式匹配：搜索构造函数中的 .Result/.Wait() |

## 四、API 设计（common/api-design.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AD-01 | P0 | API 路径包含版本号（/api/v1/...），使用 Asp.Versioning 管理 | 模式匹配：检查路由属性与版本配置 |
| AD-02 | P0 | 统一响应结构 ApiResponse<T>（code, message, data），禁止裸返回 | 模式匹配：检查 Controller 返回类型 |
| AD-03 | P0 | 请求参数使用 FluentValidation 或 DataAnnotations 校验 | 模式匹配：搜索 Validator 类或校验属性 |
| AD-04 | P1 | 分页接口使用统一分页结构（PagedResult<T>），默认页大小有上限 | 模式匹配：搜索分页参数定义 |
| AD-05 | P1 | Swagger/OpenAPI 文档通过 Swashbuckle 自动生成，CI 中校验 | 人工审查：检查 Swagger 配置 |

## 五、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 全局异常处理使用 IExceptionHandler（.NET 8+），禁止各 Controller 手动 try-catch | 模式匹配：搜索 Controller 中的 try-catch |
| EH-02 | P0 | 业务异常继承自统一 BusinessException，携带错误码 | 模式匹配：搜索自定义异常类定义 |
| EH-03 | P0 | 错误响应符合 RFC 7807 ProblemDetails 格式 | 模式匹配：搜索错误响应格式 |
| EH-04 | P1 | 异常日志包含完整堆栈与请求上下文（TraceId/RequestPath） | 人工审查：检查异常日志输出 |
| EH-05 | P1 | 禁止吞掉异常（空 catch 块），必须记录或重新抛出 | 静态扫描：Roslyn analyzer CA1031 |

## 六、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 使用 Serilog 结构化日志，禁止 Console.WriteLine / Debug.WriteLine | 模式匹配：搜索 Console.Write / Debug.Write 调用 |
| OB-02 | P0 | 日志携带 TraceId / CorrelationId，通过 Serilog Enricher 自动注入 | 模式匹配：搜索 Serilog Enricher 配置 |
| OB-03 | P1 | OpenTelemetry 集成，覆盖 HTTP 入口与出口、数据库调用 | 人工审查：检查 OpenTelemetry 配置 |
| OB-04 | P1 | 关键业务操作使用 ActivitySource 创建自定义 Span | 人工审查：检查 ActivitySource 使用 |
| OB-05 | P1 | 日志级别分层使用（Debug/Information/Warning/Error），生产环境 ≥ Information | 模式匹配：检查日志级别配置 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置（ConnectionString/Secret）禁止硬编码或提交到代码仓库 | 静态扫描：搜索硬编码连接字符串/密钥模式 |
| CF-02 | P0 | 使用 Options Pattern（IOptions<T>/IOptionsSnapshot<T>）绑定配置 | 模式匹配：搜索配置绑定方式 |
| CF-03 | P0 | 配置文件按环境分离：appsettings.json / appsettings.{env}.json | 静态扫描：检查配置文件存在性 |
| CF-04 | P1 | 配置类使用 DataAnnotations + ValidateOnStart 启动时校验 | 模式匹配：搜索 ValidateDataAnnotations 调用 |

## 八、并发与资源管理（common/concurrency-and-resource.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CR-01 | P0 | 异步方法全链路 async/await，禁止 .Result / .Wait() / .GetAwaiter().GetResult() | 静态扫描：Roslyn analyzer / 搜索 .Result .Wait() |
| CR-02 | P0 | 实现 IDisposable / IAsyncDisposable 的资源使用 using 语句管理 | 模式匹配：搜索 new 实例化后是否有 using |
| CR-03 | P0 | CancellationToken 贯穿异步调用链，Controller 到 Repository 全程传递 | 模式匹配：搜索异步方法签名是否包含 CancellationToken |
| CR-04 | P1 | HttpClient 通过 IHttpClientFactory 创建，禁止 new HttpClient() | 模式匹配：搜索 new HttpClient() |
| CR-05 | P1 | 优雅停机：IHostApplicationLifetime 注册 ApplicationStopping 回调 | 人工审查：检查停机逻辑 |

## 九、数据库访问（common/database-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库操作通过 Repository 层，禁止 Controller/Service 直接操作 DbContext | 模式匹配：搜索 Controller/Service 中的 DbContext 使用 |
| DA-02 | P0 | 只读查询使用 AsNoTracking()，减少 Change Tracker 开销 | 模式匹配：搜索查询调用链是否包含 AsNoTracking |
| DA-03 | P0 | 事务边界在 Service 层通过 IUnitOfWork 或 SaveChanges 控制 | 人工审查：检查事务管理位置 |
| DA-04 | P1 | 禁止在循环中执行数据库查询（N+1 问题），使用 Include/批量查询 | 模式匹配：搜索循环内的 DbContext/Repository 调用 |
| DA-05 | P1 | EF Core Migration 有序管理，禁止手动修改 Migration 文件 | 人工审查：检查 Migration 文件完整性 |
| DA-06 | P1 | 原生 SQL 使用参数化查询（FromSqlInterpolated），禁止字符串拼接 | 模式匹配：搜索 FromSqlRaw 拼接模式 |

## 十、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 所有外部输入必须校验，Controller 参数使用 FluentValidation/DataAnnotations | 模式匹配：检查参数绑定后是否有校验 |
| SC-02 | P0 | [Authorize] 覆盖所有受保护端点，JWT 配置正确且验证签名 | 模式匹配：检查 Controller/Action 的授权属性 |
| SC-03 | P0 | 敏感数据禁止明文日志输出，Serilog Destructure 配置排除敏感属性 | 模式匹配：搜索日志中的敏感字段 |
| SC-04 | P1 | CORS 配置白名单化，禁止 AllowAnyOrigin 用于生产 | 模式匹配：搜索 CORS 配置 |
| SC-05 | P1 | Rate Limiting 中间件已配置（UseRateLimiter），防止暴力请求 | 模式匹配：搜索 AddRateLimiter 配置 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | 核心业务逻辑有单元测试（xUnit/NUnit），覆盖率 ≥ 60% | 静态扫描：dotnet test --collect:"XPlat Code Coverage" |
| TR-02 | P0 | 集成测试使用 WebApplicationFactory<Program>，覆盖核心 API | 模式匹配：搜索 WebApplicationFactory 使用 |
| TR-03 | P1 | 测试项目命名 *.Tests / *.IntegrationTests，与源项目对应 | 模式匹配：检查测试项目命名 |
| TR-04 | P1 | CI 流水线包含 format → build → test 阶段，质量门禁阻断不合格构建 | 人工审查：检查 CI 配置 |
| TR-05 | P1 | Mock 使用 Moq/NSubstitute，禁止测试中使用真实外部服务 | 模式匹配：搜索测试中的 Mock 框架使用 |

## 十二、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P1 | 性能基线使用 BenchmarkDotNet 建立，关键路径有基准测试 | 模式匹配：搜索 [Benchmark] 属性 |
| PF-02 | P1 | 热点路径避免大对象分配，使用 ArrayPool<T> / Span<T> | 模式匹配：搜索高频分配的 byte[]/string 操作 |
| PF-03 | P1 | EF Core 查询有索引覆盖，禁止全表扫描 | 人工审查：检查查询与索引匹配 |
| PF-04 | P1 | 响应压缩（UseResponseCompression）已配置 | 模式匹配：搜索 AddResponseCompression 配置 |

## 十三、缓存（common/caching.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CA-01 | P0 | 缓存键设计包含业务前缀与版本号，避免键冲突 | 模式匹配：检查缓存键构造模式 |
| CA-02 | P0 | 所有缓存必须设置过期时间（AbsoluteExpiration/SlidingExpiration） | 模式匹配：搜索 Set 调用是否带过期参数 |
| CA-03 | P0 | 使用 IMemoryCache / IDistributedCache 接口，禁止直接依赖实现 | 模式匹配：搜索缓存注入类型 |
| CA-04 | P1 | 缓存穿透/击穿/雪崩有防护措施（Lazy/SemaphoreSlim/随机过期） | 人工审查：检查缓存防护策略 |

## 十四、文件存储（common/file-storage.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FS-01 | P0 | 文件上传限制大小与类型，校验 Content-Type | 模式匹配：检查上传处理中的校验逻辑 |
| FS-02 | P0 | 文件使用 Stream 处理（IFormFile.OpenReadStream），禁止全量 ReadAllBytes | 模式匹配：搜索 ReadAllBytes 用于大文件 |
| FS-03 | P1 | 文件存储路径使用唯一标识（GUID/Hash），禁止用户原始文件名 | 模式匹配：检查文件存储路径生成 |
| FS-04 | P1 | 对象存储使用预签名 URL 直传，减少服务端中转 | 人工审查：检查上传流程架构 |

## 十五、定时任务（common/scheduled-tasks.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| ST-01 | P0 | 定时任务必须幂等，重复执行不产生副作用 | 人工审查：检查任务逻辑幂等性 |
| ST-02 | P0 | 后台任务继承 BackgroundService 或使用 Quartz.NET，禁止 Task.Run 裸启动 | 模式匹配：搜索 Task.Run 启动后台循环 |
| ST-03 | P1 | 多实例部署时使用分布式锁，防止任务重复执行 | 模式匹配：搜索分布式锁获取逻辑 |
| ST-04 | P1 | 任务执行有 CancellationToken 支持，响应优雅停机 | 模式匹配：搜索 BackgroundService 中的 stoppingToken 使用 |

## 十六、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止在生产代码中使用 Console.WriteLine / Debug.WriteLine | 静态扫描：Roslyn analyzer / 搜索 Console.Write |
| FB-02 | P0 | 禁止提交包含密钥/密码/连接字符串的代码 | 静态扫描：git-secrets / gitleaks |
| FB-03 | P0 | 禁止使用已废弃 API（[Obsolete]），Roslyn 告警视为错误 | 静态扫描：Roslyn analyzer CS0618 |
| FB-04 | P0 | 禁止空 catch 块吞掉异常 | 静态扫描：Roslyn analyzer CA1031 |
| FB-05 | P0 | 禁止在 Controller 中直接操作 DbContext，必须经过 Service 层 | 模式匹配：搜索 Controller 中的 DbContext 注入 |

---

## Profile 专项检查

### Monolith 专项（profiles/monolith/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MO-01 | P0 | 模块间通过接口（interface）解耦，禁止直接引用其他模块实现类 | 模式匹配：检查 using 中的跨模块引用 |
| MO-02 | P1 | 模块边界清晰，每个模块有独立的 Controller/Service/Repository 层 | 人工审查：检查项目目录结构 |
| MO-03 | P1 | 共享组件集中于 Common/Shared 项目，通过 NuGet 内部包或项目引用 | 模式匹配：检查共享代码位置 |
| MO-04 | P1 | 模块间数据传递使用 DTO，禁止直接共享 EF Core Entity | 模式匹配：搜索跨模块的 Entity 引用 |

### Microservice 专项（profiles/microservice/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MS-01 | P0 | 服务间通信使用 gRPC/HTTP + 统一序列化（System.Text.Json），禁止私有协议 | 模式匹配：检查服务间调用方式 |
| MS-02 | P0 | 外部调用通过 IHttpClientFactory + Polly 配置超时、重试与熔断 | 模式匹配：搜索 HttpClient 配置与 Polly 策略 |
| MS-03 | P1 | 服务注册与发现配置正确，健康检查端点可用 | 人工审查：检查服务注册配置 |
| MS-04 | P1 | 分布式事务使用 Saga/Outbox Pattern，禁止跨服务本地事务 | 人工审查：检查跨服务事务处理 |
| MS-05 | P1 | 服务间通信携带 TraceId，OpenTelemetry Propagation 配置完整 | 模式匹配：检查 Propagator 配置 |
