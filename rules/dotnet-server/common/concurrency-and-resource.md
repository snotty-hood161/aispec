# rules/dotnet-server/common/concurrency-and-resource.md

## 异步编程
1. 所有 I/O 操作必须使用 `async/await`，禁止在异步上下文中使用 `.Result`、`.Wait()`、`.GetAwaiter().GetResult()` 阻塞调用（死锁风险）。
2. 异步方法必须贯穿全链路传递 `CancellationToken`，从 Controller 到 Repository 每一层都必须接受并传递。
3. 不需要捕获同步上下文的场景，使用 `ConfigureAwait(false)`（类库项目中推荐）；ASP.NET Core 应用层通常无需。
4. 禁止使用 `async void`，除非是事件处理器（event handler）。所有异步方法必须返回 `Task` 或 `ValueTask`。
5. `Task.Run` 仅用于将 CPU 密集型工作卸载到线程池，禁止用于包装 I/O 操作。

## 并发控制
1. 启动后台线程/任务必须可控：有取消条件（`CancellationToken`）、有超时、有错误回传。
2. `Channel<T>` 是推荐的生产者-消费者模式实现，禁止使用无限容量的 `Channel` 而不设背压。
3. 并发写共享状态必须使用明确同步机制（`lock`、`SemaphoreSlim`、`ConcurrentDictionary`），禁止依赖隐式顺序。
4. 避免使用 `lock` 包裹 `await` 调用（会阻塞线程池），应使用 `SemaphoreSlim` 作为异步锁。
5. 线程池配置不可随意调整（`ThreadPool.SetMinThreads`），如需调整必须经评审。

## 资源生命周期
1. 所有 I/O 操作必须设置超时（DB、HTTP、RPC、消息中间件），使用 `CancellationTokenSource` 配合 `CancelAfter`。
2. 长耗时任务必须支持取消（`CancellationToken`）和优雅退出。
3. 实现 `IDisposable` / `IAsyncDisposable` 的对象必须在使用完毕后释放，优先使用 `using` / `await using` 语句。
4. `HttpClient` 必须通过 `IHttpClientFactory` 创建和管理，禁止每次请求 `new HttpClient()`（Socket 泄漏、DNS 缓存问题）。

## 优雅停机与请求排空
1. 收到停止信号后，服务必须先停止接收新请求，再等待在途请求处理完成。
2. 使用 `IHostApplicationLifetime` 注册停机回调，确保后台任务和 `IHostedService` 有序关闭。
3. 优雅停机等待超时必须可配置（`HostOptions.ShutdownTimeout`），并记录停机阶段日志。
4. 超时后允许强制退出，但必须输出告警日志并统计未完成请求数量。
5. 写操作在停机阶段必须依赖幂等或事务保障，禁止产生部分提交导致的脏数据。
6. 配置示例：
   ```csharp
   builder.Services.Configure<HostOptions>(options =>
   {
       options.ShutdownTimeout = TimeSpan.FromSeconds(30);
   });
   ```
