# rules/java-server/common/concurrency-and-resource.md

## 线程池管理

### MUST
1. 禁止使用 `Executors.newFixedThreadPool()` / `Executors.newCachedThreadPool()` 等工厂方法创建线程池（无界队列或无界线程数可导致 OOM）。
2. 必须使用 `ThreadPoolTaskExecutor`（Spring）或 `ThreadPoolExecutor`（JDK）显式配置核心参数：`corePoolSize`、`maxPoolSize`、`queueCapacity`、`keepAliveSeconds`。
3. 线程池必须通过 Spring Bean（`@Bean`）统一管理，禁止在业务代码中直接 `new ThreadPoolExecutor()`。
4. 线程池必须配置有意义的 `threadNamePrefix`，便于日志和线程 dump 排查（如 `order-async-`）。
5. 线程池拒绝策略必须显式配置（推荐 `CallerRunsPolicy` 或自定义策略记录日志），禁止使用默认 `AbortPolicy` 静默丢弃。
6. `@Async` 必须指定线程池名称（`@Async("orderAsyncExecutor")`），禁止使用默认 `SimpleAsyncTaskExecutor`（每次创建新线程）。

### SHOULD
1. 线程池参数通过配置文件管理（参见 `common/configuration.md`），支持运行时调优。
2. 线程池指标（活跃线程数、队列大小、拒绝次数）纳入 Micrometer 监控。

## 异步处理（MUST）

1. `@Async` 方法必须在 `@Configuration` 类中启用 `@EnableAsync`。
2. `@Async` 方法的返回值必须是 `void`、`Future<T>` 或 `CompletableFuture<T>`，调用方必须处理异常（通过 `AsyncUncaughtExceptionHandler` 或 `CompletableFuture.exceptionally()`）。
3. `@Async` 方法禁止在同一个类内部调用（Spring AOP 代理限制），必须跨 Bean 调用。
4. 异步任务必须设置超时控制，避免无限等待。
5. 异步任务中的 MDC 上下文（`requestId`、`traceId`）必须显式传递，推荐通过 `TaskDecorator` 实现。

## 并发安全（MUST）

1. 共享可变状态必须使用明确同步机制（`synchronized`、`ReentrantLock`、`AtomicXxx`、`ConcurrentHashMap`），禁止依赖隐式顺序。
2. `@Service` / `@Component` 默认是单例 Bean，禁止在其中定义可变实例变量作为共享状态。
3. 使用 `ConcurrentHashMap` 时，复合操作必须使用 `computeIfAbsent` / `merge` 等原子方法，禁止先 `get` 再 `put`。
4. 禁止使用 `Double-Checked Locking` 而不配合 `volatile` 关键字。
5. 数据库并发操作必须使用乐观锁（`@Version`）或悲观锁（`SELECT ... FOR UPDATE`），禁止依赖应用层内存锁。

## 数据库连接池（MUST）

1. 默认使用 HikariCP（Spring Boot 默认集成），禁止使用 Druid 等非标准连接池除非有明确理由。
2. HikariCP 必须显式配置：`maximumPoolSize`、`minimumIdle`、`connectionTimeout`、`idleTimeout`、`maxLifetime`。
3. 连接池参数必须通过配置文件管理，禁止硬编码。
4. 必须配置连接有效性检测（HikariCP 默认启用 `connectionTestQuery` 或 JDBC4 `isValid()`）。
5. 生产环境 `maximumPoolSize` 建议 10-30，根据实际并发量调优，禁止设置超过 100。

## HTTP 客户端（MUST）

1. `RestTemplate` / `WebClient` 必须通过 Spring Bean 创建并复用，禁止每次请求创建新实例。
2. HTTP 客户端必须配置连接超时（`connectTimeout`）和读超时（`readTimeout`），禁止无超时调用。
3. 使用连接池管理 HTTP 连接（如 Apache HttpClient 的 `PoolingHttpClientConnectionManager`），配置最大连接数和每路由最大连接数。
4. 响应体必须完整读取并关闭，防止连接泄漏。

## 资源生命周期（MUST）

1. 所有 I/O 操作必须设置超时（数据库、HTTP、RPC、消息中间件）。
2. 实现 `Closeable` / `AutoCloseable` 的资源必须使用 try-with-resources 自动关闭。
3. 长耗时任务必须支持取消（通过 `Future.cancel()` 或中断机制）和优雅退出。
4. 连接池、消费者、Worker 在关闭流程中必须按顺序释放并等待完成。

## 优雅停机与请求排空

### MUST
1. `application.yml` 必须配置 `server.shutdown=graceful`，收到停止信号后先停止接收新请求，再等待在途请求处理完成。
2. 优雅停机超时必须配置 `spring.lifecycle.timeout-per-shutdown-phase`（建议 30s），超时后强制退出。
3. 超时后允许强制退出，但必须输出告警日志并统计未完成请求数量。
4. 消息消费者在停机阶段必须停止拉取新消息，等待当前消息处理完成后注销。
5. 定时任务在停机阶段必须等待当前执行周期完成，禁止中途中断。
6. 写操作在停机阶段必须依赖幂等或事务保障，禁止产生部分提交导致的脏数据。

### SHOULD
1. 配置 `@PreDestroy` 方法记录优雅停机日志，输出关闭阶段状态。
2. 使用 `SmartLifecycle` 接口精确控制多组件的关闭顺序和超时。
