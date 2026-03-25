# rules/java-server/common/security.md

## 输入校验（MUST）

1. 所有外部输入默认不可信，必须做长度、格式、枚举值校验。
2. Controller 层必须使用 `@Valid` / `@Validated` 触发 Bean Validation，DTO 字段标注校验注解。
3. 路径参数和查询参数必须校验类型和范围（`@Min`、`@Max`、`@Pattern`）。
4. 文件上传必须校验文件大小上限和文件类型白名单（按 MIME 和文件头校验，不仅依赖扩展名）。
5. 禁止在 SQL、JPQL、HQL 中拼接用户输入，必须使用参数化查询。
6. XSS 防护：对用户输入的 HTML 内容做转义或白名单过滤，推荐使用 `OWASP Java HTML Sanitizer`。
7. CSRF 防护：非纯 API 服务（包含页面）必须启用 CSRF Token；纯 REST API 可禁用但需依赖 CORS + Token 机制。

## Spring Security 认证（MUST）

1. 必须使用 Spring Security 作为安全框架，禁止自行实现 Filter 链绕过 Spring Security。
2. 认证方式推荐 JWT（无状态）或 OAuth2（授权码/客户端凭证模式），选型须在设计阶段确定。
3. JWT 签名算法必须使用 RS256（非对称）或 HS256（对称），禁止使用 `none` 算法。
4. JWT 密钥禁止硬编码，必须通过配置或密钥管理服务注入。
5. JWT 必须设置过期时间（Access Token 建议 ≤ 2 小时，Refresh Token 建议 ≤ 7 天），禁止永不过期的 Token。
6. Token 刷新逻辑必须独立接口实现，禁止在业务接口中静默刷新。
7. 登录失败必须限制重试次数（建议 5 次/分钟），超过阈值锁定或延迟响应。

## 授权与权限（MUST）

1. 鉴权、鉴权失败返回、权限校验路径必须统一通过 Spring Security 的 Filter 链实现，不允许业务代码绕过。
2. 高风险操作必须具备二次校验或更强身份校验机制。
3. 不同访问作用域（如 `admin` 与 `user`）必须使用独立的 `SecurityFilterChain` 配置，禁止在同一 Filter 中通过分支混合处理。
4. 不同作用域的 Token 校验规则（签发方、受众、声明字段、过期策略）必须独立配置与验证。
5. 方法级权限控制使用 `@PreAuthorize` / `@Secured`，必须在 `@Configuration` 中启用 `@EnableMethodSecurity`。
6. 禁止在 Controller 中手写 if-else 判断权限，必须使用声明式注解或 Spring Security 表达式。

## OAuth2 集成（MUST，选用 OAuth2 时适用）

1. 使用 `spring-boot-starter-oauth2-resource-server` 做资源服务器，使用 `spring-boot-starter-oauth2-client` 做客户端。
2. OAuth2 Authorization Server 推荐使用 `Spring Authorization Server` 或外部 IdP（Keycloak、Auth0）。
3. 令牌内省（Token Introspection）或 JWKS 端点必须配置缓存，避免每次请求远程验证。
4. Scope 和 Authority 映射规则必须显式配置，禁止默认透传。

## 审计日志（MUST）

1. 高风险操作必须记录审计日志：操作者（userId）、操作对象、变更前后值、时间、来源 IP、`requestId`。
2. 审计日志必须独立存储（独立表或独立日志文件），禁止与业务日志混合。
3. 审计日志禁止删除和修改，保留期限不低于 180 天。
4. 推荐使用 Spring Data JPA 的 `@EntityListeners` + `AuditingEntityListener` 自动记录 `createdBy`、`createdDate`、`lastModifiedBy`、`lastModifiedDate`。

## 数据保护（MUST）

1. 敏感数据必须最小化存储与最小化输出（如手机号只返回后四位、身份证号脱敏）。
2. 密码存储必须使用 BCrypt（`BCryptPasswordEncoder`），禁止 MD5、SHA 等可逆/弱哈希。
3. 数据库中的敏感字段（身份证号、银行卡号）推荐加密存储（AES-256 或等效算法）。
4. API 响应中禁止返回密码哈希、密钥、内部 Token 等安全凭据。
5. 外部调用按风险等级配置白名单、限流、签名校验或等效机制。

### SHOULD
1. 启用 Spring Security 的 HTTP 安全头（`X-Content-Type-Options`、`X-Frame-Options`、`Strict-Transport-Security`）。
2. 敏感接口启用访问频率限制，防止暴力枚举。
3. 定期进行安全审计和渗透测试。
