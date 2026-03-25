# rules/node-server/common/performance.md

## Event Loop 监控与保护

### MUST
1. 生产环境必须监控 Event Loop 延迟，推荐使用 `prom-client` 内建的 `nodejs_eventloop_lag_seconds` 指标或 `monitorEventLoopDelay` API。
2. Event Loop 延迟持续超过 100ms 必须触发告警，超过 500ms 必须作为 P1 事件处理。
3. 禁止在请求处理路径中执行同步 CPU 密集型操作（JSON.parse 大数据、crypto.pbkdf2Sync 等）。
4. 定时任务和批处理必须在独立进程或 Worker Thread 中执行，不占用主请求处理 Event Loop。
5. Event Loop 利用率必须纳入容量规划，单实例 Event Loop 饱和前必须水平扩展。

### SHOULD
1. 推荐使用 Clinic.js（`clinic doctor`、`clinic flame`）进行性能诊断。
2. 推荐在开发环境使用 `0x` 生成火焰图分析 CPU 热点。

检查方式：监控告警 + 压力测试
阻断级别：告警记录

---

## 内存管理与泄漏检测

### MUST
1. 生产环境必须监控堆内存使用量（`process.memoryUsage()`），堆使用超过 70% 触发告警。
2. 必须设置 `--max-old-space-size`（根据容器内存限制配置，推荐为容器内存的 75%）。
3. 禁止在请求级缓存中无限累积数据，必须设置大小上限和 LRU 淘汰策略。
4. 闭包和事件监听器必须在不再需要时移除，防止内存泄漏。
5. Stream 处理必须正确处理背压和关闭，禁止大文件全量加载到内存。
6. 全局数组、Map、Set 禁止无上限增长，必须有容量限制或定期清理机制。

### SHOULD
1. 推荐使用 `--expose-gc` + `v8.getHeapStatistics()` 在压力测试中检测内存泄漏。
2. 推荐定期（每月）在预发布环境执行长时间压力测试（≥ 1 小时），观察内存增长趋势。
3. 推荐使用 `heapdump` 或 Chrome DevTools 进行堆快照分析。

检查方式：监控告警 + 压力测试
阻断级别：阻断合并（已知泄漏）/ 告警记录（疑似）

---

## 查询与数据库性能

### MUST
1. 慢查询（>1s）必须记录日志，定期分析优化（参见 `common/database-access.md`）。
2. ORM 查询必须避免 N+1 问题，列表接口必须使用 eager loading 或 join 查询。
3. 分页查询必须限制 pageSize 上限，禁止一次返回超过 1000 条记录。
4. 统计和报表查询必须使用数据库聚合函数，禁止全量拉取到应用层聚合。
5. 高频查询必须有缓存策略（参见 `common/caching.md`），避免重复查询数据库。
6. 数据库连接池使用率必须纳入监控，超过 80% 触发告警。

### SHOULD
1. 推荐使用 `EXPLAIN ANALYZE` 分析关键查询执行计划，确保走索引。
2. 推荐读写分离场景使用只读副本分担查询压力。

检查方式：慢查询日志 + APM 监控
阻断级别：告警记录

---

## HTTP 性能优化

### MUST
1. 响应必须启用压缩（`compression` 中间件 或反向代理层 gzip/brotli），减少传输体积。
2. 静态资源必须设置 `Cache-Control` 和 `ETag`，推荐通过 CDN 或反向代理提供。
3. JSON 序列化推荐使用 `fast-json-stringify`（Fastify 内建）提升序列化性能。
4. 大型列表接口推荐支持流式响应（`Transfer-Encoding: chunked`）或分页查询。
5. 长连接（WebSocket/SSE）必须有心跳检测和超时断开机制。

### SHOULD
1. 推荐使用 HTTP/2 提升并发性能（通过反向代理或 Node.js `http2` 模块）。
2. 推荐为高频 API 实现 ETag 条件请求（304 Not Modified），减少数据传输。

---

## Cluster 与水平扩展

### MUST
1. 生产环境推荐使用 `cluster` 模块或 PM2 cluster 模式启动多进程，充分利用多核 CPU。
2. 容器化部署推荐每个容器单进程，通过 K8s HPA 水平扩展，而非容器内多进程。
3. 应用必须是无状态的（Stateless），会话状态存储到 Redis，禁止依赖进程内存存储会话。
4. 文件上传的临时文件必须存储到共享存储（如 MinIO），禁止存储在本地文件系统后假设其他实例可访问。

### SHOULD
1. 推荐设置 CPU/内存基线的自动扩缩容策略（HPA），根据实际负载动态调整实例数。
2. 推荐在负载测试中确定单实例的最大 QPS，作为扩缩容依据。

检查方式：压力测试 + 容量规划
阻断级别：告警记录

---

## 性能基线与压力测试（SHOULD）

1. 上线前必须进行压力测试，确定关键接口的 QPS 上限、P99 延迟和错误率。
2. 推荐使用 `k6`、`autocannon` 或 `Artillery` 进行压力测试。
3. 推荐建立性能基线：P99 延迟 < 500ms、错误率 < 1%、Event Loop 延迟 < 50ms。
4. 推荐在 CI 中集成性能回归测试（如 `autocannon` 基准测试），检测性能退化。
