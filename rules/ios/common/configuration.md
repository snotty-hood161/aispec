# rules/ios/common/configuration.md

## 文档目标
1. 定义 iOS 应用的构建配置与环境管理规范。

---

## Build Configuration（MUST）

1. 必须至少定义 `Debug` 和 `Release` 两个 Build Configuration。
2. 推荐增加 `Staging` Configuration 用于预发布验证。
3. 各 Configuration 使用独立的 Bundle Identifier 以支持同设备多版本安装。

---

## xcconfig 管理（MUST）

1. Build Settings 必须通过 `.xcconfig` 文件管理，禁止在 Xcode GUI 中手动修改。
2. xcconfig 文件按层级组织：Base → Configuration → Target。
3. 环境相关变量（API URL、SDK Key）在 xcconfig 中按 Configuration 定义。

```
// Config/Base.xcconfig
PRODUCT_BUNDLE_IDENTIFIER = com.example.app
SWIFT_VERSION = 5.9

// Config/Debug.xcconfig
#include "Base.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.app.debug
API_BASE_URL = https:\/\/api-dev.example.com
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG

// Config/Release.xcconfig
#include "Base.xcconfig"
API_BASE_URL = https:\/\/api.example.com
SWIFT_ACTIVE_COMPILATION_CONDITIONS = RELEASE
```

---

## Info.plist 管理（MUST）

1. 动态值通过 `$(VARIABLE_NAME)` 从 xcconfig 注入，禁止硬编码到 Info.plist。
2. 权限描述（`NSCameraUsageDescription` 等）必须提供清晰的用途说明。
3. URL Scheme 注册集中管理，用于 Deep Link 和第三方回调。

---

## 环境变量管理（MUST）

1. API Base URL、第三方 SDK Key 等通过 xcconfig + `Info.plist` 注入，代码中通过 `Bundle.main.infoDictionary` 读取。
2. 禁止在代码中硬编码环境相关值。
3. 敏感密钥（API Secret）通过 CI 环境变量注入，禁止提交到版本控制。

```swift
enum AppConfig {
    static let apiBaseURL: URL = {
        guard let urlString = Bundle.main.infoDictionary?["API_BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("API_BASE_URL 未在 Info.plist 中配置")
        }
        return url
    }()
}
```

---

## Feature Flags（SHOULD）

1. 推荐使用 Feature Flags 控制新功能灰度发布。
2. Feature Flags 通过远程配置（Firebase Remote Config）或本地配置管理。
3. Feature Flag 命名使用 `snake_case`，配置文件集中管理。

---

## 资源管理（MUST）

1. 字符串必须放在 `Localizable.strings` 或 String Catalog（`.xcstrings`），禁止硬编码。
2. 多语言支持通过 `Localizable.strings` + `.lproj` 管理。
3. 颜色和图片使用 Asset Catalog（`.xcassets`）统一管理。
4. 图标提供 `@1x` / `@2x` / `@3x` 或使用 SF Symbols / SVG。
