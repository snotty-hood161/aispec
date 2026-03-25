# rules/dotnet-desktop/common/security.md

## 输入校验（MUST）
1. 所有用户输入默认不可信，必须做长度、格式、枚举值校验。
2. 表单校验推荐使用 `INotifyDataErrorInfo` + FluentValidation，在 ViewModel 层实现。
3. 校验错误必须实时反馈到 UI（字段级错误提示），禁止仅在提交时才校验。
4. 文件路径输入必须校验路径合法性和访问权限，防止路径遍历攻击。

## 本地数据保护（MUST）
1. 敏感数据（用户密码、证件号、金融信息）禁止以明文存储在本地文件或数据库中。
2. 本地敏感数据必须使用加密存储：
   - Windows：`ProtectedData`（DPAPI）或 `PasswordVault`。
   - 跨平台：`Microsoft.AspNetCore.DataProtection`。
3. SQLite 数据库含敏感数据时，必须启用 SQLCipher 加密或应用层加密。
4. 应用日志禁止输出敏感信息：密码、令牌、证件号、银行卡完整信息。

## 认证与授权（MUST）
1. 与服务端交互必须使用安全认证方式（OAuth 2.0 / JWT Bearer），禁止明文传输用户名密码。
2. Token 存储必须使用系统安全存储（参见 `common/configuration.md` 凭据存储章节）。
3. Token 过期必须自动刷新，刷新失败时引导用户重新登录，禁止静默失败。
4. 用户注销时必须清除所有本地凭据和缓存的用户数据。

## 通信安全（MUST）
1. 所有与服务端的通信必须使用 HTTPS，禁止 HTTP 明文传输。
2. 桌面应用中禁止禁用 SSL 证书校验（`ServerCertificateCustomValidationCallback = (_, _, _, _) => true`），除非是开发调试环境。
3. API Key 或密钥禁止硬编码在源码或资源文件中，必须通过安全配置注入。

## 代码保护（SHOULD）
1. 发布的程序集推荐进行混淆处理（Obfuscation），防止逆向工程。推荐工具：`Obfuscar`、`ConfuserEx`、商业混淆器。
2. 敏感算法和密钥处理逻辑考虑使用 NativeAOT 编译或 C++ 原生库隔离。
3. 禁止在客户端硬编码 API Secret Key / 加密密钥等高敏感信息，此类操作应由服务端完成。

## 反调试与完整性校验（SHOULD）
1. 生产版本考虑检测调试器附加（`Debugger.IsAttached`），在安全敏感场景下限制功能。
2. 关键程序集考虑进行数字签名（Authenticode Signing），便于用户验证来源。
3. 自动更新包必须校验签名或哈希，防止中间人攻击替换更新包。

## 权限最小化（MUST）
1. 应用运行不应请求管理员权限（`requestedExecutionLevel = asInvoker`），除非确实需要（如安装服务、修改系统配置）。
2. 确需管理员权限的操作应独立为子进程提权执行，主进程保持普通权限运行。
3. 文件读写仅在用户数据目录操作，禁止写入系统目录或其他用户目录。
