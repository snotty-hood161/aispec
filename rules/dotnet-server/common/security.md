# rules/dotnet-server/common/security.md

## 输入与鉴权
1. 所有外部输入默认不可信，必须做长度、格式、枚举值校验（推荐 FluentValidation 或 DataAnnotations）。
2. 鉴权、鉴权失败返回、权限校验路径必须统一，不允许业务代码绕过中间件。
3. 高风险操作必须具备二次校验或更强身份校验机制。
4. 不同访问作用域（如 `Admin` 与 `User`）必须使用独立认证方案（`AuthenticationScheme`），禁止在同一 Handler 中通过分支混合处理。
5. 不同作用域的令牌校验规则（签发方、受众、声明字段、过期策略）必须独立配置与验证。
6. 授权策略使用 `[Authorize(Policy = "...")]`，策略定义集中在 `Program.cs` 或独立扩展方法中。

## JWT 安全
1. JWT 签名算法推荐 `RS256`（非对称）或 `HS256`（对称），禁止使用 `none` 算法。
2. 密钥必须从配置/密钥管理服务加载，禁止硬编码。
3. Token 验证必须校验 `Issuer`、`Audience`、`Lifetime`，启用 `ValidateIssuerSigningKey`。
4. Refresh Token 必须存储在服务端（数据库/Redis），支持主动吊销。
5. Access Token 过期时间建议 <= 30 分钟，Refresh Token 过期时间建议 <= 7 天。

## 防注入与防攻击
1. SQL 注入：EF Core 默认参数化查询；使用原生 SQL 或 Dapper 时必须使用参数化，禁止字符串拼接。
2. XSS：API 响应 `Content-Type` 必须为 `application/json`，禁止返回未转义的 HTML。
3. CSRF：SPA 场景使用 JWT Bearer Token 天然免疫 CSRF；若使用 Cookie 认证，必须启用 AntiForgery。
4. 请求体大小限制：必须配置 `MaxRequestBodySize`，防止大请求 DoS。
5. Rate Limiting：必须对公开接口配置限流（推荐 ASP.NET Core 内置 `RateLimiter` 中间件）。

## 审计与数据保护
1. 高风险操作必须记录审计日志：操作者、对象、变更前后、时间、来源 IP。
2. 敏感数据必须最小化存储与最小化输出。
3. 外部调用按风险等级配置白名单、限流、签名校验或等效机制。
4. 密码存储必须使用 `BCrypt` 或 `Argon2` 哈希，禁止使用 MD5/SHA 系列直接哈希。
5. 敏感字段（身份证号、手机号、银行卡号）在日志和响应中必须脱敏显示。
