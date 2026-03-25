# rules/android/common/baseline.md

## 技术基线
1. Kotlin 版本以项目根目录 `gradle/libs.versions.toml` 中声明为准，推荐最新 stable 版本，升级版本必须单独提交并验证兼容性。
2. 新项目必须使用 **Kotlin** 作为主语言，禁止新建 Java 源文件。
3. Android Gradle Plugin（AGP）版本与 Android Studio 保持兼容，升级须单独提交。
4. `compileSdk` 必须跟进最新稳定版 API Level。
5. `targetSdk` 必须满足 Google Play 最新上架要求。
6. `minSdk` 由项目根据用户分布确定，推荐 API 24（Android 7.0）及以上。

## 构建工具要求（MUST）

1. 必须使用 **Gradle Kotlin DSL**（`build.gradle.kts`），禁止新项目使用 Groovy DSL。
2. 必须使用 **Version Catalog**（`gradle/libs.versions.toml`）统一管理依赖版本。
3. 多模块项目必须使用 **Convention Plugins** 抽取公共构建逻辑。
4. 提交前必须确保 `./gradlew build` 无错误。

## 依赖管理（MUST）

1. 禁止使用 `+` 动态版本号（如 `1.0.+`），所有依赖必须锁定具体版本。
2. 第三方依赖引入必须经过团队评审，评估维护状态、许可证、安全性。
3. 必须定期执行依赖漏洞扫描（推荐 `dependencyCheck` 或 Snyk），高危漏洞阻断合并。
4. 禁止在 `app` 模块直接声明 `api` 传递依赖，应通过 `implementation` 隔离。

## 静态分析（MUST）

1. 必须集成 **ktlint** 进行代码格式化检查。
2. 必须集成 **detekt** 进行静态代码分析，配置文件纳入版本控制。
3. CI 流水线必须执行 `./gradlew ktlintCheck` 和 `./gradlew detekt`，失败阻断合并。
4. 推荐集成 **Android Lint**（`./gradlew lint`），`Severity=Error` 级别问题阻断合并。
