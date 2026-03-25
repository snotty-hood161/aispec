# rules/python-server/profiles/microservice/project-structure.md

## 适用场景
1. 独立部署、独立伸缩、独立发布的 Python 微服务。
2. 每个服务仓库或每个服务目录都应作为独立可交付单元。

## 推荐目录结构
```text
.
├── app/
│   ├── __init__.py
│   ├── main.py                           # FastAPI 应用入口
│   ├── lifespan.py                       # 生命周期管理
│   ├── settings.py                       # pydantic-settings 配置类
│   ├── api/
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── router.py                 # v1 版本路由聚合
│   │   │   ├── user.py                   # 用户相关路由
│   │   │   └── order.py                  # 订单相关路由
│   │   └── deps.py                       # 公共依赖注入
│   ├── core/
│   │   ├── __init__.py
│   │   ├── exceptions.py                 # 通用异常基类与处理器
│   │   ├── response.py                   # 统一响应结构
│   │   └── middleware/
│   │       ├── cors.py
│   │       ├── request_id.py
│   │       └── logging.py
│   ├── platform/
│   │   ├── __init__.py
│   │   ├── database.py                   # 数据库连接池
│   │   ├── redis_client.py               # Redis 客户端
│   │   ├── object_storage.py             # 对象存储客户端
│   │   ├── jwt_handler.py                # JWT 签发与验证
│   │   ├── grpc_client.py                # gRPC 客户端管理
│   │   └── message_broker.py             # 消息队列客户端
│   ├── domain/
│   │   ├── __init__.py
│   │   ├── user_error.py                 # 用户域业务异常
│   │   └── order_error.py                # 订单域业务异常
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py                       # 用户 Pydantic schema
│   │   └── order.py                      # 订单 Pydantic schema
│   ├── service/
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   └── order_service.py
│   ├── repository/
│   │   ├── __init__.py
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   ├── user_model.py             # 持久化模型
│   │   │   └── order_model.py
│   │   ├── queries/
│   │   │   └── order_stat.py             # 临时读模型（统计/报表）
│   │   ├── user_repo.py
│   │   └── order_repo.py
│   ├── transport/
│   │   ├── grpc/                         # gRPC 服务端（可选）
│   │   └── event/                        # 事件消费处理
│   ├── tasks/
│   │   └── order_tasks.py                # Celery 异步任务
│   └── cache/
│       └── keys.py                       # 缓存键集中定义
├── proto/                                # gRPC 契约源（proto3）
│   └── order/
│       └── v1/
│           └── order.proto
├── alembic/
│   ├── alembic.ini
│   ├── env.py
│   └── versions/
├── configs/
│   ├── .env.example
│   └── gunicorn.conf.py
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── scripts/
├── pyproject.toml
├── Dockerfile
└── docker-compose.yml                    # 本地开发依赖编排
```

## 边界与依赖
1. `app/domain` 仅服务内部使用，禁止被其他服务直接 import。
2. 对外通信契约统一放 `proto/` 或通过 FastAPI 自动生成 OpenAPI。
3. 其他服务只能依赖契约与生成代码，不能依赖本服务内部 model。
4. `main.py` 只做装配，不承载业务逻辑。

## 中间件组织规则
1. 公共中间件放 `core/middleware`，仅提供技术能力，不承载业务语义。
2. 作用域认证/权限依赖放 `api/deps.py` 或按作用域拆分到独立文件。
3. 必须按"作用域 + 职责"拆文件，不允许把 `admin` 与 `user` 鉴权揉在同一实现里。
4. 禁止新增"汇总式"中间件文件承载多个无关责任。

## 异常组织规则
1. `core/exceptions.py` 仅提供通用异常机制，不承载 `user`、`order` 等业务语义异常。
2. 业务异常按作用域拆分到 `domain/`（如 `user_error.py`、`order_error.py`），每个作用域独立文件。
3. 系统异常必须由统一异常处理器捕获并映射为业务错误响应。

## 数据模型组织规则
1. 持久化模型放在 `repository/models/`，用于常规查询与写入。
2. 统计分析、多表聚合查询的临时读模型放在 `repository/queries/`。
3. 临时读模型仅用于读取结果承载，禁止作为常规写入模型或替代持久化模型。
4. 持久化模型与临时读模型都必须按职责独立文件，禁止 `models.py` 式汇总（单一 models.py 仅适用于小型服务）。

## 组件初始化规则
1. 组件装配统一在 `lifespan.py`，禁止在业务层直接初始化基础组件。
2. 平台组件统一放在 `platform/`，如 `database.py`、`redis_client.py`、`grpc_client.py`。
3. 初始化顺序与关闭顺序必须可读可验证：先初始化配置与日志，后初始化外部依赖，关闭顺序反向执行。
4. 组件失败默认快速失败，非关键可选组件需明确定义降级策略并记录日志。
