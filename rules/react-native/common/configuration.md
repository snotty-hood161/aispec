# rules/react-native/common/configuration.md

## 文档目标
1. 定义 React Native 项目的环境变量、多环境配置与构建变体管理规范。

---

## 环境变量管理（MUST）

1. 环境变量必须通过 **react-native-config**（bare workflow）或 **expo-constants** + `app.config.ts`（Expo）管理。
2. 禁止在 TypeScript 源码中硬编码环境相关的值（API 地址、密钥、Feature Flag）。
3. 环境变量文件按环境区分：

```
.env                  # 默认（开发环境）
.env.staging          # 预发布环境
.env.production       # 生产环境
```

4. `.env*` 文件必须加入 `.gitignore`，禁止提交到代码仓库。
5. 必须提供 `.env.example` 模板文件（不含实际值），纳入版本控制。
6. 环境变量必须定义 TypeScript 类型声明：

```typescript
// env.d.ts
declare module 'react-native-config' {
  export interface NativeConfig {
    API_BASE_URL: string;
    SENTRY_DSN: string;
    ENV: 'development' | 'staging' | 'production';
    CODEPUSH_KEY?: string;
  }
  const Config: NativeConfig;
  export default Config;
}
```

---

## 多环境配置（MUST）

1. 项目必须支持至少三套环境：`development` / `staging` / `production`。
2. 不同环境的差异项必须通过环境变量控制，禁止使用 `if-else` 硬编码判断环境。
3. 各环境差异项包括但不限于：

| 配置项 | development | staging | production |
|--------|------------|---------|------------|
| API 地址 | localhost / mock | staging-api.xxx.com | api.xxx.com |
| 日志级别 | debug | info | error |
| Sentry 上报 | 关闭 | 开启（采样率低） | 开启（全量） |
| CodePush | 关闭 | 开启（Staging） | 开启（Production） |
| Feature Flag | 全部开启 | 按配置 | 按配置 |

4. 环境切换必须通过构建命令参数实现，禁止运行时修改环境配置。

---

## 构建变体（MUST）

### Android
1. 必须配置 `build.gradle` 中的 `productFlavors` 区分环境：

```groovy
android {
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        production {
            dimension "environment"
        }
    }
}
```

2. 不同环境使用不同的 `applicationId`（Bundle ID），可在同一设备上并行安装。
3. 不同环境使用不同的应用图标和应用名称（如"MyApp-Dev"、"MyApp-STG"），方便测试人员区分。

### iOS
1. 必须使用 Xcode Scheme + Configuration 区分环境。
2. 每个环境对应独立的 Scheme（如 `MyApp-Dev`、`MyApp-Staging`、`MyApp-Production`）。
3. 不同环境使用不同的 Bundle Identifier。

---

## 签名管理（MUST）

1. 签名密钥（keystore / certificate）禁止提交到代码仓库。
2. `.gitignore` 必须包含 `*.keystore`、`*.jks`、`*.p12`、`*.mobileprovision`。
3. CI 环境中签名文件通过 Secret 注入，禁止明文存储在代码仓库或构建脚本中。
4. Android keystore 密码推荐通过 `gradle.properties`（本地）或 CI Secret（流水线）注入。
5. iOS 推荐使用 **Fastlane Match** 管理证书和 Provisioning Profile。

---

## Feature Flag（SHOULD）

1. 推荐使用远程配置服务（Firebase Remote Config / LaunchDarkly / 自建）管理 Feature Flag。
2. Feature Flag 必须设置默认值，服务端不可达时回退到默认值。
3. Feature Flag 必须有过期清理机制，功能稳定后移除 Flag 代码。
4. 禁止使用 Feature Flag 控制安全相关逻辑（如绕过权限校验）。

---

## 版本管理（MUST）

1. 应用版本号遵循语义化版本（SemVer）：`MAJOR.MINOR.PATCH`。
2. `versionCode`（Android）/ `CFBundleVersion`（iOS）必须单调递增，CI 自动生成。
3. 推荐使用 **react-native-version** 或脚本统一管理 `package.json`、`build.gradle`、`Info.plist` 中的版本号。
4. 每次发版必须打 Git Tag（如 `v1.2.3`），关联 Release Notes。

---

## App 配置文件（MUST）

1. `app.json` / `app.config.ts`（Expo）或 `package.json`（bare）中的元数据必须与应用商店配置一致。
2. 应用权限声明必须最小化，只声明实际使用的权限。
3. Android `AndroidManifest.xml` 与 iOS `Info.plist` 中的权限说明文案必须准确描述用途（否则审核被拒）。

---

## 禁止事项

1. 禁止将 `.env` 文件提交到代码仓库。
2. 禁止将 keystore / .p12 / 私钥文件提交到代码仓库。
3. 禁止在源码中硬编码 API 地址或密钥。
4. 禁止在运行时修改环境配置（必须通过构建变体控制）。
5. 禁止使用同一 applicationId / Bundle ID 部署不同环境。
