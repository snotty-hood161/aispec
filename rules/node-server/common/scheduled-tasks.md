# rules/node-server/common/scheduled-tasks.md

## 任务队列选型

### MUST
1. 后台任务和异步作业必须使用任务队列（推荐 BullMQ），禁止在请求处理路径中同步执行耗时操作。

| 场景 | 推荐方案 | 说明 |
|------|---------|------|
| 异步任务（邮件、通知、导出） | BullMQ | Redis-backed，支持延迟、重试、优先级 |
| 定时任务（报表、清理、同步） | BullMQ Repeatable / Agenda | Cron 表达式驱动 |
| 分布式任务调度 | BullMQ + 分布式锁 | 多实例环境防重复执行 |

2. NestJS 项目推荐使用 `@nestjs/bullmq`，通过 `@Processor()` 装饰器定义任务处理器。
3. 任务队列客户端必须通过 DI 注入，禁止在业务代码中直接 `new Queue()`。
4. 禁止使用 `setTimeout`/`setInterval` 实现定时任务或延迟队列（进程重启会丢失）。

检查方式：架构评审
阻断级别：阻断合并

---

## 任务定义规范（MUST）

1. 每个任务必须定义唯一的任务名称（`name`），推荐格式 `{模块}.{动作}`（如 `order.sendConfirmation`、`report.generateDaily`）。
2. 任务 payload 必须有完整的 TypeScript 类型定义，禁止使用 `any` 或 `Record<string, unknown>`。
3. 任务 payload 必须仅包含 ID 和关键参数（可序列化数据），禁止传递大对象（如完整实体、文件内容）。
4. 任务处理器必须独立为单独的类/文件（如 `order-notification.processor.ts`），禁止混入 service 逻辑。
5. 任务必须设置超时时间（`timeout`），超时后标记为失败，推荐根据任务类型设置（简单任务 30s，复杂任务 5min）。

### SHOULD
1. 推荐为任务定义优先级（`priority`），确保关键任务优先执行。
2. 推荐在任务 payload 中包含触发来源（`triggeredBy`）和关联 ID（`correlationId`），便于追踪。

检查方式：代码审查
阻断级别：阻断合并

---

## 幂等性保障（MUST）

1. 任务处理器必须实现幂等性，同一任务重复执行不产生副作用。
2. 幂等方案（至少实施一种）：
   - **唯一标识去重**：使用任务 ID 或业务唯一键（如 `orderId + action`）在数据库中记录已处理标识。
   - **状态检查前置**：执行前检查业务状态，已完成则跳过。
   - **乐观锁**：使用版本号或时间戳防止重复写入。
3. BullMQ 配置 `removeOnComplete` 和 `removeOnFail` 时，必须保留足够的历史记录用于排查（推荐保留 1000 条或 7 天）。
4. 禁止在任务处理器中假设"每个任务只会执行一次"。

检查方式：重复执行测试
阻断级别：阻断合并

---

## 重试与失败处理（MUST）

1. 任务必须配置重试策略（`attempts`），推荐重试 3 次，重试间隔使用指数退避（`backoff: { type: 'exponential', delay: 1000 }`）。
2. 达到最大重试次数后，任务必须进入死信队列（Dead Letter Queue）或标记为永久失败。
3. 死信队列中的任务必须有监控告警，超过阈值通知相关人员处理。
4. 任务失败时必须记录完整的错误信息（`failedReason`、`stacktrace`）和任务上下文。
5. 禁止在任务处理器中吞掉异常（空 `catch` 块），失败必须向上抛出由框架处理。

### SHOULD
1. 推荐实现任务处理器的 `onFailed` 回调，在最终失败时执行补偿逻辑（如发送告警、记录失败单据）。
2. 推荐为不同类型的任务配置不同的重试策略（幂等任务多重试，非幂等任务少重试或不重试）。

检查方式：故障注入测试 + 监控告警
阻断级别：阻断合并

---

## 分布式任务调度（MUST）

1. 多实例部署环境下，定时任务必须防止重复执行（同一时刻只有一个实例执行）。
2. 防重复方案推荐：
   - BullMQ Repeatable Job（内建去重，基于 job name + cron + 队列）。
   - Redis 分布式锁（`SET key value NX EX`），执行前获取锁，执行后释放。
3. 分布式锁必须设置超时（防止死锁），推荐锁超时 = 任务预期执行时间 × 2。
4. 禁止使用 `node-cron` 等进程内定时器在多实例环境执行会产生副作用的任务。

### SHOULD
1. 推荐使用 BullMQ 的 `repeat` 配置实现定时任务，替代独立的 cron 调度器。
2. 推荐定时任务执行记录入库，便于审计和排查。

检查方式：多实例部署测试
阻断级别：阻断合并

---

## 任务监控（MUST）

1. 任务队列指标必须纳入 Prometheus 监控：
   - `bullmq_queue_waiting_count`：等待中的任务数
   - `bullmq_queue_active_count`：执行中的任务数
   - `bullmq_queue_failed_count`：失败任务数
   - `bullmq_queue_completed_count`：完成任务数
   - `bullmq_job_duration_seconds`：任务执行耗时
2. 队列积压（waiting > 1000）或失败率异常（> 5%）必须触发告警。
3. 死信队列中有未处理任务必须触发告警。

### SHOULD
1. 推荐使用 Bull Board（`@bull-board/express` 或 `@bull-board/nestjs`）提供任务队列管理 UI。
2. 推荐在管理后台提供任务重试、任务查看功能。

检查方式：监控告警配置审查
阻断级别：告警记录
