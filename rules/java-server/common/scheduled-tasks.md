# rules/java-server/common/scheduled-tasks.md

## 文档目标
1. 定义定时任务、后台 Worker、批处理作业的约束。
2. 并发与资源控制参见 `common/concurrency-and-resource.md`。

---

## 任务类型（MUST）

| 类型 | 示例 | 推荐方案 |
|------|------|---------|
| **定时任务（Cron）** | 日报生成、数据清理、对账 | `@Scheduled` / Quartz / XXL-Job |
| **延迟任务** | 订单超时关闭、延迟通知 | Redis 延迟队列 / RabbitMQ 延迟交换 / Quartz |
| **后台 Worker** | 消息消费、文件处理、异步导入导出 | `@Async` + 线程池 / 消息消费者 |

1. 任务类型必须明确分类，不同类型使用对应的调度机制。
2. 简单定时任务使用 `@Scheduled`（需在 `@Configuration` 中启用 `@EnableScheduling`）。
3. 复杂调度需求（动态调度、任务编排、失败重试）使用 Quartz 或 XXL-Job。
4. 禁止在业务代码中直接使用 `Timer`、`ScheduledExecutorService` 创建定时任务，必须通过 Spring 管理。

## @Scheduled 规范（MUST）

1. `@Scheduled` 方法必须是 `void` 返回值，无参数。
2. `@Scheduled` 方法禁止抛出未捕获异常（会导致后续执行中断），必须在方法内 try-catch 并记录日志。
3. `@Scheduled` 的 `cron` 表达式或 `fixedRate`/`fixedDelay` 必须通过 `@ConfigurationProperties` 或 `@Value("${...}")` 从配置文件加载，禁止硬编码。
4. 多实例部署时，`@Scheduled` 默认在所有实例执行，必须配合分布式锁保证单实例执行（参见下方分布式锁章节）。
5. `@Scheduled` 线程池必须通过 `SchedulingConfigurer` 配置 `TaskScheduler`，避免使用默认单线程调度器。

检查方式：代码审查
阻断级别：阻断合并

---

## 分布式锁（MUST）

1. 多实例部署的定时任务必须通过分布式锁保证同一时刻只有一个实例执行，禁止重复执行。
2. 分布式锁推荐方案：
   - **Redisson**（推荐）：`RLock` 或 `RScheduledExecutorService`，开箱即用。
   - **ShedLock**：与 `@Scheduled` 无缝集成，支持 Redis / JDBC 存储。
   - **数据库行锁**：简单场景可用 `SELECT ... FOR UPDATE` 实现。
3. 锁必须设置超时时间（`leaseTime`），防止持有者崩溃导致死锁。
4. 锁的唯一标识必须包含任务名 + 调度周期（如 `daily-report:2026-03-16`），防止跨周期误锁。
5. 获取锁失败的实例必须静默跳过并记录 DEBUG 日志，禁止重试抢锁（由下一个调度周期自然重试）。

### ShedLock 集成示例

```java
@Scheduled(cron = "${task.daily-report.cron}")
@SchedulerLock(name = "dailyReportTask", lockAtMostFor = "PT30M", lockAtLeastFor = "PT5M")
public void generateDailyReport() {
    // 任务逻辑
}
```

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## 任务幂等（MUST）

1. 所有任务必须实现幂等性，重复执行不产生副作用。
2. 幂等实现推荐方案：
   - **状态检查**：执行前检查是否已完成（如对账单已生成则跳过）。
   - **唯一键**：写入结果带唯一约束（数据库唯一索引），重复写入自动忽略。
3. 任务执行结果必须持久化记录（任务名、执行时间、状态、耗时、影响行数），便于排查。

检查方式：代码审查
阻断级别：阻断合并

---

## 失败处理与告警（MUST）

1. 任务失败必须记录错误日志（包含任务名、失败原因、影响范围），通过 SLF4J `log.error()` 输出。
2. 任务失败必须触发告警通知，关键任务（对账、清算）必须即时告警。
3. 可重试的任务必须配置重试策略：最大重试次数（建议 ≤ 3）、退避间隔（指数退避）。
4. 超过最大重试次数后标记为失败，等待人工介入，禁止无限重试。
5. 长时间运行的任务必须设置超时（通过 `Future.get(timeout)` 或任务内部超时检查），超时后取消并记录。

检查方式：代码审查 + 监控告警审查
阻断级别：阻断合并

---

## 任务监控（SHOULD）

1. 以下指标纳入 Micrometer 监控：
   - 任务执行次数（成功/失败/跳过）。
   - 任务执行耗时（P95/P99）。
   - 任务队列积压量（Worker 类型）。
2. 任务执行耗时超过基线 2 倍触发告警。
3. 任务长时间未执行（如 cron 任务跳过了预期的执行窗口）触发告警。

检查方式：监控平台配置审查
阻断级别：告警记录
