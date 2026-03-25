# rules/java-server/common/configuration.md

## 配置文件组织

### MUST
1. 配置文件统一使用 `application.yml`（推荐）或 `application.properties`，同一项目禁止混用两种格式。
2. 采用 `application.yml + application-{profile}.yml` 结构：`application.yml` 存放跨环境默认值；环境差异配置放 `application-dev.yml`、`application-test.yml`、`application-prod.yml`。
3. Profile 必须通过 `spring.profiles.active` 显式指定（启动参数或环境变量），禁止依赖隐式默认环境启动生产服务。
4. 配置绑定统一使用 `@ConfigurationProperties`，禁止在业务代码中散写 `@Value`（简单常量除外）。
5. `@ConfigurationProperties` 类必须使用 `@Validated` 标注，配合 Bean Validation 注解确保启动时发现配置错误。
6. Profile 必须白名单校验（如 `dev/test/staging/prod`），非法 profile 启动必须失败。

## 配置来源与优先级

### MUST
1. Spring Boot 配置加载顺序（从低到高）：`application.yml` < `application-{profile}.yml` < 环境变量 < 命令行参数 < 配置中心覆盖。
2. 配置通过环境变量或配置中心注入，禁止硬编码环境差异参数。
3. 密钥类配置（数据库密码、API Secret、JWT 签名密钥）必须来自安全存储（Vault / K8s Secret / 加密环境变量），禁止提交到代码仓库。
4. `application.yml` 中禁止存放明文密钥，敏感值使用 `${ENV_VAR}` 占位。
5. 当前生效 profile 必须在启动日志中明确输出，便于排查环境错配。

## 基础设施配置约束

### MUST
1. 数据库、Redis、OSS 等外部依赖必须使用配置声明地址、凭据、超时、连接池参数，禁止代码硬编码。
2. 数据库配置必须显式声明驱动类型（`spring.datasource.driver-class-name`），仅允许 MySQL（`com.mysql.cj.jdbc.Driver`）或 PostgreSQL（`org.postgresql.Driver`）。
3. 若需接入数据库但未明确类型，必须先确认数据库类型后再继续实现，不得自行假设。
4. 超时、重试、连接池大小、线程池核心线程数必须可配置。
5. 启动阶段必须完成配置校验（通过 `@Validated` + `@ConfigurationProperties`），失败要快速退出并输出明确错误。
6. 配置项变更涉及行为变化时，必须更新文档并注明默认值。

## CORS 配置约束

### MUST
1. CORS 白名单域名必须由配置加载，禁止在 `WebMvcConfigurer` 或 Filter 中硬编码。
2. CORS 必须支持多域名配置（`allowed-origins` 列表）。
3. 不同 profile 必须允许配置不同 CORS 域名集合（例如 `dev` 允许本地调试域名，`prod` 仅允许正式域名）。
4. 当 `allowCredentials=true` 时，`allowedOrigins` 禁止使用 `*`，必须使用 `allowedOriginPatterns`。

## 配置示例（简化）

```yaml
spring:
  application:
    name: order-service
  profiles:
    active: ${APP_PROFILE:dev}

  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: ${DB_URL:jdbc:mysql://localhost:3306/order_db?useSSL=true&serverTimezone=UTC}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD}
      lettuce:
        pool:
          max-active: 16
          max-idle: 8
          min-idle: 2

server:
  port: 8080
  shutdown: graceful

management:
  server:
    port: 8081
  endpoints:
    web:
      exposure:
        include: health,prometheus,info
  endpoint:
    health:
      show-details: when_authorized
      probes:
        enabled: true

app:
  cors:
    allowed-origins:
      - https://admin.example.com
      - https://app.example.com
    allowed-methods: GET,POST,PUT,DELETE,OPTIONS
    allowed-headers: Authorization,Content-Type,X-Request-ID
    allow-credentials: true
```

### SHOULD
1. 使用 Spring Boot 的 `spring-boot-configuration-processor` 生成配置元数据，提升 IDE 自动补全体验。
2. 复杂配置分拆为多个 `@ConfigurationProperties` 类，每个类职责单一。
3. 配置文件中的每个自定义配置项附带行内注释说明用途和默认值。
