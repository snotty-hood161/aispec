# rules/dotnet-server/common/performance.md

## 文档目标
1. 定义 C#/.NET 服务端性能约束，涵盖 Profiling、内存、数据库查询、连接池、序列化等维度。
2. 异步编程与优雅停机参见 `common/concurrency-and-resource.md`；指标与追踪参见 `common/observability.md`。
3. 本文件聚焦"如何发现和预防性能问题"，与上述文件互补不重复。

---

## Profiling 与基准测试（MUST）

1. 生产服务推荐集成 `dotnet-monitor` 或 `dotnet-trace`，支持运行时性能采集，禁止在生产代码中插入临时计时逻辑后上线。
2. 性能敏感模块（序列化、加解密、批量处理、热路径）必须编写 BenchmarkDotNet 基准测试。
3. 基准测试结果纳入 PR 评审：涉及热路径变更时，必须附优化前后的 Benchmark 对比。
4. 生产环境应启用 EventCounters / Metrics 端点，便于运行时性能观测。

### SHOULD
1. CI 中集成基准测试回归检测，关键路径性能劣化超过 10% 触发告警。
2. 定期（每月）对核心服务做性能采样，输出性能趋势报告。

检查方式：代码审查 + CI 基准测试
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 内存管理与 GC 优化（MUST）

1. 热路径中禁止高频创建大对象（> 85KB 会进入 LOH），必须使用 `ArrayPool<T>` 或 `ObjectPool<T>` 复用。
2. `ArrayPool<T>` 使用时必须在 `Return` 前清理敏感数据（使用 `clearArray: true`）。
3. 已知大小的集合必须预分配容量（`new List<T>(capacity)`、`new Dictionary<K,V>(capacity)`），禁止依赖自动扩容。
4. 大量字符串拼接必须使用 `StringBuilder`，禁止在循环中使用 `+=` 拼接。
5. 热路径推荐使用 `Span<T>` / `Memory<T>` 减少堆分配，使用 `stackalloc` 处理小型临时缓冲区。
6. `IDisposable` 对象必须及时释放，避免非托管资源泄漏。

### SHOULD
1. 关注 Server GC vs Workstation GC 选型：Web 服务推荐 Server GC（`<ServerGarbageCollection>true</ServerGarbageCollection>`）。
2. .NET 8+ 项目考虑使用 `GCConserveMemory` 或调整 `GCHeapHardLimit` 配合容器内存限制。
3. 定期通过 `dotnet-dump` / `dotnet-gcdump` 分析内存分配热点。

检查方式：性能分析 + 代码审查
阻断级别：阻断合并

---

## 数据库查询性能（MUST）

1. 所有查询必须设置超时（通过 `CommandTimeout` 或 `CancellationToken`），禁止无超时的数据库操作。
2. 列表查询必须分页，禁止无 `Take`/`LIMIT` 的查询（管理脚本或迁移任务除外，需注释说明）。
3. `WHERE` 条件中参与过滤的字段必须有索引覆盖；新增查询必须附 `EXPLAIN` 结果或索引说明。
4. 禁止查询整个实体仅使用部分字段（等同于 `SELECT *`），必须使用 `.Select()` 投影。
5. N+1 查询必须消除：使用 `.Include()` / `.ThenInclude()` 预加载，或批量查询替代循环单条查询。
6. 慢查询阈值必须可配置（建议默认 200ms），超出阈值自动记录日志并上报指标（EF Core 可配置 `LogTo` 或拦截器）。

### SHOULD
1. 读多写少的查询考虑读写分离或 `AsNoTracking()` 优化。
2. 高频查询结果考虑缓存（参见缓存策略相关规范）。
3. 大批量数据操作使用批量插入/更新（`EFCore.BulkExtensions` 或 `ExecuteUpdate`），禁止逐条操作。

检查方式：慢查询日志 + EXPLAIN 审查 + 代码审查
阻断级别：阻断合并

---

## 连接池与 HttpClient 调优（MUST）

1. EF Core 推荐使用 `AddDbContextPool<T>` 启用 DbContext 池化，配置 `poolSize` 上限。
2. Redis 连接（StackExchange.Redis）`IConnectionMultiplexer` 必须注册为 Singleton，禁止每次请求创建新连接。
3. `HttpClient` 必须通过 `IHttpClientFactory` 管理，禁止每次请求 `new HttpClient()`。
4. 命名 HttpClient 或类型化 HttpClient 必须配置 `Timeout`、`MaxConnectionsPerServer`。
5. 所有连接池参数必须通过配置文件管理（参见 `common/configuration.md`），禁止硬编码。
6. 响应体（`HttpResponseMessage`）必须释放或完整读取，使用 `using` 确保连接回收。

### SHOULD
1. 连接池参数根据实际负载调优，避免过大（浪费资源）或过小（排队等待）。
2. 连接池指标（活跃连接数、等待数）纳入监控。

检查方式：配置审查 + 代码审查
阻断级别：阻断合并

---

## 序列化与编解码性能（MUST）

1. JSON 序列化推荐使用 `System.Text.Json`（性能优于 Newtonsoft.Json），热路径使用 Source Generator（`[JsonSerializable]`）避免反射。
2. 禁止在热路径中使用反射做通用序列化；需要反射的场景必须提前缓存类型信息。
3. Protobuf 优先于 JSON 用于内部服务间通信（gRPC），减少序列化开销。
4. 大文件传输使用流式处理（`Stream`），禁止一次性读入内存。

### SHOULD
1. 响应体较大时考虑响应压缩（通过 `UseResponseCompression` 中间件），减少网络传输开销。
2. 高频使用的 DTO 考虑使用 `JsonTypeInfo<T>` Source Generator 避免运行时反射。

检查方式：Benchmark 测试 + 代码审查
阻断级别：阻断合并

---

## 接口响应时间约束（MUST）

1. 同步 API 响应时间目标：P95 <= 200ms，P99 <= 500ms。
2. 超过目标值的接口必须记录为慢接口，限时优化。
3. 耗时操作（报表生成、批量导入导出、文件处理）必须异步化，接口立即返回任务 ID，客户端轮询或回调获取结果。
4. 外部依赖调用（第三方 API、支付网关等）必须设置独立超时，禁止使用全局默认超时。

### SHOULD
1. 核心接口设置 SLA 目标并纳入监控告警。
2. 接口响应时间劣化超过 20% 触发告警并限时修复。

检查方式：APM 监控 + 代码审查
阻断级别：阻断合并

---

## 性能防劣化机制（SHOULD）

1. 核心服务维护性能基线文档，记录关键接口的 P95/P99 延迟、QPS 峰值、内存水位。
2. 版本发布前做压力测试（推荐 `k6`、`NBomber`、`wrk`），对比基线数据。
3. 线上启用性能告警：CPU > 80%、内存 > 80%、线程池排队数突增、GC 停顿 > 100ms。
4. 每季度做一次全量性能巡检，输出优化建议与执行计划。

检查方式：压力测试报告 + 监控告警配置审查
阻断级别：告警记录
