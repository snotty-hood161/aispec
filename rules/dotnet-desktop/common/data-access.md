# rules/dotnet-desktop/common/data-access.md

## 本地数据库选型

| 方案 | 适用场景 | 推荐 ORM |
|------|---------|---------|
| **SQLite** | 轻量本地存储、离线数据、缓存 | EF Core + `Microsoft.EntityFrameworkCore.Sqlite` |
| **LiteDB** | 嵌入式文档数据库、小型数据集 | LiteDB 原生 API |
| **无数据库** | 简单配置/少量数据 | JSON 文件 + `System.Text.Json` |

### MUST
1. 必须明确数据持久化方案，禁止在项目中混用多种不同的数据持久化策略而无明确分工。
2. 本地数据库文件必须存储在用户数据目录（`Environment.SpecialFolder.LocalApplicationData`），禁止存储在程序安装目录。
3. 数据库连接和操作必须在后台线程执行（async/await），禁止在 UI 线程操作数据库。
4. 数据库操作必须设置超时，防止阻塞。

## 本地数据库规范（MUST）

1. EF Core DbContext 在桌面应用中建议注册为 `Transient` 或使用 `IDbContextFactory<T>` 按需创建，避免长生命周期 DbContext 导致的内存膨胀。
2. 数据库结构变更必须使用 EF Core Migrations，应用启动时自动执行迁移。
3. 本地数据库必须处理并发访问（SQLite 使用 WAL 模式）：
   ```csharp
   options.UseSqlite(connectionString, opt =>
   {
       opt.CommandTimeout(10);
   });
   // 启动后执行：PRAGMA journal_mode=WAL;
   ```
4. 批量操作必须限制单批大小，避免 SQLite 锁等待。

## 远程 API 调用（MUST）

1. 远程 API 调用必须通过 `IHttpClientFactory` 管理 `HttpClient`，禁止每次请求 `new HttpClient()`。
2. API 客户端必须封装在独立的 Service/Client 类中，ViewModel 禁止直接使用 `HttpClient`。
3. 所有 API 调用必须设置超时（建议 <= 30s），禁止无超时的网络请求。
4. 必须配置重试和熔断策略（推荐 Polly）：
   - 网络瞬时错误自动重试（最多 3 次，指数退避）。
   - 连续失败后熔断（快速失败，避免用户持续等待）。
5. API 调用失败时必须提供明确的用户反馈（网络错误、超时、服务端错误分别提示）。
6. 认证令牌（JWT / API Key）管理通过 `DelegatingHandler` 统一注入，禁止在每次请求中手动添加。

### API 客户端配置示例
```csharp
services.AddHttpClient<IApiClient, ApiClient>(client =>
{
    client.BaseAddress = new Uri(config["Api:BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(30);
})
.AddHttpMessageHandler<AuthTokenHandler>()
.AddTransientHttpErrorPolicy(policy =>
    policy.WaitAndRetryAsync(3, retryAttempt =>
        TimeSpan.FromSeconds(Math.Pow(2, retryAttempt))))
.AddTransientHttpErrorPolicy(policy =>
    policy.CircuitBreakerAsync(5, TimeSpan.FromSeconds(30)));
```

## 离线支持（SHOULD）

1. 需要离线功能的应用必须实现本地优先策略：优先读写本地数据库，网络可用时同步到服务端。
2. 离线操作队列：断网期间的写操作缓存到本地队列，恢复网络后按序重放。
3. 冲突处理策略必须明确：最后写入胜出（Last Write Wins）/ 手动冲突解决 / 服务端仲裁。
4. 网络状态变化必须通知 UI 层（显示在线/离线状态指示）。

检查方式：代码审查
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

## 文件读写（MUST）

1. 文件读写必须使用异步方法（`File.ReadAllTextAsync` / `StreamReader.ReadToEndAsync`），禁止在 UI 线程同步读写文件。
2. 文件路径必须使用 `Path.Combine` 拼接，禁止手动拼接路径字符串。
3. 用户数据文件必须存储在 `LocalApplicationData` 或 `MyDocuments`，禁止写入程序安装目录。
4. 临时文件使用 `Path.GetTempPath()` + 唯一文件名，使用完毕必须清理。
5. 文件操作必须处理 `IOException`（文件被占用、磁盘满等），向用户展示可操作的错误提示。
