# rules/android/common/configuration.md

## 文档目标
1. 定义 Android 应用的构建配置与环境管理规范。

---

## Build Variant（MUST）

1. 必须至少定义 `debug` 和 `release` 两个 Build Type。
2. 推荐增加 `staging` Build Type 用于预发布验证。
3. 各 Build Type 必须配置独立的 `applicationIdSuffix` 以支持同设备多版本安装。

```kotlin
android {
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
        create("staging") {
            applicationIdSuffix = ".staging"
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

---

## Product Flavor（SHOULD）

1. 多品牌/多渠道应用使用 Product Flavor 区分。
2. Flavor 维度必须显式声明（`flavorDimensions`）。
3. Flavor 专属资源放在对应 source set（`src/{flavor}/`）。
4. 禁止在 Flavor 中复制粘贴大量代码，应通过抽象层处理差异。

---

## 签名管理（MUST）

1. Release 签名密钥禁止提交到版本控制。
2. 签名配置通过 `local.properties` 或 CI 环境变量注入。
3. Debug 签名使用 Android Studio 默认 Debug Keystore。
4. Google Play App Signing 推荐开启。

```kotlin
android {
    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE_PATH") ?: "debug.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: ""
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
        }
    }
}
```

---

## 环境变量管理（MUST）

1. API Base URL、第三方 SDK Key 等环境相关配置通过 `BuildConfig` 字段注入。
2. 不同环境的配置值在 `build.gradle.kts` 中按 Build Type / Flavor 定义。
3. 禁止在代码中硬编码环境相关值。

```kotlin
android {
    defaultConfig {
        buildConfigField("String", "API_BASE_URL", "\"https://api.example.com\"")
    }
    buildTypes {
        debug {
            buildConfigField("String", "API_BASE_URL", "\"https://api-dev.example.com\"")
        }
        create("staging") {
            buildConfigField("String", "API_BASE_URL", "\"https://api-staging.example.com\"")
        }
    }
}
```

---

## 资源管理（MUST）

1. 字符串必须放在 `res/values/strings.xml`，禁止硬编码字符串到代码中。
2. 多语言支持通过 `res/values-{locale}/strings.xml` 管理。
3. 颜色、尺寸统一在 `res/values/` 中定义，禁止在布局中硬编码。
4. 图片资源优先使用 Vector Drawable（SVG），位图使用 WebP 格式。
