# rules/flutter/common/security.md

## 文档目标
1. 定义 Flutter 跨平台应用的安全开发规范，覆盖存储、网络、代码保护。

---

## 安全存储（MUST）

1. 敏感数据（Token / 密钥 / 用户凭证）必须使用 **flutter_secure_storage** 存储：
   - Android 底层使用 EncryptedSharedPreferences（AES 加密）。
   - iOS 底层使用 Keychain Services。
2. 禁止将敏感数据存储在 `SharedPreferences` / `Hive` 等未加密存储中。
3. 禁止在日志、错误上报中输出 Token / 密钥 / 密码。
4. 用户登出时必须清除所有安全存储中的凭证。

---

## 网络安全（MUST）

1. 所有网络请求必须使用 HTTPS，禁止 HTTP 明文传输。
2. 生产环境推荐启用证书锁定（Certificate Pinning）：
   - 使用 `dio` 的 `SecurityContext` 或 `http_certificate_pinning` 包。
3. 禁止在生产代码中禁用 SSL 证书验证（`badCertificateCallback` 返回 true）。
4. API 请求 Token 通过 HTTP Header（`Authorization: Bearer xxx`）传输，禁止拼接在 URL 中。
5. 敏感接口（支付 / 修改密码）推荐使用请求签名机制。

---

## 代码混淆与保护（MUST）

1. 生产构建必须启用 Dart 代码混淆：
   ```bash
   flutter build apk --obfuscate --split-debug-info=build/debug-info/
   flutter build ipa --obfuscate --split-debug-info=build/debug-info/
   ```
2. `--split-debug-info` 输出的符号映射文件必须保存并上传到崩溃收集平台（用于堆栈还原）。
3. 禁止将 API 密钥、加密密钥硬编码在 Dart 源码中。
4. API 密钥应通过 `--dart-define` 在构建时注入，或通过后端动态下发。

---

## 输入校验（MUST）

1. 所有用户输入在发送到服务端前必须经过客户端校验。
2. 校验包括：长度限制、格式校验（正则）、XSS 字符过滤。
3. 富文本 / HTML 内容展示必须使用安全渲染（`flutter_html` 配合 sanitize）。
4. WebView 加载的 URL 必须白名单校验，禁止加载用户可控 URL。

---

## 本地数据保护（MUST）

1. 本地数据库（SQLite / Drift / Isar）存储敏感业务数据时必须启用加密：
   - SQLite 使用 `sqflite_sqlcipher` 或 `drift` + SQLCipher。
2. 应用截屏保护：涉及敏感信息的页面推荐禁用截屏（Android `FLAG_SECURE`）。
3. 应用退到后台时推荐显示遮罩，防止最近任务列表泄露敏感内容。

---

## 平台安全配置（MUST）

### Android
1. `AndroidManifest.xml` 中设置 `android:allowBackup="false"` 防止数据备份泄露。
2. 生产构建必须启用 ProGuard / R8 代码压缩。
3. 推荐集成 root 检测（`flutter_jailbreak_detection`），在 root 设备上提示风险。

### iOS
1. 启用 App Transport Security (ATS)，禁止 `NSAllowsArbitraryLoads`。
2. 启用 Data Protection（`NSFileProtectionComplete`）。
3. 推荐集成越狱检测，在越狱设备上提示风险。

---

## 禁止事项

1. 禁止将密钥 / Token / 密码硬编码在源码中。
2. 禁止在生产环境禁用 SSL 证书验证。
3. 禁止在日志中输出敏感信息。
4. 禁止使用 `SharedPreferences` 存储 Token 或密码。
5. 禁止在 WebView 中启用 `javaScriptEnabled` 而不限制加载域名。
