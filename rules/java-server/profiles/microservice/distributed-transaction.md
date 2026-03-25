# rules/java-server/profiles/microservice/distributed-transaction.md

## 文档目标
1. 定义微服务场景下分布式事务的选型、实施规范和一致性保障约束。
2. 本地事务管理参见 `common/database-access.md`；消息队列参见 `messaging.md`；服务间通信参见 `communication-and-contracts.md`。

---

## 事务模式选型（MUST）

| 模式 | 适用场景 | 一致性 | 复杂度 | Java 生态方案 |
|------|---------|--------|--------|-------------|
| **本地事务** | 单服务单库 | 强一致 | 低 | `@Transactional` |
| **Outbox + 事件驱动** | 跨服务最终一致 | 最终一致 | 中 | 手动实现 / Debezium CDC |
| **Saga** | 跨服务长事务 | 最终一致 | 中高 | 手动编排 / Seata Saga |
| **TCC** | 高频交易、资金相关 | 最终一致 | 高 | Seata TCC / Hmily |
| **2PC/XA** | 强一致需求（谨慎使用） | 强一致 | 高 | Seata AT / Atomikos |

### MUST
1. 跨服务事务禁止使用本地数据库事务（`@Transactional` 无法跨服务生效）。
2. 优先使用最终一致性方案（Outbox / Saga），仅在强一致性场景（金融、支付）考虑 TCC / 2PC。
3. 事务模式选型必须在服务设计阶段确定并记录，禁止开发过程中随意切换。
4. 禁止使用 JTA/XA 分布式事务管理多数据源，除非有明确的性能测试和故障恢复验证。

---

## Outbox 模式（MUST，选用时适用）

1. 业务写入与 Outbox 消息必须在同一本地事务中（`@Transactional`），保证原子性。
2. Outbox 表结构至少包含：`id`、`event_type`、`payload`（JSON）、`status`（PENDING/SENT/FAILED）、`created_at`、`sent_at`。
3. 独立调度器（`@Scheduled` + 分布式锁）轮询 Outbox 表，将 PENDING 消息投递到消息队列。
4. 投递成功后更新 Outbox 记录状态为 SENT，失败后重试（最大重试次数可配置）。
5. 消费方必须实现幂等消费（参见 `messaging.md`），应对 Outbox 重复投递。
6. Outbox 表定期清理已发送记录（建议保留 7 天后归档或删除）。

### Outbox 表设计示例

```sql
CREATE TABLE outbox_event (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_type   VARCHAR(64)  NOT NULL,
    aggregate_id VARCHAR(64)  NOT NULL,
    payload      JSON         NOT NULL,
    status       VARCHAR(16)  NOT NULL DEFAULT 'PENDING',
    retry_count  INT          NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at      DATETIME     NULL,
    INDEX idx_status_created (status, created_at)
);
```

### SHOULD
1. 高吞吐场景推荐使用 Debezium CDC（Change Data Capture）监听 Outbox 表变更，替代轮询，降低延迟。
2. Outbox 调度器指标（投递成功/失败数、延迟）纳入 Micrometer 监控。

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## Saga 模式（MUST，选用时适用）

1. 每个 Saga 参与方必须提供正向操作和补偿操作（Compensating Action）。
2. 补偿操作必须幂等，多次执行不产生副作用。
3. Saga 编排方式选择：
   - **编排式（Choreography）**：通过事件驱动，各参与方监听事件并执行操作。适用于参与方少（≤ 3）的简单流程。
   - **协调式（Orchestration）**：由 Saga 协调器统一编排步骤和补偿。适用于参与方多或流程复杂的场景。推荐使用 Seata Saga 或自建协调器。
4. Saga 必须定义超时策略，超时后触发补偿或人工介入。
5. Saga 执行状态必须持久化（数据库记录每步执行状态），便于故障恢复和排查。
6. 补偿链执行失败时，必须有人工介入机制和告警通知。

### SHOULD
1. Saga 流程可视化：通过状态机图或执行日志展示 Saga 执行进度。
2. Saga 执行指标（成功/失败/补偿/超时数量）纳入监控。

检查方式：架构评审 + 集成测试
阻断级别：阻断合并

---

## TCC 模式（MUST，选用时适用）

1. 每个 TCC 参与方必须实现三个阶段：
   - **Try**：资源预留（如冻结库存、预扣金额）。
   - **Confirm**：确认提交（如扣减库存、扣款）。
   - **Cancel**：取消释放（如解冻库存、退款）。
2. Confirm 和 Cancel 必须幂等，支持重复调用。
3. Try 阶段预留的资源必须设置超时自动释放，防止资源长期冻结。
4. TCC 框架推荐 Seata TCC 或 Hmily，禁止手动实现（复杂度高、易出错）。
5. TCC 的 Try 阶段禁止执行不可逆操作（如发送短信、调用第三方支付），不可逆操作放在 Confirm 阶段。

检查方式：架构评审 + 集成测试
阻断级别：阻断合并

---

## Seata 集成规范（MUST，选用 Seata 时适用）

1. Seata Server（TC）必须高可用部署（至少 2 实例），存储模式推荐 DB 或 Redis。
2. Seata AT 模式使用时，参与方数据库表必须有主键，且 undo_log 表必须存在。
3. Seata 全局事务超时必须显式配置（建议 ≤ 60s），禁止使用默认值。
4. Seata 事务日志（undo_log / branch 记录）定期清理，避免无限增长。
5. Seata 异常（全局事务超时、分支事务回滚失败）必须有告警通知。

### SHOULD
1. Seata AT 模式适用于大部分场景（自动生成回滚 SQL），仅在需要精细控制时使用 TCC 模式。
2. Seata 与 Nacos 集成，通过 Nacos 管理 Seata 配置和注册。

检查方式：Seata 配置审查 + 集成测试
阻断级别：阻断合并

---

## 一致性验证（MUST）

1. 所有分布式事务场景必须编写集成测试，覆盖以下路径：
   - 正常提交路径。
   - 参与方失败触发补偿/回滚路径。
   - 超时触发补偿路径。
   - 网络分区或消息丢失后的最终一致性验证。
2. 生产环境必须有对账机制，定期（每日）检查跨服务数据一致性。
3. 对账发现不一致时必须触发告警，并提供修复工具或人工介入流程。

检查方式：集成测试 + 对账报告
阻断级别：阻断合并
