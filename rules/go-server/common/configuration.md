# rules/go-server/common/configuration.md

## 配置文件组织
1. 配置目录统一为 `configs/`，采用 `application.yml + application-<profile>.yml` 结构。
2. `application.yml` 存放跨环境默认值；环境差异配置放 `application-dev.yml`、`application-test.yml`、`application-prod.yml`。
3. Profile 必须显式指定（如 `APP_PROFILE=dev`），禁止依赖隐式默认环境启动生产服务。
4. 配置加载器代码放 `internal/platform/config`（或等价 `internal/app/config`），不放入业务模块目录。
5. Profile 必须白名单校验（如 `dev/test/staging/prod`），非法 profile 启动必须失败。

## 配置来源与优先级
1. 推荐加载顺序：`application.yml` < `application-<profile>.yml` < 环境变量/配置中心覆盖。
2. 配置通过环境变量或配置中心注入，禁止硬编码环境差异参数。
3. 密钥类配置必须来自安全存储，禁止提交到仓库。
4. `configs/` 仅存非敏感默认值或模板，禁止存放明文密钥。
5. 当前生效 profile 必须在启动日志中明确输出，便于排查环境错配。

## 基础设施配置约束
1. 数据库、Redis、MinIO 等外部依赖必须使用配置声明地址、凭据、超时、连接池参数，禁止代码硬编码。
2. 数据库配置必须显式声明 `type`，且仅允许 `mysql` 或 `postgresql`。
3. 若检查到“需要配置数据库”但未明确 `type`，必须先反馈并要求用户选择（`mysql` 或 `postgresql`），不得自行假设。
4. 超时、重试、连接池大小、并发上限必须可配置。
5. 启动阶段必须完成配置校验，失败要快速退出并输出明确错误。
6. 配置项变更涉及行为变化时，必须更新文档并注明默认值。

## CORS 配置约束
1. CORS 白名单域名必须由配置加载，禁止在 `cors` 中间件里硬编码。
2. CORS 必须支持多域名配置（如 `allowed_origins` 字符串数组）。
3. 不同 profile 必须允许配置不同 CORS 域名集合（例如 `dev` 允许本地调试域名，`prod` 仅允许正式域名）。
4. 当 `allow_credentials=true` 时，`allowed_origins` 禁止使用 `*`。

## 配置示例（简化）
```yaml
app:
  name: admin-server
  profile: dev

database:
  type: mysql
  dsn: ${DB_DSN}
  max_open_conns: 50
  max_idle_conns: 10
  conn_max_lifetime: 30m

redis:
  addr: ${REDIS_ADDR}
  password: ${REDIS_PASSWORD}
  db: 0

minio:
  endpoint: ${MINIO_ENDPOINT}
  access_key: ${MINIO_ACCESS_KEY}
  secret_key: ${MINIO_SECRET_KEY}
  bucket: app-assets
  use_ssl: true

http:
  cors:
    allowed_origins:
      - https://admin.example.com
      - https://app.example.com
    allowed_methods: [GET, POST, PUT, DELETE, OPTIONS]
    allowed_headers: [Authorization, Content-Type, X-Request-ID]
    allow_credentials: true
```
