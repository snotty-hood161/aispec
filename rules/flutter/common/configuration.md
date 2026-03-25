# rules/flutter/common/configuration.md

## 文档目标
1. 定义 Flutter 应用的构建配置、环境管理与签名规范。

---

## 构建变体（MUST）

1. 必须支持至少三个环境：`dev` / `staging` / `prod`。
2. 环境配置通过 `--dart-define` 或 `--dart-define-from-file` 注入，禁止硬编码：

```bash
# 命令行注入
flutter run --dart-define=API_BASE_URL=https://api-dev.example.com --dart-define=ENV=dev

# 配置文件注入（推荐）
flutter run --dart-define-from-file=config/dev.json
```

3. Dart 代码中通过 `String.fromEnvironment` 读取配置：

```dart
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  static bool get isProduction => environment == 'prod';
}
```

4. 禁止在 Dart 源码中硬编码环境 URL / API Key，必须通过构建时注入。

---

## Android 构建配置（MUST）

1. 使用 Gradle Flavor 区分环境（与 `--dart-define` 配合）：
   - `dev` / `staging` / `prod` 三个 Flavor。
   - 每个 Flavor 配置独立的 `applicationId` 后缀（如 `.dev`、`.staging`），允许多环境并装。
2. 签名配置：
   - 开发使用 debug keystore。
   - 生产使用独立 keystore，密码通过环境变量 / CI Secret 注入。
   - keystore 文件禁止提交到代码仓库。
3. `versionCode` 必须单调递增，`versionName` 使用语义化版本。

---

## iOS 构建配置（MUST）

1. 使用 Xcode Scheme + xcconfig 区分环境：
   - 每个环境对应独立的 Bundle Identifier 后缀。
   - 配置文件（`Debug.xcconfig` / `Release.xcconfig`）纳入版本控制。
2. 签名配置：
   - 推荐使用 **Fastlane Match** 管理证书与描述文件。
   - 禁止手动管理证书，必须通过自动签名或 CI 脚本管理。
   - 证书与私钥禁止提交到代码仓库。
3. `CFBundleVersion` 必须单调递增。

---

## Feature Flag（SHOULD）

1. 推荐使用 Feature Flag 控制功能开关，支持远程动态下发。
2. 可选方案：Firebase Remote Config / 自建配置中心。
3. Feature Flag 代码中定义默认值，远程不可达时使用默认值降级。
4. 已全量发布的 Feature Flag 必须在后续版本中清理。

---

## 禁止事项

1. 禁止在 Dart 源码中硬编码环境配置（URL / Key / Secret）。
2. 禁止将 keystore / .p12 / 私钥文件提交到代码仓库。
3. 禁止在 dev 环境使用生产环境 API Key。
4. 禁止省略 `versionCode` / `CFBundleVersion` 递增检查。
