# rules/go-server/common/performance.md

## 文档目标
1. 定义 Go 服务端性能约束，涵盖 Profiling、内存、数据库查询、连接池、序列化等维度。
2. 并发控制与优雅停机参见 `common/concurrency-and-resource.md`；指标与追踪参见 `common/observability.md`。
3. 本文件聚焦"如何发现和预防性能问题"，与上述文件互补不重复。

---

## Profiling 与基准测试（MUST）

1. 生产服务必须注册 `net/http/pprof` 端点，绑定在独立的管理端口（非业务端口），并通过鉴权保护。
2. 禁止在业务端口暴露 pprof 端点。
3. 性能敏感模块（序列化、加解密、批量处理、热路径）必须编写 `Benchmark` 测试（`func BenchmarkXxx(b *testing.B)`）。
4. 基准测试结果纳入 PR 评审：涉及热路径变更时，必须附优化前后的 Benchmark 对比。
5. 线上性能排查优先使用 pprof 采样分析（CPU / Heap / Goroutine / Block），禁止在生产代码中插入临时计时逻辑后上线。

### SHOULD
1. CI 中集成基准测试回归检测（如 `benchstat`），关键路径性能劣化超过 10% 触发告警。
2. 定期（每月）对核心服务做 pprof 采样，输出性能趋势报告。

检查方式：代码审查 + CI 基准测试
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 内存管理与 GC 优化（MUST）

1. 热路径中禁止高频创建大对象（> 1KB），必须使用 `sync.Pool` 复用或预分配缓冲区。
2. `sync.Pool` 使用时必须在 `Put` 前重置对象状态，防止脏数据泄漏。
3. 已知大小的 slice/map 必须使用 `make([]T, 0, cap)` / `make(map[K]V, cap)` 预分配容量，禁止依赖自动扩容。
4. 大 slice 截取后若原数组不再使用，必须显式 copy 到新 slice，避免底层数组无法被 GC 回收。
5. `[]byte` 与 `string` 转换频繁的场景，使用 `unsafe` 零拷贝转换或 `strings.Builder`，避免重复分配。
6. 禁止在循环中拼接字符串（`+=`），必须使用 `strings.Builder` 或 `bytes.Buffer`。

### SHOULD
1. 关注 `GOGC` 参数调优：默认 100，高吞吐低延迟场景可适当调高（减少 GC 频率）；内存敏感场景可调低。
2. Go 1.19+ 项目考虑使用 `GOMEMLIMIT` 设置内存软上限，配合容器内存限制使用。
3. 定期通过 `go tool pprof -alloc_space` 分析内存分配热点。

检查方式：pprof 分析 + 代码审查
阻断级别：阻断合并

---

## 数据库查询性能（MUST）

1. 所有查询必须设置超时（通过 `context.WithTimeout`），禁止无超时的数据库操作。
2. 列表查询必须分页，禁止无 `LIMIT` 的 `SELECT`（管理脚本或迁移任务除外，需注释说明）。
3. `WHERE` 条件中参与过滤的字段必须有索引覆盖；新增查询必须附 `EXPLAIN` 结果或索引说明。
4. 禁止 `SELECT *`，必须显式列出需要的字段。
5. N+1 查询必须消除：批量场景使用 `WHERE IN (...)` 或 `JOIN` 替代循环单条查询。
6. 慢查询阈值必须可配置（建议默认 200ms），超出阈值自动记录日志并上报指标。

### SHOULD
1. 读多写少的查询考虑读写分离（读走从库）。
2. 高频查询结果考虑缓存（参见缓存策略相关规范）。
3. 大批量数据操作使用批量插入/更新（`INSERT ... VALUES (...), (...)` 或 ORM 批量接口），禁止逐条操作。

检查方式：慢查询日志 + EXPLAIN 审查 + 代码审查
阻断级别：阻断合并

---

## 连接池与资源池调优（MUST）

1. 数据库连接池必须显式配置：`MaxOpenConns`、`MaxIdleConns`、`ConnMaxLifetime`、`ConnMaxIdleTime`。
2. Redis 连接池必须显式配置：`PoolSize`、`MinIdleConns`、`PoolTimeout`。
3. HTTP 客户端必须复用（全局或按目标域名共享），禁止每次请求创建新的 `http.Client`。
4. HTTP 客户端必须设置 `Timeout`、`Transport.MaxIdleConns`、`Transport.MaxIdleConnsPerHost`、`Transport.IdleConnTimeout`。
5. 所有连接池参数必须通过配置文件管理（参见 `common/configuration.md`），禁止硬编码。
6. 响应体（`resp.Body`）必须 `defer resp.Body.Close()` 且完整读取（`io.ReadAll` 或 `io.Copy(io.Discard, ...)`），防止连接无法复用。

### SHOULD
1. 连接池参数根据实际负载调优，避免过大（浪费资源）或过小（排队等待）。
2. 连接池指标（活跃连接数、等待数、超时数）纳入监控。

检查方式：配置审查 + 代码审查
阻断级别：阻断合并

---

## 序列化与编解码性能（MUST）

1. JSON 序列化热路径推荐使用高性能库（如 `sonic`、`go-json`），或使用 `encoding/json` 配合预编译 `Encoder`。
2. 禁止在热路径中使用 `reflect` 做通用序列化；需要反射的场景必须提前缓存反射结果。
3. Protobuf 优先于 JSON 用于内部服务间通信（RPC/消息），减少序列化开销。
4. 大文件传输使用流式处理（`io.Reader` / `io.Writer`），禁止一次性读入内存。

### SHOULD
1. 响应体较大时考虑 `gzip` 压缩（通过中间件统一处理），减少网络传输开销。
2. 高频使用的数据结构考虑手写 `MarshalJSON` / `UnmarshalJSON` 避免反射开销。

检查方式：Benchmark 测试 + 代码审查
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
2. 版本发布前做压力测试（推荐 `wrk`、`k6`、`vegeta`），对比基线数据。
3. 线上启用性能告警：CPU > 80%、内存 > 80%、goroutine 数突增、GC 停顿 > 10ms。
4. 每季度做一次全量性能巡检，输出优化建议与执行计划。

检查方式：压力测试报告 + 监控告警配置审查
阻断级别：告警记录
