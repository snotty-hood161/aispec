# iOS 编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/ios/common/baseline.md`
- `rules/ios/common/forbidden.md`

---

## A. 新增页面 / ViewController / SwiftUI View
- 主文件：`rules/ios/common/architecture.md`
- 关联文件：`rules/ios/common/code-style.md`
- Profile：当前 profile 的 `project-structure.md`

## B. UI 组件开发（SwiftUI View / UIView）
- 主文件：`rules/ios/common/ui-framework.md`
- 关联文件：`rules/ios/common/performance.md`

## C. 数据层（CoreData / 网络请求 / Repository）
- 主文件：`rules/ios/common/data-access.md`
- 关联文件：`rules/ios/common/error-handling.md`、`rules/ios/common/security.md`
- 跨域：涉及服务端 API → 参考 `rules/frontend-backend-collaboration.md`

## D. 状态管理 / 数据流
- 主文件：`rules/ios/common/architecture.md`
- 关联文件：`rules/ios/common/error-handling.md`

## E. 依赖注入
- 主文件：`rules/ios/common/architecture.md`
- 关联文件：`rules/ios/common/code-style.md`

## F. 错误处理 / 用户提示
- 主文件：`rules/ios/common/error-handling.md`
- 关联文件：`rules/ios/common/observability.md`

## G. 安全（Keychain / ATS / 代码签名）
- 主文件：`rules/ios/common/security.md`
- 关联文件：`rules/ios/common/configuration.md`

## H. Xcode 配置 / xcconfig / 环境管理
- 主文件：`rules/ios/common/configuration.md`
- 关联文件：`rules/ios/common/testing-and-release.md`

## I. 日志 / 崩溃报告 / 性能监控
- 主文件：`rules/ios/common/observability.md`
- 关联文件：`rules/ios/common/error-handling.md`

## J. 性能优化（启动 / 内存 / 渲染）
- 主文件：`rules/ios/common/performance.md`
- 关联文件：`rules/ios/common/ui-framework.md`

## K. 测试 / CI / 发布
- 主文件：`rules/ios/common/testing-and-release.md`
- 关联文件：`rules/ios/common/code-style.md`
- 模板：`rules/templates/ios/pr-review-checklist.md`

## L. 初始化项目结构
- 主文件：当前 profile 的 `project-structure.md`
- 关联文件：`rules/ios/common/architecture.md`
- 建议：使用 `$ios-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 同时命中多个场景时，合并去重，总量不超过 8 个。
