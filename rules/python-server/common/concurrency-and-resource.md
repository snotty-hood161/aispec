# rules/python-server/common/concurrency-and-resource.md

## asyncio 并发控制
1. FastAPI 异步路由中，所有 I/O 操作（数据库、HTTP 请求、Redis）MUST 使用 `async/await`，禁止在异步上下文中调用同步阻塞函数。
2. 需要调用同步阻塞代码时，MUST 使用 `asyncio.to_thread()` 或 `run_in_executor()` 将其放入线程池执行。
3. 并发任务 MUST 使用 `asyncio.gather()` 或 `asyncio.TaskGroup()`（Python 3.11+）管理，禁止裸 `create_task()` 后不等待结果。
4. 所有异步任务必须有超时控制（`asyncio.wait_for()` 或 `asyncio.timeout()`），禁止无超时等待。
5. 异步上下文中禁止使用 `time.sleep()`，必须使用 `asyncio.sleep()`。

### asyncio 并发示例
```python
async def fetch_user_and_orders(user_id: int):
    async with asyncio.TaskGroup() as tg:
        user_task = tg.create_task(user_service.get_user(user_id))
        orders_task = tg.create_task(order_service.get_user_orders(user_id))
    return user_task.result(), orders_task.result()
```

## 线程池管理
1. 同步 Web 框架（Django/Flask + Gunicorn）MUST 配置 Worker 数量（建议 `2 * CPU + 1`）。
2. 线程池大小必须可配置，禁止使用无限制的线程创建。
3. CPU 密集型任务 MUST 使用 `ProcessPoolExecutor` 或独立进程/Celery 任务，禁止在 Web Worker 中长时间阻塞。
4. 多线程共享状态必须使用明确的同步机制（`threading.Lock`、`asyncio.Lock`），禁止依赖隐式顺序。

## 数据库连接池
1. SQLAlchemy MUST 配置连接池参数：`pool_size`、`max_overflow`、`pool_timeout`、`pool_recycle`。
2. 异步项目 MUST 使用 `create_async_engine` + `AsyncSession`，禁止在异步上下文中使用同步 Session。
3. 每个请求结束后 MUST 释放数据库连接（通过依赖注入的 `yield` 或上下文管理器），禁止连接泄漏。
4. Django 项目 MUST 配置 `CONN_MAX_AGE` 和 `CONN_HEALTH_CHECKS`，禁止每次请求新建连接。
5. 连接池参数通过配置文件管理，禁止硬编码。

### SQLAlchemy 异步连接池示例
```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

engine = create_async_engine(
    settings.database.dsn,
    pool_size=settings.database.pool_size,
    max_overflow=settings.database.max_overflow,
    pool_timeout=settings.database.pool_timeout,
    pool_recycle=settings.database.pool_recycle,
    pool_pre_ping=True,
)
async_session = async_sessionmaker(engine, expire_on_commit=False)
```

## Redis 连接池
1. Redis 客户端 MUST 配置连接池（`max_connections`）和超时（`socket_timeout`、`socket_connect_timeout`）。
2. 异步项目 MUST 使用 `redis.asyncio.Redis`，禁止在异步上下文中使用同步 Redis 客户端。
3. 连接池参数通过配置文件管理，禁止硬编码。

## 资源生命周期
1. 所有 I/O 操作必须设置超时（DB、HTTP、RPC、消息中间件）。
2. 长耗时任务必须支持取消和优雅退出。
3. 连接池、消费者、Worker 在关闭流程中必须按顺序释放并等待完成。
4. 上下文管理器（`async with` / `with`）是资源生命周期管理的首选方式。

## 优雅停机与请求排空
1. 收到停止信号（`SIGTERM`、`SIGINT`）后，服务必须先停止接收新请求，再等待在途请求处理完成。
2. Uvicorn MUST 配置 `--timeout-graceful-shutdown` 参数，确保优雅停机有超时控制。
3. Gunicorn MUST 配置 `graceful_timeout`，确保 Worker 有足够时间完成在途请求。
4. 优雅停机等待超时必须可配置，并记录停机阶段日志。
5. 超时后允许强制退出，但必须输出告警日志并统计未完成请求数量。
6. Celery Worker 停机时 MUST 先停止接收新任务（`worker_shutdown` 信号），等待正在执行的任务完成。

### Uvicorn 优雅停机配置
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --timeout-graceful-shutdown 30
```
