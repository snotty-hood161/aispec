# rules/dotnet-server/common/scheduled-tasks.md

## 文档目标
1. 定义后台任务、定时作业、批处理作业的约束。
2. 异步编程与资源控制参见 `common/concurrency-and-resource.md`。

---

## 任务类型（MUST）

| 类型 | 示例 | 推荐方案 |
|------|------|---------|
| **后台托管服务** | 消息消费、长轮询、持续运行的 Worker | `IHostedService` / `BackgroundService` |
| **定时任务（Cron）** | 日报生成、数据清理、对账 | Hangfire / Quartz.NET |
| **延迟任务** | 订单超时关闭、延迟通知 | Hangfire `Schedule` / 消息队列延迟消费 |
| **短期后台任务** | 发送邮件、异步通知 | `IHostedService` + `Channel<T>` 队列 |

1. 任务类型必须明确分类，不同类型使用对应的调度机制。
2. 所有后台任务必须注册到 DI 容器（`IHostedService`），禁止在业务代码中使用 `Task.Run` 启动火 forget 后台任务。
3. 禁止使用 `Timer` / `System.Timers.Timer` 手动实现定时逻辑，必须使用 `BackgroundService` 或专业调度框架。

检查方式：代码审查
阻断级别：阻断合并

---

## BackgroundService 规范（MUST）

1. 继承 `BackgroundService` 实现 `ExecuteAsync`，必须监听 `CancellationToken`，收到取消信号后有序退出。
2. `ExecuteAsync` 中的异常必须捕获并记录日志，禁止未处理异常导致整个宿主进程崩溃。
3. 循环任务中必须包含延迟（`await Task.Delay`），禁止空转消耗 CPU。
4. 示例：
   ```csharp
   protected override async Task ExecuteAsync(CancellationToken stoppingToken)
   {
       while (!stoppingToken.IsCancellationRequested)
       {
           try
           {
               await ProcessPendingTasksAsync(stoppingToken);
           }
           catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
           {
               // 正常停机，忽略
           }
           catch (Exception ex)
           {
               _logger.LogError(ex, "后台任务执行失败");
           }

           await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
       }
   }
   ```

检查方式：代码审查
阻断级别：阻断合并

---

## 分布式锁（MUST）

1. 多实例部署的定时任务必须通过分布式锁保证同一时刻只有一个实例执行，禁止重复执行。
2. 分布式锁推荐方案：Redis 锁（RedLock.net）/ 数据库行锁 / Hangfire 内置调度保证。
3. 锁必须设置超时时间，防止持有者崩溃导致死锁。
4. 锁的唯一标识必须包含任务名 + 调度周期（如 `daily-report:2026-03-16`），防止跨周期误锁。
5. 获取锁失败的实例必须静默跳过，禁止重试抢锁（由下一个调度周期自然重试）。

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## 任务幂等（MUST）

1. 所有任务必须实现幂等性，重复执行不产生副作用。
2. 幂等实现推荐方案：
   - **状态检查**：执行前检查是否已完成（如对账单已生成则跳过）。
   - **唯一键**：写入结果带唯一约束，重复写入自动忽略。
3. 任务执行结果必须持久化记录（任务名、执行时间、状态、耗时、影响行数），便于排查。

检查方式：代码审查
阻断级别：阻断合并

---

## 失败处理与告警（MUST）

1. 任务失败必须记录错误日志，包含任务名、失败原因、影响范围。
2. 任务失败必须触发告警通知，关键任务（对账、清算）必须即时告警。
3. 可重试的任务必须配置重试策略：最大重试次数（建议 <= 3）、退避间隔（推荐 Polly 库）。
4. 超过最大重试次数后标记为失败，等待人工介入，禁止无限重试。
5. 长时间运行的任务必须设置超时（通过 `CancellationTokenSource.CancelAfter`），超时后取消并记录。

检查方式：代码审查 + 监控告警审查
阻断级别：阻断合并

---

## 任务监控（SHOULD）

1. 以下指标纳入监控：
   - 任务执行次数（成功/失败/跳过）。
   - 任务执行耗时（P95/P99）。
   - 任务队列积压量（Worker 类型）。
2. 任务执行耗时超过基线 2 倍触发告警。
3. 任务长时间未执行（如 cron 任务跳过了预期的执行窗口）触发告警。

检查方式：监控平台配置审查
阻断级别：告警记录
