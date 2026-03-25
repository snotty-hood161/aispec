# 脚手架映射表（UI 框架 → 规则与模板文件）

本文件定义每种 UI 框架初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认 UI 框架后，按下表加载对应文件。
2. "通用必读"对所有 UI 框架生效。

---

## 一、通用必读（所有 UI 框架）

### iOS 规则
| 文件 | 用途 |
|------|------|
| `rules/ios/common/baseline.md` | Swift 版本、Xcode 版本、依赖管理 |
| `rules/ios/common/code-style.md` | Swift 命名、SwiftLint 配置 |
| `rules/ios/common/architecture.md` | MVVM 分层、依赖注入 |
| `rules/ios/common/security.md` | Keychain、ATS、代码签名 |
| `rules/ios/common/error-handling.md` | 错误建模与异常处理 |
| `rules/ios/common/configuration.md` | xcconfig、Info.plist |
| `rules/ios/common/data-access.md` | SwiftData、URLSession |
| `rules/ios/common/observability.md` | os.Logger、Crashlytics |
| `rules/ios/common/performance.md` | 启动/内存/ARC 优化 |
| `rules/ios/common/testing-and-release.md` | XCTest、CI/CD、App Store |
| `rules/ios/common/ui-framework.md` | HIG、无障碍、Dynamic Type |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/ios/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、UI 框架差异

| 框架 | Profile 规则 | 入口组件 | 导航方案 | 状态管理 |
|------|-------------|---------|---------|---------|
| `swiftui` | `profiles/swiftui/project-structure.md` | @main App + ContentView | NavigationStack | @StateObject + @Published |
| `uikit` | `profiles/uikit/project-structure.md` | AppDelegate + SceneDelegate | Coordinator + Navigation Controller | Combine + @Published |

### 技术栈（通用）
- 语言：Swift
- 依赖管理：Swift Package Manager
- 网络：URLSession + async/await
- 数据库：SwiftData / Core Data
- 测试：XCTest / swift-testing
- CI：Fastlane + GitHub Actions

---

## 三、生成产物清单（通用）

每种 UI 框架初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/*/project-structure.md` |
| `.xcconfig` 配置文件 | `common/configuration.md` |
| `.swiftlint.yml` | `common/code-style.md` |
| `.swiftformat` | `common/code-style.md` |
| `Package.swift`（依赖）| `common/baseline.md` |
| `.gitignore` | `common/security.md` |
| `Fastfile` | `common/testing-and-release.md` |
