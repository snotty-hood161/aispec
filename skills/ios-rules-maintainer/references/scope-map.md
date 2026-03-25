# 主题落点映射（需求 -> 规则文件）

用此表将用户需求映射到"主定义文件"，避免多文件重复修改。

## 通用主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| 技术基线/Swift 版本/Xcode | `common/baseline.md` | `common/forbidden.md` |
| Swift 代码风格/SwiftLint/SwiftFormat | `common/code-style.md` | `profiles/*/project-structure.md` |
| 分层架构/MVVM/依赖注入 | `common/architecture.md` | `common/code-style.md`, `common/performance.md` |
| 错误建模/async throws/Error 协议 | `common/error-handling.md` | `common/forbidden.md`, `common/observability.md` |
| Keychain/ATS/代码签名 | `common/security.md` | `common/configuration.md`, `common/forbidden.md` |
| SwiftData/URLSession/UserDefaults | `common/data-access.md` | `common/code-style.md`, `profiles/*/project-structure.md` |
| xcconfig/Info.plist/Configuration | `common/configuration.md` | `common/security.md`, `common/data-access.md` |
| os.Logger/Crashlytics/MetricKit | `common/observability.md` | `common/error-handling.md` |
| 启动/内存/ARC/渲染优化 | `common/performance.md` | `common/architecture.md`, `common/code-style.md` |
| XCTest/CI/CD/App Store 发布 | `common/testing-and-release.md` | `common/configuration.md` |
| HIG/无障碍/Dynamic Type | `common/ui-framework.md` | `profiles/*/project-structure.md` |
| 禁止项（反模式） | `common/forbidden.md` | 各主题文件（反向校验） |

## Profile 主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| SwiftUI 项目结构 | `profiles/swiftui/project-structure.md` | `common/code-style.md`, `common/architecture.md` |
| UIKit 项目结构 | `profiles/uikit/project-structure.md` | `common/code-style.md`, `common/architecture.md` |

## 冲突决策
1. 同主题冲突：`profile` 规则优先于 `common`。
2. 无法消解：采用"更严格且可验证"的规则并在输出中标注。
