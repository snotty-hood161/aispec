# rules/node-server/common/concurrency-and-resource.md

## Event Loop 保护

### MUST
1. 禁止在 Event Loop 中执行 CPU 密集型同步操作（如大数据 JSON 解析、加密计算、图片处理），必须转移到 Worker Threads 或外部服务。
2. 禁止使用 `fs.readFileSync`、`fs.writeFileSync` 等同步 I/O API（启动阶段加载配置文件除外）。
3. Event Loop 延迟必须纳入监控（参见 `common/observability.md`），延迟超过 100ms 触发告警。
4. 长循环（超过 1000 次迭代的数据处理）必须使用 `setImmediate()` 或分批处理，避免阻塞 Event Loop。
5. 正则表达式必须避免灾难性回溯（ReDoS），输入长度超过限制时必须截断。

### SHOULD
1. 推荐使用 `@matteo.collina/physician` 或 `blocked-at` 检测 Event Loop 阻塞。
2. 推荐 CPU 密集型任务使用 `worker_threads` 或 `piscina` 线程池。

检查方式：Event Loop 监控 + 压力测试
阻断级别：阻断合并

---

## Worker Threads 使用规范（MUST）

1. Worker Threads 仅用于 CPU 密集型任务（加密、压缩、数据转换），禁止用于 I/O 操作。
2. Worker 线程池大小必须可配置，默认不超过 `os.cpus().length - 1`。
3. Worker 线程必须设置任务执行超时，超时后终止 Worker 并记录错误日志。
4. Worker 线程与主线程通信必须使用结构化克隆或 SharedArrayBuffer，禁止传递不可序列化对象。
5. Worker 线程错误必须在主线程捕获并处理，禁止未处理的 Worker 崩溃导致进程静默退出。

### SHOULD
1. 推荐使用 `piscina` 管理 Worker 线程池，提供自动排队和负载均衡。
2. 推荐在线程池饱和时返回 `503 Service Unavailable` 而非无限排队。

---

## 数据库连接池（MUST）

1. 数据库连接池大小必须显式配置（不使用默认值），推荐公式：`pool_size = (cpu_cores * 2) + spinning_disks`。
2. 连接池必须配置最小空闲连接数、最大连接数、连接超时和空闲超时。
3. Prisma 项目必须在 `datasource` 中配置 `connection_limit` 参数。
4. TypeORM 项目必须在 `DataSourceOptions` 中配置 `poolSize`、`connectTimeoutMS`。
5. 连接池耗尽时必须有明确的错误提示和降级策略（如排队等待 + 超时），禁止无限阻塞。
6. 应用停机时必须等待活跃查询完成后再关闭连接池。

### SHOULD
1. 推荐监控连接池使用率（活跃连接/最大连接），超过 80% 触发告警。
2. 推荐在连接获取时设置超时（如 5 秒），避免长时间等待。

检查方式：配置审查 + 压力测试
阻断级别：阻断合并

---

## 优雅停机与请求排空

### MUST
1. 收到停止信号（`SIGTERM`、`SIGINT`）后，服务必须先停止接收新请求，再等待在途请求处理完成。
2. NestJS 项目必须启用 `enableShutdownHooks()` 并在 `OnApplicationShutdown` 中执行资源清理。
3. Express/Fastify 项目必须调用 `server.close()` 停止接收新连接，等待在途请求完成。
4. 优雅停机等待超时必须可配置（推荐 15-30 秒），超时后强制退出。
5. 超时强制退出时必须输出告警日志并统计未完成请求数量。
6. 停机阶段必须按逆序关闭资源：HTTP Server → 消息队列消费者 → 定时任务 → 数据库连接 → Redis 连接 → 日志 flush。
7. 写操作在停机阶段必须依赖幂等或事务保障，禁止产生部分提交导致的脏数据。

### SHOULD
1. 推荐在停机阶段将健康检查端点返回 `503`，通知负载均衡器摘除实例。
2. 推荐使用 `@godaddy/terminus` 简化优雅停机流程管理。

检查方式：停机测试 + 压力测试
阻断级别：阻断部署

---

## 异步操作与 Promise 管理

### MUST
1. 所有异步操作必须使用 `async/await`，禁止回调嵌套超过两层（callback hell）。
2. 并发异步操作必须使用 `Promise.all()`（全部成功）或 `Promise.allSettled()`（容忍部分失败），禁止顺序 `await` 无依赖关系的 Promise。
3. 禁止出现 unhandled Promise rejection，进程级必须注册 `process.on('unhandledRejection')` 监听器。
4. 异步操作必须设置超时（推荐使用 `AbortController` + `AbortSignal.timeout()`），禁止无限等待。
5. 流式处理（Stream）必须正确处理 `error` 事件和背压（backpressure），禁止忽略流错误。

### SHOULD
1. 推荐使用 `p-queue`、`p-limit` 等库控制并发数量，避免大量 Promise 同时执行导致资源耗尽。
2. 推荐在重试场景使用指数退避策略（`p-retry`），避免重试风暴。

检查方式：ESLint `no-floating-promises` + 代码审查
阻断级别：阻断合并
