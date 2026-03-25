# rules/python-server/common/scheduled-tasks.md

## 文档目标
1. 定义定时任务、后台 Worker、批处理作业的约束。
2. 并发与资源控制参见 `common/concurrency-and-resource.md`。

---

## 任务框架选型（MUST）

| 类型 | 推荐方案 | 适用场景 |
|------|---------|---------|
| **分布式异步任务** | Celery + Redis/RabbitMQ | 多实例部署、任务持久化、重试、监控 |
| **轻量异步任务** | arq / Dramatiq | 小规模异步任务、Redis-only 架构 |
| **定时调度** | Celery Beat / APScheduler | 周期性定时任务 |

1. 项目必须选定唯一的异步任务框架，禁止混用（如 Celery + 手写线程池）。
2. 所有后台任务必须注册到任务框架，禁止在业务代码中散写 `threading.Timer` 或 `time.sleep` 轮询。

检查方式：代码审查
阻断级别：阻断合并

---

## Celery 配置规范（MUST）

1. Celery 任务 MUST 定义在独立的 `tasks.py` 文件中，禁止在路由或视图中内联定义。
2. 任务 MUST 使用 `@shared_task` 或 `@app.task` 装饰器注册，并设置 `name` 参数确保名称稳定。
3. 任务 MUST 配置 `acks_late=True`（延迟确认），确保 Worker 崩溃后任务可被重新投递。
4. 任务参数 MUST 可序列化（基本类型 + Pydantic model 的 `model_dump()`），禁止传递 ORM 实例或文件对象。
5. Celery Beat 定时任务 MUST 使用 `celery.schedules.crontab()` 或 `timedelta`，禁止在代码中使用 `while True + sleep` 模拟定时。

### Celery 任务定义示例
```python
from celery import shared_task

@shared_task(name="tasks.generate_daily_report", acks_late=True, max_retries=3)
def generate_daily_report(report_date: str) -> dict:
    """生成日报，支持幂等：检查报告是否已存在。"""
    if ReportRepository.exists(report_date):
        return {"status": "skipped", "reason": "already_exists"}
    report = ReportService.generate(report_date)
    return {"status": "success", "report_id": report.id}
```

检查方式：代码审查
阻断级别：阻断合并

---

## 分布式锁（MUST）

1. 多实例部署的定时任务必须通过分布式锁保证同一时刻只有一个实例执行，禁止重复执行。
2. 分布式锁推荐方案：Redis 锁（`SET key value NX EX`）/ 数据库行锁。
3. 锁必须设置超时时间，防止持有者崩溃导致死锁。
4. 锁的唯一标识必须包含任务名 + 调度周期（如 `daily-report:2026-03-16`），防止跨周期误锁。
5. 获取锁失败的实例必须静默跳过，禁止重试抢锁（由下一个调度周期自然重试）。

### Redis 分布式锁示例
```python
import uuid

async def acquire_lock(redis, lock_key: str, ttl: int = 300) -> str | None:
    lock_value = str(uuid.uuid4())
    acquired = await redis.set(lock_key, lock_value, nx=True, ex=ttl)
    return lock_value if acquired else None

async def release_lock(redis, lock_key: str, lock_value: str):
    script = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end"
    await redis.eval(script, 1, lock_key, lock_value)
```

检查方式：代码审查 + 集成测试
阻断级别：阻断合并

---

## 任务幂等（MUST）

1. 所有任务必须实现幂等性，重复执行不产生副作用。
2. 幂等实现推荐方案：
   - **状态检查**：执行前检查是否已完成（如对账单已生成则跳过）。
   - **唯一键**：写入结果带唯一约束，重复写入自动忽略。
3. 任务执行结果必须持久化记录（任务名、执行时间、状态、耗时、影响行数），便于排查。
4. Celery 任务推荐使用 `task_id` 作为幂等键，配合 Redis 去重窗口。

检查方式：代码审查
阻断级别：阻断合并

---

## 失败处理与告警（MUST）

1. 任务失败必须记录错误日志，包含任务名、任务 ID、失败原因、影响范围。
2. 任务失败必须触发告警通知，关键任务（对账、清算）必须即时告警。
3. 可重试的任务必须配置重试策略：`max_retries`（建议 ≤ 3）、`default_retry_delay`（指数退避）。
4. 超过最大重试次数后标记为失败，等待人工介入，禁止无限重试。
5. 长时间运行的任务必须设置超时（Celery `time_limit` 和 `soft_time_limit`），超时后取消并记录。

### Celery 重试与超时配置
```python
@shared_task(
    name="tasks.sync_external_data",
    max_retries=3,
    default_retry_delay=60,
    soft_time_limit=300,
    time_limit=360,
    acks_late=True,
)
def sync_external_data(source_id: str):
    try:
        ExternalDataService.sync(source_id)
    except TemporaryError as exc:
        raise sync_external_data.retry(exc=exc, countdown=60 * (sync_external_data.request.retries + 1))
```

检查方式：代码审查 + 监控告警审查
阻断级别：阻断合并

---

## 任务监控（SHOULD）

1. 以下指标纳入监控（推荐 `celery-exporter` 或 `flower`）：
   - 任务执行次数（成功/失败/重试）。
   - 任务执行耗时（P95/P99）。
   - 任务队列积压量。
2. 任务执行耗时超过基线 2 倍触发告警。
3. 任务长时间未执行（如 cron 任务跳过了预期的执行窗口）触发告警。
4. Dead Letter Queue 积压量超过阈值触发告警。

检查方式：监控平台配置审查
阻断级别：告警记录
