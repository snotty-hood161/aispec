# rules/android/common/security.md

## 文档目标
1. 定义 Android 应用的安全规范，覆盖代码混淆、安全存储、网络安全、防逆向等。

---

## 代码混淆与防逆向（MUST）

1. Release 构建必须启用 **R8** 代码混淆与优化。
2. `proguard-rules.pro` 纳入版本控制，禁止使用 `-dontwarn **` 忽略所有警告。
3. 关键 keep 规则必须有注释说明保留原因。
4. 混淆后必须验证应用功能完整性，CI 流水线包含混淆后的集成测试。

```kotlin
// build.gradle.kts
android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

## 安全存储（MUST）

1. 敏感数据（Token、密钥、用户凭据）必须使用 **EncryptedSharedPreferences** 或 **Android Keystore** 存储。
2. 禁止使用普通 `SharedPreferences` 存储敏感信息。
3. 禁止将敏感信息存储在外部存储（`/sdcard/`）。
4. 数据库中的敏感字段必须加密存储（推荐 SQLCipher 或 Room + 加密）。

```kotlin
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val securePrefs = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
)
```

---

## 网络安全（MUST）

1. 所有 HTTP 请求必须使用 HTTPS，禁止 HTTP 明文传输。
2. 必须配置 **Network Security Config**（`res/xml/network_security_config.xml`）。
3. 生产环境禁止 `cleartextTrafficPermitted="true"`。
4. 关键 API 必须实施 **证书固定**（Certificate Pinning）。

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config>
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2027-01-01">
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

5. OkHttp Certificate Pinner 配置：
```kotlin
val certificatePinner = CertificatePinner.Builder()
    .add("api.example.com", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .build()
```

---

## 代码安全（MUST）

1. 禁止在代码中硬编码 API 密钥、Token、密码。
2. 构建时注入的密钥通过 `local.properties` 或 CI Secret 管理，禁止提交到版本控制。
3. 发布构建必须启用代码签名，签名密钥通过 CI/CD Secret 管理。
4. 禁止在日志中输出敏感信息（Token、密码、用户隐私数据）。
5. WebView 禁止启用 `setJavaScriptEnabled(true)` + `addJavascriptInterface` 的组合，除非有充分安全评估。

---

## 权限管理（MUST）

1. 遵循最小权限原则，仅声明应用实际使用的权限。
2. 运行时权限必须在使用前请求，被拒绝后提供功能降级方案。
3. 禁止在 `AndroidManifest.xml` 中声明未使用的权限。
4. 敏感权限（相机、位置、麦克风）使用前必须向用户说明用途。

---

## 禁止事项

1. 禁止关闭 SSL 证书校验（`TrustAllCerts`）。
2. 禁止在 Release 构建中启用 `debuggable = true`。
3. 禁止使用 `MODE_WORLD_READABLE` / `MODE_WORLD_WRITEABLE`。
4. 禁止在 ContentProvider 中暴露敏感数据而不做权限校验。
5. 禁止使用过时的加密算法（MD5、SHA1 用于安全场景、DES）。
