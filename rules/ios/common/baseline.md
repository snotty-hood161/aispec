# rules/ios/common/baseline.md

## 技术基线
1. Swift 版本以项目 `.swift-version` 文件或 `Package.swift` 中声明为准，推荐最新 stable 版本，升级版本必须单独提交并验证兼容性。
2. 新项目必须使用 **Swift** 作为主语言，禁止新建 Objective-C 源文件。
3. Xcode 版本与 Apple 最新稳定版保持同步，团队统一版本号。
4. 最低部署目标（Deployment Target）由项目根据用户分布确定，推荐 iOS 16+。
5. 推荐使用 Swift 6 严格并发检查（`SWIFT_STRICT_CONCURRENCY = complete`）。

## 依赖管理（MUST）

1. 首选 **Swift Package Manager**（SPM）管理依赖。
2. 已有 CocoaPods 项目允许继续使用，新依赖优先通过 SPM 引入。
3. 禁止同时使用 SPM + CocoaPods + Carthage 三种方式（最多两种共存，并有迁移计划）。
4. 所有依赖必须锁定具体版本或版本范围（`.upToNextMinor`），禁止 `.upToNextMajor` 宽泛范围。
5. 第三方依赖引入必须经过团队评审，评估维护状态、许可证、安全性。

## 项目配置（MUST）

1. 必须使用 `.xcconfig` 文件管理 Build Settings，禁止在 Xcode GUI 中手动修改 Build Settings。
2. 项目必须支持通过命令行构建（`xcodebuild` 或 Fastlane）。
3. `.gitignore` 必须排除 `xcuserdata/`、`DerivedData/`、`Pods/`（如使用 CocoaPods）。
4. Xcode 项目文件（`.pbxproj`）冲突频繁时，推荐使用 `XcodeGen` 或 `Tuist` 生成。

## 静态分析（MUST）

1. 必须集成 **SwiftLint** 进行代码风格与规范检查。
2. SwiftLint 配置文件（`.swiftlint.yml`）纳入版本控制。
3. 推荐集成 **SwiftFormat** 进行自动格式化。
4. CI 流水线必须执行 `swiftlint lint --strict`，warning 视为 error 阻断合并。
5. 推荐启用 Xcode 静态分析器（Analyze，`⇧⌘B`），定期执行。
