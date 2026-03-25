# rules/tauri-desktop/common/security.md

## 文档目标
1. 定义 Tauri 桌面应用的安全规范，覆盖权限模型、CSP、文件系统隔离等。
2. 利用 Tauri 内置安全机制，最小化攻击面。

---

## Tauri 权限模型（MUST）

### Tauri v2 Capability 系统
1. 必须在 `src-tauri/capabilities/` 中显式声明应用所需权限。
2. 遵循最小权限原则：仅声明实际使用的 API 权限。
3. 禁止使用 `"permissions": ["core:default"]` 后不做细化。

```json
// src-tauri/capabilities/main.json
{
  "identifier": "main-capability",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "fs:allow-read-text-file",
    "fs:allow-write-text-file",
    "dialog:allow-open",
    "dialog:allow-save",
    "updater:default"
  ]
}
```

### 规则
1. 每个窗口独立配置 Capability，主窗口和子窗口权限分离。
2. 文件系统访问必须限定 Scope（允许的目录范围）。
3. Shell 命令执行必须使用 Sidecar 或 `shell:allow-execute`，禁止开放任意命令执行。

---

## CSP（Content Security Policy）（MUST）

1. `tauri.conf.json` 中必须配置严格的 CSP：
   ```json
   {
     "app": {
       "security": {
         "csp": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' asset: https://asset.localhost"
       }
     }
   }
   ```
2. 禁止 `script-src 'unsafe-eval'`（禁止 `eval()`）。
3. 禁止 `script-src 'unsafe-inline'`（禁止内联脚本）。
4. 外部资源加载必须限定域名白名单。

---

## 文件系统安全（MUST）

1. 文件读写必须限定在 Tauri Scope 允许的目录内。
2. 用户数据存储在 `app_data_dir`，临时文件存储在 `temp_dir`。
3. 禁止读写应用安装目录（只读）。
4. 文件路径必须做路径遍历（Path Traversal）防护，禁止拼接用户输入构造路径。

```rust
// 安全的文件路径构造
fn safe_file_path(app: &tauri::AppHandle, filename: &str) -> Result<PathBuf, AppError> {
    let sanitized = Path::new(filename)
        .file_name()
        .ok_or(AppError::Business("非法文件名".into()))?;
    Ok(app.path().app_data_dir()?.join(sanitized))
}
```

---

## 网络安全（MUST）

1. 所有 HTTP 请求必须使用 HTTPS，禁止 HTTP 明文传输。
2. 禁止在代码中禁用 SSL 证书校验。
3. API 密钥和 Token 存储在系统密钥链（macOS Keychain / Windows Credential Manager），禁止明文存储。
4. WebView 禁止加载外部不可信页面，如需加载外部 URL 必须使用独立窗口并限制权限。

---

## 代码安全（MUST）

1. Rust 代码禁止使用 `unsafe` 块，除非有充分理由并经评审。
2. 禁止在前端代码中硬编码密钥、Token、凭据。
3. 发布构建必须启用代码签名（Windows: Authenticode、macOS: Apple Developer ID）。
4. 更新包必须经过签名验证（Tauri Updater 内置签名校验，禁止绕过）。

---

## 禁止事项

1. 禁止使用 `dangerousRemoteDomainIpcAccess` 开放远程域名 IPC 访问。
2. 禁止在生产构建中启用 DevTools。
3. 禁止将敏感数据写入日志文件。
4. 禁止使用 `shell:allow-open` 打开任意 URL（必须限定协议和域名）。
