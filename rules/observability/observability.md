# 监控与可观测性规范

## Skill 协作
1. DevOps 任务优先使用 `$devops-engineer`，自动加载本规则。
2. 各域 coding-guide 中的 observability.md 为域内可观测性细则，本文件为跨域可观测性基线。
3. 跨域业务任务使用 `$task-router` 自动路由。

## 可观测性三支柱

```
可观测性体系
├── Metrics（指标） — 量化系统状态
├── Logging（日志） — 记录离散事件
└── Tracing（链路追踪） — 追踪请求全链路
```

## 指标监控（Metrics）

### 指标分层（MUST）

| 层级 | 指标类别 | 示例 | 采集频率 |
|------|---------|------|---------|
| 基础设施 | CPU / 内存 / 磁盘 / 网络 | `node_cpu_usage_percent` | 15s |
| 运行时 | GC / 线程 / 连接池 / goroutine | `go_goroutines_count` | 15s |
| 应用 | QPS / 延迟 / 错误率 / 队列深度 | `http_request_duration_seconds` | 15s |
| 业务 | 注册量 / 订单量 / 支付成功率 | `order_created_total` | 60s |

### 指标命名规范（MUST）
1. 使用小写字母和下划线：`http_requests_total`。
2. 包含度量单位后缀：`_seconds`、`_bytes`、`_total`。
3. 使用标准前缀区分来源：`app_`（应用）、`biz_`（业务）、`infra_`（基础设施）。
4. 计数器使用 `_total` 后缀，直方图使用 `_bucket` / `_sum` / `_count`。

### 黄金指标（MUST）
每个服务必须暴露以下四个黄金指标：

| 指标 | 含义 | 告警阈值建议 |
|------|------|------------|
| 延迟（Latency） | 请求处理时间（P50 / P95 / P99） | P99 > SLA 目标的 2 倍 |
| 流量（Traffic） | 每秒请求数 | 突增 > 基线的 3 倍 |
| 错误率（Errors） | 错误请求占比 | > 1% 持续 5 分钟 |
| 饱和度（Saturation） | 资源使用率 | CPU/内存 > 80% |

## 日志管理（Logging）

### 日志格式（MUST）
所有服务必须使用结构化 JSON 日志格式：

```json
{
  "timestamp": "2026-03-24T10:30:00.000Z",
  "level": "error",
  "service": "order-service",
  "trace_id": "abc123def456",
  "span_id": "789ghi",
  "caller": "handler/order.go:42",
  "message": "failed to create order",
  "error": "duplicate key constraint",
  "context": {
    "user_id": "u_123",
    "order_id": "o_456"
  }
}
```

### 日志级别（MUST）

| 级别 | 用途 | 生产环境 |
|------|------|---------|
| ERROR | 需要立即关注的错误 | 始终启用 |
| WARN | 潜在问题，不影响主流程 | 始终启用 |
| INFO | 关键业务事件和状态变更 | 始终启用 |
| DEBUG | 调试信息 | 仅调试时开启 |
| TRACE | 详细追踪信息 | 仅排查特定问题时开启 |

### 日志规范（MUST）
1. 生产环境默认日志级别：INFO。
2. 禁止在日志中打印敏感信息（密码、Token、身份证号、银行卡号）。
3. 错误日志必须包含上下文信息（请求 ID、用户 ID、操作类型）。
4. 日志必须包含 trace_id，支持跨服务日志关联。
5. 日志保留策略：在线 ≥ 30 天，归档 ≥ 180 天。

## 链路追踪（Tracing）

### 接入规范（MUST）
1. 所有服务必须接入 OpenTelemetry SDK（或兼容的追踪 SDK）。
2. 每个入口请求必须生成 trace_id，跨服务调用传播 trace_id。
3. 关键操作必须创建 span：HTTP 请求、数据库查询、缓存操作、消息队列、外部 API 调用。

### Span 命名规范（MUST）
1. HTTP 请求：`HTTP {METHOD} {ROUTE}`，如 `HTTP GET /api/orders/:id`。
2. 数据库：`DB {OPERATION} {TABLE}`，如 `DB SELECT orders`。
3. 缓存：`CACHE {OPERATION} {KEY_PREFIX}`，如 `CACHE GET user:`。
4. 消息队列：`MQ {OPERATION} {TOPIC}`，如 `MQ PUBLISH order.created`。

### Span 属性（SHOULD）
- HTTP：status_code、method、url、user_agent。
- DB：db.system、db.statement（脱敏）、db.operation。
- 业务：user_id、tenant_id、request_id。

## 告警规则

### 告警分级（MUST）

| 级别 | 场景 | 响应时间 | 通知方式 |
|------|------|---------|---------|
| P0 — 致命 | 服务宕机、数据丢失、安全事件 | 5 分钟 | 电话 + 短信 + IM |
| P1 — 严重 | 错误率 > SLA、延迟 > SLA、核心功能异常 | 15 分钟 | 短信 + IM |
| P2 — 警告 | 资源使用 > 80%、非核心功能异常 | 工作时间内 | IM |
| P3 — 通知 | 资源使用 > 60%、性能趋势劣化 | 下次迭代 | 邮件 / IM |

### 告警抑制（SHOULD）
1. 同一告警 5 分钟内不重复发送（去抖动）。
2. 关联告警聚合：同一根因的多个告警合并通知。
3. 维护窗口期静默：发布/维护期间暂停非 P0 告警。

## SLO / SLI 定义模板（SHOULD）

```
## 服务 SLO 定义

### 服务名称：{service-name}

### SLI 指标
| SLI | 定义 | 计算方式 |
|-----|------|---------|
| 可用性 | 成功请求 / 总请求 | status != 5xx |
| 延迟 | P95 请求延迟 | histogram_quantile(0.95) |
| 正确性 | 正确响应 / 总响应 | 业务逻辑校验 |

### SLO 目标
| SLI | SLO 目标 | 窗口 | 错误预算 |
|-----|---------|------|---------|
| 可用性 | 99.9% | 30 天滚动 | 43.2 分钟/月 |
| 延迟 P95 | < 200ms | 30 天滚动 | — |

### 错误预算策略
- 预算剩余 > 50%：正常发布节奏。
- 预算剩余 25%~50%：减少发布频率，增加测试覆盖。
- 预算剩余 < 25%：冻结非关键发布，集中修复稳定性问题。
```

## 仪表盘规范（SHOULD）

### 必备仪表盘
1. **服务概览**：黄金指标 + 实例数 + 版本 + 最近部署。
2. **错误详情**：错误分类 + 趋势 + Top 5 错误 + 影响范围。
3. **依赖健康度**：数据库 / 缓存 / 消息队列 / 外部 API 的延迟和错误率。
4. **业务看板**：核心业务指标的实时数据和趋势。
