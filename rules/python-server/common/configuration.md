# rules/python-server/common/configuration.md

## 配置管理方案
1. 推荐使用 `pydantic-settings`（Pydantic v2）作为配置管理方案，提供类型安全的配置加载和校验。
2. Django 项目使用 `django-environ` 或 `pydantic-settings` 管理配置。
3. 配置类必须继承 `BaseSettings`，所有配置项必须有类型注解和默认值（或标记为必填）。

### pydantic-settings 示例
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class DatabaseSettings(BaseSettings):
    type: Literal["mysql", "postgresql"] = "postgresql"
    dsn: str
    pool_size: int = 10
    max_overflow: int = 20
    pool_timeout: int = 30
    pool_recycle: int = 1800

class RedisSettings(BaseSettings):
    url: str
    max_connections: int = 50
    socket_timeout: float = 5.0

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_nested_delimiter="__",
    )

    app_name: str = "my-service"
    profile: Literal["dev", "test", "staging", "prod"] = "dev"
    database: DatabaseSettings
    redis: RedisSettings
```

## 配置文件组织
1. 配置目录统一为 `configs/`（或使用 `.env` 文件），采用环境分离结构。
2. `.env` 仅存放环境差异参数，应用代码通过 `pydantic-settings` 自动加载。
3. Profile 必须显式指定（如 `APP_PROFILE=dev`），禁止依赖隐式默认环境启动生产服务。
4. Profile 必须白名单校验（如 `dev/test/staging/prod`），非法 profile 启动必须失败。
5. 当前生效 profile 必须在启动日志中明确输出，便于排查环境错配。

## 配置来源与优先级
1. 推荐加载顺序：代码默认值 < 配置文件 < `.env` 文件 < 环境变量 < 配置中心覆盖。
2. 配置通过环境变量或配置中心注入，禁止硬编码环境差异参数。
3. 密钥类配置必须来自安全存储（环境变量 / Vault / K8s Secret），禁止提交到仓库。
4. `.env` 文件必须加入 `.gitignore`，仅 `.env.example`（含注释无真实密钥）纳入版本控制。
5. 禁止在代码中直接调用 `os.getenv()` 读取配置，必须通过配置类统一管理。

## 基础设施配置约束
1. 数据库、Redis、MinIO 等外部依赖必须使用配置声明地址、凭据、超时、连接池参数，禁止代码硬编码。
2. 数据库配置必须显式声明 `type`，且仅允许 `mysql` 或 `postgresql`。
3. 若检查到"需要配置数据库"但未明确 `type`，必须先反馈并要求用户选择，不得自行假设。
4. 超时、重试、连接池大小、并发上限必须可配置。
5. 启动阶段必须完成配置校验（`pydantic-settings` 自动完成），失败要快速退出并输出明确错误。
6. 配置项变更涉及行为变化时，必须更新文档并注明默认值。

## CORS 配置约束
1. CORS 白名单域名必须由配置加载，禁止在中间件里硬编码。
2. CORS 必须支持多域名配置（如 `allowed_origins` 列表）。
3. 不同 profile 必须允许配置不同 CORS 域名集合（例如 `dev` 允许本地调试域名，`prod` 仅允许正式域名）。
4. 当 `allow_credentials=True` 时，`allowed_origins` 禁止使用 `["*"]`。

### FastAPI CORS 配置示例
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors.allowed_origins,
    allow_credentials=settings.cors.allow_credentials,
    allow_methods=settings.cors.allowed_methods,
    allow_headers=settings.cors.allowed_headers,
)
```

## Django 配置约束
1. Django 项目的 `settings.py` 禁止包含硬编码的密钥和敏感信息。
2. `SECRET_KEY`、`DATABASE` 配置必须从环境变量加载。
3. `DEBUG = True` 禁止出现在生产配置中。
4. `ALLOWED_HOSTS` 必须显式配置，禁止使用 `["*"]`（开发环境除外）。
