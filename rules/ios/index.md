# rules/ios/index.md

## 目的
1. 统一 Swift/Objective-C iOS 原生应用开发与交付标准，降低架构漂移和协作成本。
2. 采用"共性规则 + UI 框架规则"模式，避免重复和冲突。

## 适用范围
1. 适用于所有 iOS 原生应用项目代码（Swift 首选，Objective-C 仅限旧项目维护）。
2. 本规则默认高于个人编码习惯；若需例外，必须在评审中记录原因、边界、回收时间。

## 规则组成
1. `common`：所有 iOS 应用必须遵守。
2. `profiles/swiftui`：SwiftUI 项目额外规则与项目结构。
3. `profiles/uikit`：UIKit 项目额外规则与项目结构。

## 适用方式
1. SwiftUI 项目：`common + profiles/swiftui`。
2. UIKit 项目：`common + profiles/uikit`。
3. 混合项目（SwiftUI + UIKit）：`common + profiles/swiftui`，UIKit 部分参考 `profiles/uikit`。

## Skill 协作（推荐）
1. 编写 iOS 应用代码时优先使用 `$ios-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 规则维护优先使用 `$ios-rules-maintainer`。
4. 涉及远程 API 调用时优先使用 `$frontend-backend-coding-guide`。

## 冲突优先级
1. 具体 profile 规则优先于 `common` 中同主题的描述。
2. 当规则冲突无法消解时，以"更严格、更可验证"的规则为准。

## 目录索引

### 通用规则（common）— 所有 iOS 应用必须遵守
1. `common/baseline.md` — 技术基线与基础工程要求
2. `common/code-style.md` — Swift 命名、格式化、静态分析
3. `common/architecture.md` — 分层架构、依赖注入、数据流
4. `common/error-handling.md` — 错误建模、异常处理、用户提示
5. `common/security.md` — Keychain、ATS、代码签名、数据保护
6. `common/data-access.md` — 数据持久化、网络请求、文件管理
7. `common/configuration.md` — Xcode 配置、xcconfig、环境管理
8. `common/observability.md` — 日志、崩溃报告、性能监控
9. `common/performance.md` — 启动优化、内存管理、渲染性能
10. `common/testing-and-release.md` — 测试策略、CI/CD、发布流程
11. `common/ui-framework.md` — Human Interface Guidelines、无障碍、适配
12. `common/forbidden.md` — 禁止事项汇总

### 框架专属规则（profiles）
13. `profiles/swiftui/project-structure.md` — SwiftUI 项目结构与最佳实践
14. `profiles/uikit/project-structure.md` — UIKit 项目结构

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/ios/pr-review-checklist.md` — iOS 应用 PR 评审清单
- `templates/exception-request-template.md` — 规范例外申请模板（通用）
