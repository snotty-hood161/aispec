# rules/ios/common/security.md

## 文档目标
1. 定义 iOS 应用的安全规范，覆盖 Keychain、ATS、代码签名、数据保护等。

---

## Keychain 安全存储（MUST）

1. 敏感数据（Token、密钥、用户凭据）必须使用 **Keychain Services** 存储。
2. 禁止使用 `UserDefaults` 存储敏感信息。
3. 推荐使用封装库（KeychainAccess / SwiftKeychainWrapper）简化 Keychain 操作。
4. Keychain Item 必须设置合适的 Accessibility（推荐 `kSecAttrAccessibleAfterFirstUnlock`）。

```swift
import KeychainAccess

let keychain = Keychain(service: "com.example.app")
    .accessibility(.afterFirstUnlock)

// 存储
try keychain.set(token, key: "auth_token")

// 读取
let token = try keychain.get("auth_token")

// 删除
try keychain.remove("auth_token")
```

---

## App Transport Security（MUST）

1. 必须保持 ATS 默认启用，所有网络请求使用 HTTPS。
2. 禁止在 `Info.plist` 中设置 `NSAllowsArbitraryLoads = YES`。
3. 如需连接特定 HTTP 域名（开发/测试），使用 `NSExceptionDomains` 精确配置。
4. 关键 API 推荐实施 **SSL Pinning**（证书固定）。

```swift
let session = URLSession(
    configuration: .default,
    delegate: SSLPinningDelegate(),
    delegateQueue: nil
)

class SSLPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let trust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(trust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        // 验证证书指纹
        let remoteCertData = SecCertificateCopyData(certificate) as Data
        if pinnedCertificates.contains(remoteCertData) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

---

## 代码签名与 Provisioning（MUST）

1. 必须使用 Apple Developer ID 进行代码签名。
2. 签名证书和 Provisioning Profile 通过 CI/CD Secret 管理，禁止提交到版本控制。
3. 推荐使用 **Fastlane Match** 统一团队签名证书管理。
4. 发布构建必须使用 Distribution Certificate + App Store Provisioning Profile。

---

## 数据保护（MUST）

1. 用户敏感数据文件设置 `FileProtectionType.complete` 或 `.completeUnlessOpen`。
2. Core Data / SwiftData 持久化存储设置加密属性。
3. 剪贴板中禁止存放敏感数据（设置 `UIPasteboard.general.setItems([], options: [.localOnly: true])`）。
4. 应用截屏保护：在 `sceneDidEnterBackground` 中覆盖敏感页面。

---

## 代码安全（MUST）

1. 禁止在代码中硬编码 API 密钥、Token、密码。
2. 构建时注入的密钥通过 xcconfig 或 CI 环境变量管理。
3. 禁止在日志中输出敏感信息（Token、密码、用户隐私数据）。
4. 禁止使用 Method Swizzling，除非有充分理由并经评审。

---

## 越狱检测（SHOULD）

1. 金融、支付等安全敏感应用推荐实施越狱检测。
2. 检测方式：检查越狱文件路径、Cydia URL Scheme、沙箱完整性。
3. 检测到越狱时提示用户风险，敏感功能降级或拒绝。

---

## 禁止事项

1. 禁止使用 `NSAllowsArbitraryLoads = YES`。
2. 禁止在 Release 构建中禁用 SSL 校验。
3. 禁止使用 `UserDefaults` 存储密码、Token。
4. 禁止将签名证书/私钥提交到版本控制。
5. 禁止在 Release 构建中保留测试用的后门接口。
