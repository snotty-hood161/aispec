# rules/java-server/common/performance.md

## 文档目标
1. 定义 Java 服务端性能约束，涵盖 Profiling、JVM 调优、数据库查询、连接池、序列化等维度。
2. 并发控制与优雅停机参见 `common/concurrency-and-resource.md`；指标与追踪参见 `common/observability.md`。
3. 本文件聚焦"如何发现和预防性能问题"，与上述文件互补不重复。

---

## Profiling 与基准测试（MUST）

1. 生产服务必须支持 JMX 远程连接或 JFR（Java Flight Recorder）采样，绑定在管理端口并通过鉴权保护。
2. 禁止在业务端口暴露 JMX 端口。
3. 性能敏感模块（序列化、加解密、批量处理、热路径）推荐编写 JMH（Java Microbenchmark Harness）基准测试。
4. 基准测试结果纳入 PR 评审：涉及热路径变更时，必须附优化前后的 JMH 对比。
5. 线上性能排查优先使用 JFR + JMC（Java Mission Control）或 Arthas，禁止在生产代码中插入临时计时逻辑后上线。

### SHOULD
1. CI 中集成基准测试回归检测，关键路径性能劣化超过 10% 触发告警。
2. 定期（每月）对核心服务做 JFR 采样，输出性能趋势报告。

检查方式：代码审查 + CI 基准测试
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## JVM 调优（MUST）

1. 生产环境 JVM 参数必须显式配置，禁止使用 JVM 默认值：
   - 堆大小：`-Xms` 和 `-Xmx` 设为相同值，避免动态扩缩容开销。
   - GC 策略：JDK 17+ 推荐 G1GC（默认）或 ZGC（低延迟场景）。
   - 元空间：`-XX:MaxMetaspaceSize` 设置上限，防止类加载泄漏。
2. JVM 参数必须通过环境变量或启动脚本配置，禁止硬编码在代码中。
3. 启用 GC 日志（`-Xlog:gc*:file=gc.log:time,uptime,level,tags`），便于分析 GC 行为。
4. 容器化部署时，JVM 必须感知容器内存限制（JDK 10+ 默认支持 `-XX:+UseContainerSupport`），`-Xmx` 建议为容器内存限制的 70%-80%。
5. 禁止在生产环境使用 `-XX:+PrintCompilation`、`-XX:+TraceClassLoading` 等调试参数。

### SHOULD
1. 定期分析 GC 日志，关注 Full GC 频率和停顿时间。
2. 使用 `jstack`/`jmap` 或 Arthas 定期检查线程状态和堆内存分布。
3. OOM 时自动 dump heap：`-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/heapdump.hprof`。

检查方式：JVM 参数审查 + GC 日志分析
阻断级别：阻断合并

---

## 内存管理（MUST）

1. 热路径中禁止高频创建大对象（> 1KB），考虑对象复用或池化。
2. 大集合（List/Map）必须预估大小并使用 `new ArrayList<>(capacity)` / `new HashMap<>(capacity)` 预分配，禁止依赖自动扩容。
3. 禁止在循环中拼接字符串（`+=`），必须使用 `StringBuilder`。
4. 流式处理大数据集时使用 `Stream` 或分批查询，禁止一次性加载全部到内存。
5. 缓存对象引用类型选择正确：强引用、`SoftReference`（缓存）、`WeakReference`（避免内存泄漏）。
6. 使用完的大对象必须及时解引用（赋 `null` 或离开作用域），避免 GC 无法回收。

### SHOULD
1. 定期通过 JFR 或 MAT（Memory Analyzer Tool）分析内存分配热点。
2. 关注对象逃逸分析和标量替换优化，减少不必要的堆分配。

检查方式：代码审查 + JFR 分析
阻断级别：阻断合并

---

## 数据库查询性能（MUST）

1. 所有查询必须设置超时（通过 `spring.jpa.properties.javax.persistence.query.timeout` 或 MyBatis `timeout`），禁止无超时的数据库操作。
2. 列表查询必须分页，禁止无 `LIMIT` 的 `SELECT`（管理脚本或迁移任务除外，需注释说明）。
3. `WHERE` 条件中参与过滤的字段必须有索引覆盖；新增查询必须附 `EXPLAIN` 结果或索引说明。
4. 禁止 `SELECT *`，必须显式列出需要的字段。
5. N+1 查询必须消除：JPA 使用 `@EntityGraph` / `JOIN FETCH`；MyBatis 使用 `<collection>` 嵌套查询或 `JOIN` 语句。
6. 慢查询阈值必须可配置（建议默认 200ms），超出阈值自动记录日志并上报指标。

### SHOULD
1. 读多写少的查询考虑读写分离（读走从库），通过 `@Transactional(readOnly = true)` + 路由数据源实现。
2. 高频查询结果考虑缓存（参见 `common/caching.md`）。
3. 大批量数据操作使用批量插入（JPA `saveAll` + `spring.jpa.properties.hibernate.jdbc.batch_size`；MyBatis 的 `<foreach>`），禁止逐条操作。

检查方式：慢查询日志 + EXPLAIN 审查 + 代码审查
阻断级别：阻断合并

---

## 连接池与资源池调优（MUST）

1. HikariCP 必须显式配置：`maximumPoolSize`、`minimumIdle`、`connectionTimeout`、`idleTimeout`、`maxLifetime`。
2. Redis 连接池（Lettuce）必须显式配置：`max-active`、`max-idle`、`min-idle`。
3. HTTP 客户端（RestTemplate / WebClient）必须复用，禁止每次请求创建新实例。
4. HTTP 客户端必须配置 `connectTimeout`、`readTimeout`，并使用连接池管理连接。
5. 所有连接池参数必须通过配置文件管理（参见 `common/configuration.md`），禁止硬编码。

### SHOULD
1. 连接池参数根据实际负载调优，避免过大（浪费资源）或过小（排队等待）。
2. 连接池指标（活跃连接数、等待数、超时数）纳入 Micrometer 监控。

检查方式：配置审查 + 代码审查
阻断级别：阻断合并

---

## 序列化与编解码性能（MUST）

1. JSON 序列化默认使用 Jackson（Spring Boot 默认集成），热路径可考虑配置 `ObjectMapper` 优化选项（如 `afterburner` 模块）。
2. 禁止在热路径中反复创建 `ObjectMapper` 实例，必须复用（Spring 容器注入或 static final）。
3. Protobuf 优先于 JSON 用于内部服务间通信（gRPC/消息），减少序列化开销。
4. 大文件传输使用流式处理（`InputStream` / `OutputStream` / `StreamingResponseBody`），禁止一次性读入内存。

### SHOULD
1. 响应体较大时考虑 `gzip` 压缩（`server.compression.enabled=true`），减少网络传输开销。
2. 高频使用的 DTO 考虑使用 `@JsonView` 控制序列化字段，避免不必要的数据传输。

检查方式：代码审查 + 性能测试
阻断级别：阻断合并

---

## 接口响应时间约束（MUST）

1. 同步 API 响应时间目标：P95 ≤ 200ms，P99 ≤ 500ms。
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
2. 版本发布前做压力测试（推荐 JMeter、k6、Gatling），对比基线数据。
3. 线上启用性能告警：CPU > 80%、堆内存 > 80%、线程数突增、GC 停顿 > 200ms、Full GC 频率 > 1次/小时。
4. 每季度做一次全量性能巡检，输出优化建议与执行计划。

检查方式：压力测试报告 + 监控告警配置审查
阻断级别：告警记录
