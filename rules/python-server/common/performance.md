# rules/python-server/common/performance.md

## 文档目标
1. 定义 Python 服务端性能约束，涵盖 Profiling、异步优化、数据库查询、连接池、序列化等维度。
2. 并发控制与优雅停机参见 `common/concurrency-and-resource.md`；指标与追踪参见 `common/observability.md`。
3. 本文件聚焦"如何发现和预防性能问题"，与上述文件互补不重复。

---

## Profiling 与基准测试（MUST）

1. 生产服务 MUST 支持按需开启 Profiling，推荐集成 `py-spy`（采样分析）或 `yappi`（线程/协程分析）。
2. 禁止在生产代码中嵌入 `cProfile` 或 `profile` 模块的常驻调用，仅允许临时诊断。
3. 性能敏感模块（序列化、加解密、批量处理、热路径）SHOULD 编写基准测试（推荐 `pytest-benchmark`）。
4. 基准测试结果纳入 PR 评审：涉及热路径变更时，SHOULD 附优化前后的基准对比。
5. 线上性能排查优先使用 `py-spy` 采样分析（CPU / Wall-time），禁止在生产代码中插入临时计时逻辑后上线。

### SHOULD
1. CI 中集成基准测试回归检测，关键路径性能劣化超过 10% 触发告警。
2. 定期（每月）对核心服务做 Profiling 采样，输出性能趋势报告。

检查方式：代码审查 + CI 基准测试
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 异步性能优化（MUST）

1. FastAPI 异步路由中，禁止调用同步阻塞函数（文件 I/O、`requests.get()`、`time.sleep()`），MUST 使用异步替代方案。
2. 异步 HTTP 客户端 MUST 使用 `httpx.AsyncClient`（推荐）或 `aiohttp`，禁止使用 `requests`。
3. `httpx.AsyncClient` MUST 复用（应用级别创建一个实例），禁止每次请求新建客户端。
4. I/O 密集型并发任务 MUST 使用 `asyncio.gather()` / `TaskGroup` 并行执行，禁止串行等待。
5. 异步代码中禁止使用 `sync_to_async` 包装大量同步代码作为常规方案，仅允许作为遗留代码过渡。

### SHOULD
1. 异步路由中的 CPU 密集操作 SHOULD 使用 `asyncio.to_thread()` 或 `ProcessPoolExecutor` 卸载。

检查方式：代码审查 + 性能测试
阻断级别：阻断合并

---

## 数据库查询性能（MUST）

1. 所有查询必须设置超时，禁止无超时的数据库操作。
2. 列表查询必须分页，禁止无 `LIMIT` 的 `SELECT`（管理脚本或迁移任务除外，需注释说明）。
3. `WHERE` 条件中参与过滤的字段必须有索引覆盖；新增查询必须附 `EXPLAIN` 结果或索引说明。
4. 禁止 `SELECT *`，必须使用 `load_only()` 或显式 `select()` 列出需要的字段。
5. N+1 查询必须消除：使用 `selectinload()` / `joinedload()` 或 `WHERE IN (...)` 替代循环单条查询。
6. 慢查询阈值必须可配置（建议默认 200ms），超出阈值自动记录日志并上报指标。
7. SQLAlchemy 项目 SHOULD 启用 SQL 日志（`echo=True` 仅限开发环境），定期审查生成的 SQL。

### SHOULD
1. 读多写少的查询考虑读写分离（读走从库）。
2. 高频查询结果考虑缓存（参见 `common/caching.md`）。
3. 大批量数据操作使用 `session.execute(insert(Model).values(batch))` 批量接口，禁止逐条操作。

检查方式：慢查询日志 + EXPLAIN 审查 + 代码审查
阻断级别：阻断合并

---

## 连接池与资源池调优（MUST）

1. SQLAlchemy 连接池必须显式配置：`pool_size`、`max_overflow`、`pool_timeout`、`pool_recycle`。
2. Redis 连接池必须显式配置：`max_connections`、`socket_timeout`、`socket_connect_timeout`。
3. HTTP 客户端（`httpx.AsyncClient`）必须复用，禁止每次请求创建新实例。
4. HTTP 客户端必须设置 `timeout`（含 `connect`、`read`、`write`、`pool` 超时）。
5. 所有连接池参数必须通过配置文件管理（参见 `common/configuration.md`），禁止硬编码。

### SHOULD
1. 连接池参数根据实际负载调优，避免过大（浪费资源）或过小（排队等待）。
2. 连接池指标（活跃连接数、等待数、超时数）纳入监控。

检查方式：配置审查 + 代码审查
阻断级别：阻断合并

---

## 序列化与编解码性能（MUST）

1. JSON 序列化热路径推荐使用高性能库（如 `orjson` 或 `ujson`），FastAPI 可通过 `ORJSONResponse` 替代默认序列化。
2. Pydantic v2 默认使用 Rust 核心（`pydantic-core`），MUST 使用 Pydantic v2 获取性能提升。
3. 大文件处理使用流式处理（`StreamingResponse` / 生成器），禁止一次性读入内存。
4. Protobuf 优先于 JSON 用于内部服务间通信（RPC/消息），减少序列化开销。

### SHOULD
1. 响应体较大时考虑 `gzip` 压缩（通过中间件统一处理），推荐 `GZipMiddleware`。

检查方式：基准测试 + 代码审查
阻断级别：阻断合并

---

## 接口响应时间约束（MUST）

1. 同步 API 响应时间目标：P95 ≤ 200ms，P99 ≤ 500ms。
2. 超过目标值的接口必须记录为慢接口，限时优化。
3. 耗时操作（报表生成、批量导入导出、文件处理）必须异步化（Celery 任务），接口立即返回任务 ID，客户端轮询或回调获取结果。
4. 外部依赖调用（第三方 API、支付网关等）必须设置独立超时，禁止使用全局默认超时。

### SHOULD
1. 核心接口设置 SLA 目标并纳入监控告警。
2. 接口响应时间劣化超过 20% 触发告警并限时修复。

检查方式：APM 监控 + 代码审查
阻断级别：阻断合并

---

## 性能防劣化机制（SHOULD）

1. 核心服务维护性能基线文档，记录关键接口的 P95/P99 延迟、QPS 峰值、内存水位。
2. 版本发布前做压力测试（推荐 `locust`、`k6`、`wrk`），对比基线数据。
3. 线上启用性能告警：CPU > 80%、内存 > 80%、Worker 进程数不足、数据库连接池耗尽。
4. 每季度做一次全量性能巡检，输出优化建议与执行计划。

检查方式：压力测试报告 + 监控告警配置审查
阻断级别：告警记录
