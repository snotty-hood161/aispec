# rules/python-server/profiles/microservice/messaging.md

## 文档目标
1. 定义微服务间异步通信、消息队列、幂等消费、死信处理的约束。

---

## 消息队列选型（MUST）

1. 项目必须选定唯一的消息队列方案（RabbitMQ / Kafka / RocketMQ / NATS / Redis Streams），禁止混用。
2. 选型必须在架构设计阶段确定并记录。
3. Celery 默认使用 RabbitMQ 或 Redis 作为 Broker，MUST 在配置中显式指定。

| Broker | 适用场景 | Python 客户端 |
|--------|---------|-------------|
| **RabbitMQ** | 通用异步消息、任务队列 | `pika` / `aio-pika` / Celery |
| **Kafka** | 高吞吐事件流、日志收集 | `confluent-kafka` / `aiokafka` |
| **Redis** | 轻量级消息、已有 Redis 基础设施 | `redis-py` Streams / Celery |
| **NATS** | 轻量级、低延迟 | `nats-py` |

检查方式：架构评审
阻断级别：阻断合并

---

## 消息契约（MUST）

1. 事件消息必须定义稳定 schema 和版本号，推荐使用 Pydantic model 或 JSON Schema 定义消息结构。
2. 消息体必须包含：消息 ID（唯一）、事件类型、版本号、时间戳、业务 payload。
3. 格式变更必须向后兼容（新增字段可选、不删除字段），破坏性变更升级版本。

### 消息结构示例
```python
from pydantic import BaseModel, Field
from datetime import datetime
import uuid

class EventMessage(BaseModel):
    message_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    event_type: str
    version: str = "1.0"
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    payload: dict

class OrderCreatedEvent(EventMessage):
    event_type: str = "order.created"
    payload: dict  # {"order_id": "...", "user_id": "...", "amount": ...}
```

检查方式：人工审查
阻断级别：阻断合并

---

## 生产者（MUST）

1. 消息发送必须确保至少一次投递（At-Least-Once），关键场景使用 Outbox 模式保证本地事务与消息投递的原子性。
2. 发送失败必须有重试机制和告警，禁止静默丢弃。
3. 消息必须携带幂等键（如业务 ID + 事件类型），便于消费方去重。
4. Celery 任务发送 MUST 使用 `apply_async()` 或 `delay()`，并设置 `task_id` 以支持幂等。

检查方式：代码审查
阻断级别：阻断合并

---

## 消费者（MUST）

1. 消费端必须实现幂等消费，同一消息重复投递不产生副作用。
2. 幂等推荐方案：唯一键约束 / 状态机校验 / 消费记录表。
3. 消费失败分级重试：
   - **即时重试**：暂时性错误，重试 1-3 次。
   - **延迟重试**：依赖未就绪，退避（1s → 5s → 30s）。
   - **死信队列**：超过最大重试后投入死信，人工介入。
4. 死信队列必须配置监控告警，堆积超阈值触发告警。
5. 禁止无限重试，最大重试次数可配置（建议 ≤ 5 次）。
6. Celery 消费者 MUST 配置 `acks_late=True` + `reject_on_worker_lost=True`，确保 Worker 崩溃后消息不丢失。

检查方式：代码审查 + 集成测试（正常消费、重复消费、死信流转）
阻断级别：阻断合并

---

## 消息顺序性（MUST）

1. 默认不保证全局顺序，仅保证分区/队列内有序。
2. 需要顺序消费时，通过分区键（如订单 ID）保证同一业务实体消息路由到同一分区。
3. 顺序消费场景的消费者必须单线程消费同一分区，禁止并行消费破坏顺序。
4. Kafka 场景使用 `aiokafka` 时，MUST 通过 `key` 参数指定分区键。

检查方式：代码审查
阻断级别：阻断合并

---

## 消息追踪（SHOULD）

1. 消息必须携带 `trace_id` 和 `request_id`，确保跨服务链路可追踪。
2. Celery 任务推荐使用 `opentelemetry-instrumentation-celery` 自动注入 trace 上下文。
3. 消息消费日志必须包含 `message_id`、`event_type`、`trace_id`，便于排查。

检查方式：追踪平台审查
阻断级别：告警记录
