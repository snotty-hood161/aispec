# rules/python-server/profiles/monolith/project-structure.md

## 适用场景
1. 单进程部署的 Python 应用，含管理后台 API、业务 API、后台任务等。
2. 默认采用"模块化单体（Modular Monolith）"而非脚手架式平铺目录。

## 推荐目录结构（FastAPI）
```text
.
├── app/
│   ├── __init__.py
│   ├── main.py                           # 应用入口：创建 FastAPI 实例、注册路由
│   ├── lifespan.py                       # 生命周期管理：初始化/关闭组件
│   ├── settings.py                       # pydantic-settings 配置类
│   ├── core/
│   │   ├── __init__.py
│   │   ├── exceptions.py                 # 通用异常基类与异常处理器
│   │   ├── response.py                   # 统一响应结构
│   │   ├── security.py                   # JWT/OAuth2 通用鉴权
│   │   └── middleware/
│   │       ├── __init__.py
│   │       ├── cors.py                   # 跨域策略
│   │       ├── request_id.py             # 请求标识注入
│   │       ├── logging.py                # 访问日志
│   │       └── error_handler.py          # 全局异常处理
│   ├── platform/                         # 基础设施组件（数据库/缓存/存储）
│   │   ├── __init__.py
│   │   ├── database.py                   # 数据库连接池
│   │   ├── redis_client.py               # Redis 客户端
│   │   ├── object_storage.py             # 对象存储客户端
│   │   └── jwt_handler.py                # JWT 签发与验证
│   ├── modules/
│   │   ├── user/
│   │   │   ├── __init__.py
│   │   │   ├── router.py                 # HTTP 路由（transport 层）
│   │   │   ├── schemas.py                # Pydantic 请求/响应模型
│   │   │   ├── service.py                # 业务逻辑（service 层）
│   │   │   ├── repository.py             # 数据访问（repository 层）
│   │   │   ├── models.py                 # ORM 持久化模型
│   │   │   ├── exceptions.py             # 用户域业务异常
│   │   │   └── dependencies.py           # FastAPI 依赖（鉴权、权限）
│   │   ├── order/
│   │   │   ├── __init__.py
│   │   │   ├── router.py
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   ├── repository.py
│   │   │   ├── models.py
│   │   │   ├── exceptions.py
│   │   │   └── tasks.py                  # Celery 异步任务
│   │   └── admin/
│   │       ├── __init__.py
│   │       ├── router.py
│   │       ├── dependencies.py           # 管理端独立鉴权
│   │       └── ...
│   ├── cache/
│   │   ├── __init__.py
│   │   └── keys.py                       # 缓存键集中定义
│   └── shared/                           # 跨模块共享能力（仅技术组件）
│       └── __init__.py
├── alembic/                              # 数据库迁移
│   ├── alembic.ini
│   ├── env.py
│   └── versions/
├── configs/
│   ├── .env.example                      # 环境变量模板
│   └── gunicorn.conf.py                  # Gunicorn 配置
├── tests/
│   ├── conftest.py                       # 全局 Fixture
│   ├── unit/
│   │   ├── test_user_service.py
│   │   └── ...
│   └── integration/
│       └── ...
├── scripts/
├── docs/
│   └── api/
├── pyproject.toml                        # 依赖管理 + 工具配置
└── Dockerfile
```

## 推荐目录结构（Django）
```text
.
├── config/
│   ├── __init__.py
│   ├── settings/
│   │   ├── base.py                       # 通用配置
│   │   ├── dev.py                        # 开发环境
│   │   └── prod.py                       # 生产环境
│   ├── urls.py
│   └── wsgi.py / asgi.py
├── apps/
│   ├── user/
│   │   ├── models.py
│   │   ├── views.py / viewsets.py
│   │   ├── serializers.py
│   │   ├── services.py
│   │   ├── repositories.py
│   │   ├── exceptions.py
│   │   ├── urls.py
│   │   └── tests/
│   └── order/
│       └── ...
├── core/
│   ├── exceptions.py
│   ├── middleware/
│   ├── permissions.py
│   └── pagination.py
├── platform/
│   ├── database.py
│   ├── redis_client.py
│   └── ...
├── manage.py
├── requirements.txt / pyproject.toml
└── Dockerfile
```

## 模块边界
1. 模块内依赖只允许 `router(transport) -> service -> repository`，禁止反向依赖。
2. `domain`（模型与业务规则）不反向依赖外层实现细节。
3. 模块之间禁止直接调用对方 `repository`。
4. 跨模块协作通过 `service` 接口或模块 Facade。
5. `modules/<module>/models.py` 是模块私有模型，不用于跨服务共享。

## 中间件组织规则
1. `core/middleware` 只放"跨作用域可复用"的技术中间件，如 `cors`、`request_id`、`error_handler`。
2. 带业务作用域语义的认证/权限依赖必须放 `modules/<module>/dependencies.py`（FastAPI）或 `apps/<app>/permissions.py`（Django）。
3. 必须按"作用域 + 职责"拆分：每个作用域或职责一个独立文件，禁止把多个责任揉进同一个大文件。
4. 禁止把 `admin` 和 `user` 认证写在同一个依赖/中间件里靠 `if` 分支区分，必须拆成独立实现。

## 异常组织规则
1. `core/exceptions.py` 仅提供通用异常机制（基类、异常处理器），不承载业务语义异常。
2. 业务异常按模块拆分到 `modules/<module>/exceptions.py`，每个模块独立文件。
3. 系统异常在统一异常处理器中捕获、记录日志并映射为业务错误响应，禁止直接返回原始异常。

## 数据模型组织规则
1. 模块 ORM 模型放在 `modules/<module>/models.py`。
2. Pydantic 请求/响应 schema 放在 `modules/<module>/schemas.py`（FastAPI）或 `serializers.py`（Django）。
3. ORM 模型与 Pydantic schema 禁止混用，转换必须显式实现。
4. 统计分析临时查询 Schema 与 ORM 模型必须分离。

## 组件初始化规则
1. 组件装配统一在 `lifespan.py`（FastAPI）或 `AppConfig.ready()`（Django），禁止在业务层直接初始化基础组件。
2. 平台组件统一放在 `platform/` 目录。
3. 初始化顺序与关闭顺序必须可读可验证：先初始化配置与日志，后初始化外部依赖，关闭顺序反向执行。
4. 组件失败默认快速失败，非关键可选组件需明确定义降级策略并记录日志。

## 额外约束
1. `shared/` 只允许沉淀无业务语义组件，不允许放业务实体。
2. 启动入口只做装配，不做业务判断，不写 SQL。
3. 系统异常必须记录并由统一异常处理器映射为业务错误响应，禁止直接返回异常原文。
