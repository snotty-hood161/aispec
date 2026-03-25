# rules/python-server/common/security.md

## 输入校验（MUST）
1. 所有外部输入默认不可信，必须做长度、格式、枚举值校验（通过 Pydantic schema）。
2. Pydantic schema 必须使用 `Field()` 约束（`min_length`、`max_length`、`ge`、`le`、`pattern`），禁止仅靠类型注解。
3. 路径参数和查询参数必须使用 `Path()` / `Query()` 添加约束，禁止直接接受裸类型。
4. 文件上传必须校验文件大小、MIME 类型和文件头，禁止仅依赖扩展名。
5. URL、重定向地址必须做白名单校验，防止 SSRF 和 Open Redirect。
6. HTML 内容输入必须经过 XSS 过滤（如 `bleach` 或 `nh3` 库），禁止直接存储和渲染用户 HTML。

## 鉴权（MUST）
1. 鉴权、鉴权失败返回、权限校验路径必须统一，不允许业务代码绕过中间件。
2. 不同访问作用域（如 `admin` 与 `user`）必须使用独立认证依赖/中间件，禁止在同一依赖中通过分支混合处理。
3. 不同作用域的令牌校验规则（签发方、受众、声明字段、过期策略）必须独立配置与验证。
4. 高风险操作必须具备二次校验或更强身份校验机制。
5. JWT 令牌 MUST 配置合理过期时间（建议 access_token ≤ 30 分钟，refresh_token ≤ 7 天）。

### FastAPI 鉴权依赖示例
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

bearer_scheme = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    jwt_handler: JWTHandler = Depends(get_jwt_handler),
) -> UserPayload:
    payload = jwt_handler.verify(credentials.credentials, audience="user")
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="invalid token")
    return UserPayload(**payload)
```

## OAuth2 集成（SHOULD）
1. 对外 API 鉴权推荐使用 OAuth2（Authorization Code / Client Credentials）。
2. FastAPI 项目 SHOULD 使用 `fastapi.security.OAuth2PasswordBearer` 或 `OAuth2AuthorizationCodeBearer`。
3. Token 存储推荐 Redis（支持主动吊销），禁止仅依赖 JWT 自验证无法吊销。

## CORS 安全
1. CORS 白名单域名必须由配置加载（参见 `common/configuration.md`），禁止硬编码。
2. 生产环境禁止 `allow_origins=["*"]`，必须明确列出允许的域名。
3. 当 `allow_credentials=True` 时，`allow_origins` 禁止使用 `["*"]`。
4. 预检请求缓存时间（`max_age`）建议 ≤ 86400 秒。

## 审计日志（MUST）
1. 高风险操作必须记录审计日志：操作者、操作对象、变更前后值、时间、来源 IP。
2. 审计日志必须持久化存储（独立日志表或日志平台），不依赖于应用日志轮转。
3. 审计日志禁止包含密码、令牌等敏感信息的明文。
4. 删除和权限变更操作的审计日志保留期不少于 180 天。

## 数据保护（MUST）
1. 敏感数据必须最小化存储与最小化输出。
2. 密码存储 MUST 使用 `bcrypt` 或 `argon2`，禁止使用 MD5/SHA1/SHA256 单次哈希。
3. 敏感数据（身份证号、银行卡号）输出时 MUST 脱敏（部分掩码）。
4. 个人隐私数据（PII）的访问必须有权限控制和审计日志。
5. 数据库中的敏感字段 SHOULD 加密存储（如 AES-256），密钥由密钥管理服务管理。

## 密钥管理
1. 密钥、令牌、凭据禁止硬编码在代码中，必须通过环境变量或密钥管理服务注入。
2. 密钥禁止写入日志、异常信息、API 响应。
3. 密钥轮换必须有自动化流程，禁止长期使用不变的密钥。

## 安全 Headers（MUST）
1. 生产环境 MUST 配置安全响应头：
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: DENY`（或 `SAMEORIGIN`）
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
   - `Content-Security-Policy`（按需配置）
2. 禁止在响应中暴露服务器信息（如 `Server: uvicorn`），生产环境 SHOULD 移除或混淆。
