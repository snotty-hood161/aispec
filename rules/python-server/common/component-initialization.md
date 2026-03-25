# rules/python-server/common/component-initialization.md

## 目标
1. 统一 Python 服务端组件初始化方案，避免隐藏依赖、全局单例滥用和启动顺序漂移。
2. 覆盖常见基础组件：日志、数据库、Redis、对象存储、JWT、消息队列。

## DI 总体策略
1. FastAPI 项目 MUST 使用 `Depends()` 机制实现依赖注入，配合 `lifespan` 管理生命周期。
2. Django 项目 MUST 使用 `django-injector` 或手动构造函数注入，禁止在视图函数中直接构造外部客户端。
3. Flask 项目 MUST 使用 `flask-injector` 或应用工厂模式（`create_app()`），禁止模块级全局可变单例。
4. 组装根（Composition Root）必须位于应用启动入口或 `app/bootstrap` 模块。
5. 启动入口仅负责：加载配置、构建组件、注册路由/模块、启动服务、优雅退出。

### FastAPI 依赖注入示例
```python
from fastapi import Depends, FastAPI
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 初始化组件
    db_pool = await create_db_pool(settings.database)
    redis_client = await create_redis_client(settings.redis)
    app.state.db_pool = db_pool
    app.state.redis_client = redis_client
    yield
    # 关闭组件（反向顺序）
    await redis_client.close()
    await db_pool.close()

app = FastAPI(lifespan=lifespan)

async def get_db_session(request: Request):
    async with request.app.state.db_pool() as session:
        yield session

@app.get("/users/{user_id}")
async def get_user(user_id: int, session: AsyncSession = Depends(get_db_session)):
    ...
```

## 初始化与生命周期
1. 推荐初始化顺序：`config -> logger -> metrics/tracing -> db -> redis -> object_storage -> jwt -> repository -> service -> transport`。
2. 组件初始化失败的默认策略是快速失败（fail fast）；可选组件需明确定义降级策略并记录日志。
3. 所有可关闭组件必须实现统一关闭路径，关闭顺序与初始化顺序相反。
4. 进程退出时必须有超时控制，避免阻塞在资源回收阶段。
5. FastAPI 项目 MUST 使用 `lifespan` 事件管理初始化和清理，禁止使用已废弃的 `on_event("startup")` / `on_event("shutdown")`。

## 健康检查与就绪检查
1. 服务必须提供存活探针与就绪探针（建议 `/healthz` 与 `/readyz`）。
2. 存活探针仅反映进程可运行状态，不应依赖慢速外部依赖检查。
3. 就绪探针必须反映关键依赖可用性（如数据库、关键缓存、关键消息链路）。
4. 非关键可选依赖故障时可继续就绪，但必须有降级标识和告警日志。
5. 探针结果必须可观测：失败原因应写入结构化日志并附带 `request_id/trace_id`（如有）。

### 健康检查示例
```python
@app.get("/healthz")
async def liveness():
    return {"status": "ok"}

@app.get("/readyz")
async def readiness(db: AsyncSession = Depends(get_db_session)):
    try:
        await db.execute(text("SELECT 1"))
        return {"status": "ready"}
    except Exception:
        raise HTTPException(status_code=503, detail="database unavailable")
```

## 组件接口约束
1. 每个组件模块至少提供创建函数、关闭函数（如适用）和健康检查函数（如适用）。
2. 禁止在业务代码中直接构造第三方客户端（如 `sqlalchemy.create_engine()`、`redis.Redis()`），必须通过组件层提供的实例注入。
3. 组件日志必须脱敏，禁止打印密钥、令牌、连接串完整内容。

## 目录与职责
1. 组件实现放在 `app/platform/` 或 `app/infrastructure/`，例如：
   - `app/platform/database.py` — 数据库连接池
   - `app/platform/redis_client.py` — Redis 客户端
   - `app/platform/object_storage.py` — 对象存储客户端
   - `app/platform/jwt_handler.py` — JWT 签发与验证
2. 组件装配代码放在 `app/bootstrap.py` 或 `app/lifespan.py`。

## 重点组件规则
1. 数据库组件负责连接池创建、超时与健康检查，不承载业务 SQL。
2. SQLAlchemy 组件 MUST 使用 `AsyncSession` + `sessionmaker`，配置连接池参数（`pool_size`、`max_overflow`、`pool_timeout`、`pool_recycle`）。
3. Redis 组件必须配置超时（`socket_timeout`、`socket_connect_timeout`）和连接池（`max_connections`），禁止默认无限制。
4. 对象存储组件必须显式配置 endpoint、bucket、TLS 策略与超时。
5. JWT 组件必须显式配置签名算法、密钥来源、过期策略，禁止硬编码密钥。
6. 日志组件必须优先初始化，保证后续组件初始化失败可被记录。

## 可测试性要求
1. 使用方依赖抽象协议（`Protocol` / ABC）而非具体客户端类型，便于注入 mock 或 fake。
2. 组件创建函数必须可在测试中传入替代配置或替代依赖。
3. 禁止在测试中依赖全局可变单例状态。

## 禁止事项
1. 禁止在模块级别直接创建数据库引擎、Redis 连接等外部组件（除非由框架统一管理）。
2. 禁止通过模块级全局变量暴露可变组件实例（如全局 `db`、全局 `redis_client`），必须通过依赖注入获取。
3. 禁止在 router/service 中直接 `create_engine()`、`Redis()`、`boto3.client()` 等构造。
