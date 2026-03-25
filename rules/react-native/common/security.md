# rules/react-native/common/security.md

## 文档目标
1. 定义 React Native 跨平台应用的安全开发规范，覆盖存储、网络、代码保护。

---

## 安全存储（MUST）

1. 敏感数据（Token / 密钥 / 用户凭证）必须使用加密存储方案：
   - 推荐 **react-native-mmkv**（MMKV 引擎，支持加密模式）。
   - 或 **react-native-keychain**（底层使用 Android Keystore / iOS Keychain）。
2. 禁止将敏感数据存储在 `AsyncStorage`、`MMKV 非加密模式`、或明文本地文件中。
3. 禁止在日志、错误上报中输出 Token / 密钥 / 密码。
4. 用户登出时必须清除所有安全存储中的凭证。
5. 加密密钥不得硬编码在 JS Bundle 中，推荐使用原生 Keystore / Keychain 派生。

```typescript
// 正确：使用加密 MMKV
import { MMKV } from 'react-native-mmkv';

const secureStorage = new MMKV({
  id: 'secure-storage',
  encryptionKey: getEncryptionKeyFromKeychain(),
});

// 错误：使用 AsyncStorage 存储 Token
import AsyncStorage from '@react-native-async-storage/async-storage';
await AsyncStorage.setItem('token', accessToken); // 禁止
```

---

## 网络安全（MUST）

1. 所有网络请求必须使用 HTTPS，禁止 HTTP 明文传输。
2. 生产环境推荐启用证书锁定（Certificate Pinning）：
   - 使用 **react-native-ssl-pinning** 或 **TrustKit** 集成。
3. 禁止在生产代码中禁用 SSL 证书验证。
4. API 请求 Token 通过 HTTP Header（`Authorization: Bearer xxx`）传输，禁止拼接在 URL 中。
5. 敏感接口（支付 / 修改密码）推荐使用请求签名机制。
6. 网络请求必须设置合理超时时间（默认 30s），防止连接泄漏。

---

## 代码保护（MUST）

1. 生产构建必须启用 **Hermes bytecode** 编译，JS Bundle 以 `.hbc` 格式分发而非明文 JS。
2. Android 生产构建必须启用 ProGuard / R8 代码压缩与混淆。
3. iOS 生产构建启用 Bitcode（如支持）。
4. 禁止将 API 密钥、加密密钥硬编码在 TypeScript / JavaScript 源码中。
5. API 密钥应通过 `react-native-config` 在构建时注入环境变量，或通过后端动态下发。
6. 推荐使用 **react-native-code-push** 或 **EAS Update** 时启用签名校验，防止 OTA 包被篡改。

---

## 输入校验（MUST）

1. 所有用户输入在发送到服务端前必须经过客户端校验。
2. 校验包括：长度限制、格式校验（正则）、XSS 字符过滤。
3. 推荐使用 **zod** 或 **yup** 作为校验库，统一前后端校验规则。
4. WebView 加载的 URL 必须白名单校验，禁止加载用户可控的任意 URL。
5. Deep Link 参数必须校验后再使用，防止注入攻击。

---

## 本地数据保护（MUST）

1. 本地数据库（WatermelonDB / SQLite）存储敏感业务数据时推荐启用加密。
2. 应用截屏保护：涉及敏感信息的页面推荐禁用截屏：
   - Android 使用 `FLAG_SECURE`。
   - iOS 使用 `UIScreen` 截屏通知 + 遮罩。
3. 应用退到后台时推荐显示遮罩，防止最近任务列表泄露敏感内容。
4. 推荐集成 **react-native-screens** 的隐私模式处理后台遮罩。

---

## 平台安全配置（MUST）

### Android
1. `AndroidManifest.xml` 中设置 `android:allowBackup="false"` 防止数据备份泄露。
2. 生产构建必须启用 ProGuard / R8 代码压缩。
3. 推荐集成 root 检测（**react-native-device-info** + **jail-monkey**），在 root 设备上提示风险。
4. `network_security_config.xml` 必须配置，限制 ClearText 流量。

### iOS
1. 启用 App Transport Security (ATS)，禁止 `NSAllowsArbitraryLoads`。
2. 启用 Data Protection（`NSFileProtectionComplete`）。
3. 推荐集成越狱检测（**jail-monkey**），在越狱设备上提示风险。
4. Keychain 存储的 AccessGroup 必须正确配置，防止跨应用读取。

---

## 认证与会话（MUST）

1. Token 刷新逻辑必须在 HTTP 拦截器中统一处理，禁止在各业务模块分散实现。
2. Refresh Token 过期后必须清除所有凭证并跳转登录页。
3. 生物识别认证（Face ID / 指纹）推荐使用 **react-native-biometrics** 或 **expo-local-authentication**。
4. 多设备登录场景必须支持服务端踢出与本地感知。

---

## 禁止事项

1. 禁止将密钥 / Token / 密码硬编码在源码中。
2. 禁止在生产环境禁用 SSL 证书验证。
3. 禁止在日志中输出敏感信息。
4. 禁止使用 `AsyncStorage` 存储 Token 或密码。
5. 禁止在 WebView 中启用 JavaScript 而不限制加载域名。
6. 禁止以明文 JS Bundle 分发生产构建（必须使用 Hermes bytecode）。
