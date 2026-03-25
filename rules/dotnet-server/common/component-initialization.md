# rules/dotnet-server/common/component-initialization.md

## 目标
1. 统一服务端组件初始化方案，避免隐藏依赖、静态单例滥用和启动顺序漂移。
2. 覆盖常见基础组件：日志、数据库/EF Core、Redis、MinIO/对象存储、JWT。

## DI 总体策略
1. 默认采用 ASP.NET Core 内置 DI 容器（`Microsoft.Extensions.DependencyInjection`），依赖通过构造函数注入。
2. 允许使用第三方 DI 容器（如 Autofac）用于高级场景（属性注入、装饰器模式），但必须经评审通过。
3. 服务注册统一在 `Program.cs` 或独立的 `ServiceCollectionExtensions` 扩展方法中完成。
4. `Program.cs` 仅负责：加载配置、注册服务、配置中间件管道、启动服务、优雅退出。

## 生命周期管理
1. 服务注册时必须明确生命周期：`Transient`、`Scoped`、`Singleton`。
2. `Scoped` 服务禁止被 `Singleton` 服务依赖（Captive Dependency 问题），启用 `ValidateScopes` 和 `ValidateOnBuild` 检测。
3. 配置启用严格校验：
   ```csharp
   builder.Host.UseDefaultServiceProvider(options =>
   {
       options.ValidateScopes = true;
       options.ValidateOnBuild = true;
   });
   ```
4. 所有实现 `IDisposable` / `IAsyncDisposable` 的服务由 DI 容器管理生命周期，禁止手动 `new` 后忘记释放。

## 初始化与启动顺序
1. 推荐注册顺序：`Configuration -> Logging -> Metrics/Tracing -> DbContext -> Redis -> MinIO -> JWT -> Repository -> Service -> Controller/Endpoint`。
2. 组件初始化失败的默认策略是快速失败（fail fast）；可选组件需明确定义降级策略并记录日志。
3. 进程退出时必须调用 `IHost.StopAsync` 触发优雅停机，由 `IHostedService.StopAsync` 和 `IHostApplicationLifetime` 管理关闭顺序。
4. 进程退出超时必须可配置（`ShutdownTimeout`），避免阻塞在资源回收阶段。

## 健康检查与就绪检查
1. 服务必须注册健康检查端点（`/healthz` 或 `/health`）和就绪端点（`/readyz` 或 `/ready`），使用 `Microsoft.Extensions.Diagnostics.HealthChecks`。
2. 存活探针仅反映进程可运行状态，不应依赖慢速外部依赖检查。
3. 就绪探针必须反映关键依赖可用性（如数据库、关键缓存、关键消息链路），使用 `AddDbContextCheck`、`AddRedis` 等内置检查。
4. 非关键可选依赖故障时可继续就绪，但必须有降级标识和告警日志。
5. 探针结果必须可观测：失败原因应写入结构化日志。
6. 配置示例：
   ```csharp
   builder.Services.AddHealthChecks()
       .AddDbContextCheck<AppDbContext>("database", tags: new[] { "ready" })
       .AddRedis(redisConnectionString, "redis", tags: new[] { "ready" });

   app.MapHealthChecks("/healthz", new HealthCheckOptions
   {
       Predicate = _ => false // 存活探针不检查外部依赖
   });
   app.MapHealthChecks("/readyz", new HealthCheckOptions
   {
       Predicate = check => check.Tags.Contains("ready")
   });
   ```

## 服务注册约束
1. 每个基础组件封装为独立的 `IServiceCollection` 扩展方法（如 `AddAppDatabase()`、`AddAppRedis()`），保持注册代码内聚。
2. 禁止在业务代码中直接 `new` 第三方客户端（如 `new RedisConnection()`、`new MinioClient()`），必须通过 DI 注入。
3. 组件日志必须脱敏，禁止打印密钥、令牌、连接串完整内容。

## 目录与职责
1. 基础组件注册扩展方法放在 `Infrastructure` 项目或 `Extensions` 目录，例如：
   - `Extensions/DatabaseExtensions.cs`
   - `Extensions/RedisExtensions.cs`
   - `Extensions/MinioExtensions.cs`
   - `Extensions/JwtExtensions.cs`
   - `Extensions/HealthCheckExtensions.cs`
2. 配置强类型类（Options Pattern）放在对应项目的 `Options` 或 `Configuration` 目录。

## 重点组件规则
1. 数据库/EF Core：`DbContext` 注册为 `Scoped`，连接池由 EF Core 自动管理，显式配置 `CommandTimeout`、`MaxRetryCount`。
2. Redis：使用 `IConnectionMultiplexer`（StackExchange.Redis）注册为 `Singleton`，必须配置超时、重试和连接池。
3. MinIO/对象存储：客户端注册为 `Singleton`，必须显式配置 endpoint、bucket、TLS 策略与超时。
4. JWT：配置必须通过 Options Pattern 管理，显式配置签名算法、密钥来源、过期策略，禁止硬编码密钥。
5. 日志：使用 `ILogger<T>` 注入，日志框架（Serilog / NLog）在 `Program.cs` 最早阶段配置，保证后续组件初始化失败可被记录。

## 可测试性要求
1. 使用方依赖接口而非具体实现类型，便于注入 mock 或 fake。
2. 服务注册必须可在测试中替换（通过 `WebApplicationFactory.ConfigureServices`）。
3. 禁止在测试中依赖静态可变状态。

## 禁止事项
1. 禁止使用静态类/静态属性持有数据库连接、Redis 连接等有状态组件实例。
2. 禁止在 Controller/Service 中直接构造基础组件客户端（`new DbContext()`、`new RedisConnection()`）。
3. 禁止使用 Service Locator 模式（直接调用 `IServiceProvider.GetService`）替代构造函数注入（`IServiceScopeFactory` 等框架级用法除外）。
