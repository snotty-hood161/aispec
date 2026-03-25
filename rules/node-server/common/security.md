# rules/node-server/common/security.md

## HTTP 安全头（MUST）

1. 必须使用 `helmet` 中间件设置安全响应头，NestJS 在 `main.ts` 中全局启用。
2. 必须设置以下安全头（`helmet` 默认包含，需确认未被禁用）：
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: DENY` 或 `SAMEORIGIN`
   - `X-XSS-Protection: 0`（现代浏览器推荐禁用，依赖 CSP）
   - `Strict-Transport-Security`（HSTS，生产环境强制 HTTPS）
   - `Content-Security-Policy`（根据业务需求配置）
3. 响应中禁止暴露服务器技术栈信息：移除 `X-Powered-By` 头（`helmet` 默认移除）。
4. API 响应禁止设置缓存敏感数据：涉及用户隐私的接口必须设置 `Cache-Control: no-store`。

检查方式：安全扫描 + 响应头审查
阻断级别：阻断合并

---

## CORS 策略（MUST）

1. 必须显式配置 CORS，禁止使用 `origin: '*'`（生产环境）。
2. 允许的 Origin 列表必须从配置文件/环境变量加载，禁止在代码中硬编码域名。
3. `credentials: true` 时必须明确指定 `origin`（不能为 `*`）。
4. 必须限制允许的 HTTP 方法和请求头，禁止 `methods: '*'`。
5. 预检请求（OPTIONS）的 `maxAge` 推荐设置为 86400 秒（24 小时），减少预检请求频率。

### SHOULD
1. 推荐为不同 API 前缀配置不同的 CORS 策略（如管理后台 API 限制更严格的 Origin）。

检查方式：安全扫描 + 配置审查
阻断级别：阻断合并

---

## 认证与授权（MUST）

1. 认证方案推荐 JWT + Refresh Token 模式，NestJS 项目推荐使用 `@nestjs/passport` + `passport-jwt`。
2. Access Token 有效期不超过 30 分钟，Refresh Token 有效期不超过 7 天。
3. JWT 签名必须使用 RS256 或 ES256 非对称算法（生产环境），禁止使用 `none` 算法。
4. JWT 密钥禁止硬编码，必须通过环境变量或密钥管理服务注入。
5. 必须实现统一的认证守卫（NestJS Guard / Express 中间件），在路由级别声明是否需要认证。
6. 授权必须基于角色（RBAC）或权限（ABAC），禁止在业务代码中硬编码角色判断。
7. 敏感操作（删除、权限变更、资金操作）必须进行二次确认或额外鉴权。

### SHOULD
1. 推荐使用 `@nestjs/passport` 的多策略（local、jwt、api-key）支持不同认证场景。
2. 推荐实现 Token 黑名单机制，支持用户主动登出和强制下线。
3. 推荐使用 CASL（`@casl/ability`）实现细粒度权限控制。

检查方式：安全审查 + 渗透测试
阻断级别：阻断合并

---

## 输入校验与防注入（MUST）

1. 所有用户输入必须在 controller 层通过 DTO 校验（参见 `common/api-design.md`），进入 service 层的数据必须是已校验的。
2. 禁止直接拼接用户输入到 SQL 语句，必须使用参数化查询（ORM 默认参数化）。
3. 必须对用户输入进行 XSS 过滤（推荐 `xss` 或 `dompurify`），特别是存储到数据库后会被前端渲染的字段。
4. 文件上传必须校验文件类型（基于 Magic Bytes 而非扩展名）、文件大小，并使用随机文件名存储。
5. URL 参数和路径参数必须校验格式（如 ID 必须为 UUID 或正整数），防止路径遍历攻击。
6. 请求体大小必须限制（推荐 `body-parser` 配置 `limit: '1mb'`），防止大体积攻击。

### SHOULD
1. 推荐使用 `express-rate-limit` 或 `@nestjs/throttler` 实现 API 限流，防止暴力破解和 DDoS。
2. 推荐为登录接口实现渐进式延迟或账号锁定策略。

检查方式：安全扫描（OWASP ZAP）+ 渗透测试
阻断级别：阻断合并

---

## 数据保护（MUST）

1. 密码必须使用 `bcrypt`（推荐 cost factor ≥ 12）或 `argon2` 加密存储，禁止使用 MD5/SHA 系列。
2. 敏感数据（身份证号、银行卡号、手机号）存储时必须加密，查询时按需解密。
3. API 响应中禁止返回密码哈希、完整身份证号、完整银行卡号等敏感字段。
4. 数据库连接必须启用 TLS/SSL（生产环境），连接串中配置 `ssl=true`。
5. 日志中禁止记录用户密码、令牌、信用卡号等敏感信息，必须脱敏处理。

### SHOULD
1. 推荐使用字段级加密（AES-256-GCM）保护高敏感数据。
2. 推荐实现数据访问审计日志，记录谁在何时访问了哪些敏感数据。

检查方式：安全审查 + 数据分类审查
阻断级别：阻断合并

---

## 审计日志（MUST）

1. 用户关键操作必须记录审计日志（参见 `common/observability.md` 审计日志章节）。
2. 审计日志必须独立于业务日志，持久化存储且不可篡改。
3. 管理员操作（用户管理、角色变更、系统配置）必须全量记录审计日志。

---

## 依赖安全（MUST）

1. 必须在 CI 中运行 `pnpm audit`，高危漏洞阻断合并（参见 `common/baseline.md`）。
2. 禁止使用已知有安全漏洞且无修复版本的依赖，必须寻找替代方案。
3. 禁止在生产环境暴露调试端口（如 `--inspect`），禁止启用 REPL 功能。
