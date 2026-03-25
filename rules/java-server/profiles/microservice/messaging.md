# rules/java-server/profiles/microservice/messaging.md

## 文档目标
1. 定义微服务间异步通信、消息队列、幂等消费、死信处理的约束。

---

## 消息队列选型（MUST）

| 方案 | 适用场景 | Java 生态集成 |
|------|---------|-------------|
| **RabbitMQ** | 业务消息、事件驱动、延迟队列 | `spring-boot-starter-amqp` |
| **Kafka** | 高吞吐日志流、事件溯源、大数据管道 | `spring-kafka` |
| **RocketMQ** | 阿里生态、顺序消息、事务消息 | `rocketmq-spring-boot-starter` |

1. 项目必须选定唯一的消息队列方案，禁止混用（日志采集用 Kafka + 业务消息用 RabbitMQ 的场景除外，需架构评审确认）。
2. 选型必须在架构设计阶段确定并记录。
3. 消息客户端必须通过 Spring Boot Starter 集成，禁止手动管理连接和 Channel。

检查方式：架构评审
阻断级别：阻断合并

---

## 消息契约（MUST）

1. 事件消息必须定义稳定 schema 和版本号，推荐使用 JSON Schema 或 Avro。
2. 消息体必须包含：消息 ID（唯一，如 UUID）、事件类型、版本号、时间戳、业务 payload。
3. 消息事件类统一定义在 `domain/event/` 包下，包含上述必要字段。
4. 格式变更必须向后兼容（新增字段可选、不删除字段），破坏性变更升级版本。
5. 消息序列化推荐使用 Jackson JSON，配置统一的 `ObjectMapper`。

### 消息事件示例

```java
public class OrderCreatedEvent {
    private String messageId;
    private String eventType = "ORDER_CREATED";
    private int version = 1;
    private LocalDateTime timestamp;
    private OrderPayload payload;
}
```

检查方式：人工审查
阻断级别：阻断合并

---

## 生产者（MUST）

1. 消息发送必须确保至少一次投递（At-Least-Once）。
2. RabbitMQ 生产者必须启用 Publisher Confirms（`spring.rabbitmq.publisher-confirm-type=correlated`），确认消息到达 Broker。
3. Kafka 生产者必须配置 `acks=all`（关键场景），确保消息写入所有 ISR 副本。
4. 关键场景使用 Outbox 模式保证本地事务与消息投递的原子性（业务写入和 Outbox 记录在同一 `@Transactional` 中）。
5. 发送失败必须有重试机制和告警，禁止静默丢弃。
6. 消息必须携带幂等键（如业务 ID + 事件类型），便于消费方去重。
7. 消息生产者封装在 `infrastructure/messaging/producer/`，禁止在 Service 中直接使用 `RabbitTemplate` / `KafkaTemplate`。

检查方式：代码审查
阻断级别：阻断合并

---

## 消费者（MUST）

1. 消费端必须实现幂等消费，同一消息重复投递不产生副作用。
2. 幂等推荐方案：唯一键约束（数据库唯一索引）/ 状态机校验 / 消费记录表。
3. RabbitMQ 消费者使用 `@RabbitListener`，Kafka 消费者使用 `@KafkaListener`。
4. 消费者必须配置手动 ACK（Manual Acknowledgement），禁止自动 ACK 导致消息丢失。
5. 消费失败分级重试：
   - **即时重试**：暂时性错误，Spring Retry 重试 1-3 次。
   - **延迟重试**：依赖未就绪，RabbitMQ 使用 TTL + 死信交换实现延迟重试；Kafka 使用 `RetryTopic`。
   - **死信队列**：超过最大重试后投入死信队列（DLQ），人工介入。
6. 死信队列必须配置监控告警，堆积超阈值触发告警。
7. 禁止无限重试，最大重试次数可配置（建议 ≤ 5 次）。
8. 消费者方法中的异常必须捕获并处理，禁止未捕获异常导致消费线程退出。

### RabbitMQ 消费者示例

```java
@RabbitListener(queues = "${mq.order.queue}")
public void handleOrderCreated(OrderCreatedEvent event, Channel channel,
                                @Header(AmqpHeaders.DELIVERY_TAG) long tag) {
    try {
        orderService.processOrderCreated(event);
        channel.basicAck(tag, false);
    } catch (Exception e) {
        log.error("消费失败，messageId={}", event.getMessageId(), e);
        channel.basicNack(tag, false, shouldRequeue(e));
    }
}
```

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## 消息顺序性（MUST）

1. 默认不保证全局顺序，仅保证分区/队列内有序。
2. 需要顺序消费时：
   - RabbitMQ：使用单队列 + 单消费者，或通过 `x-consistent-hash` 交换保证同一业务键路由到同一队列。
   - Kafka：通过 Partition Key（如订单 ID）保证同一业务实体消息路由到同一分区。
3. 顺序消费场景的消费者必须单线程消费同一分区/队列（Kafka `concurrency=1` for ordered partition），禁止并行消费破坏顺序。

检查方式：代码审查
阻断级别：阻断合并

---

## 消息监控（SHOULD）

1. 以下指标纳入 Micrometer 监控：
   - 生产者：发送成功/失败数、发送延迟。
   - 消费者：消费成功/失败数、消费延迟、积压量。
   - 死信队列：堆积消息数。
2. 消息积压超过阈值触发告警。
3. 消费延迟超过 SLA 触发告警。

检查方式：监控平台配置审查
阻断级别：告警记录
