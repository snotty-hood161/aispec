# Android 编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/android/common/baseline.md`
- `rules/android/common/forbidden.md`

---

## A. 新增 Activity / Fragment / Screen
- 主文件：`rules/android/common/architecture.md`
- 关联文件：`rules/android/common/code-style.md`
- Profile：当前 profile 的 `project-structure.md`

## B. UI 组件开发（Compose Composable / XML Layout）
- 主文件：`rules/android/common/ui-framework.md`
- 关联文件：`rules/android/common/performance.md`
- Profile：`profiles/compose/project-structure.md` 或 `profiles/xml-views/project-structure.md`

## C. 数据层（Room / 网络请求 / Repository）
- 主文件：`rules/android/common/data-access.md`
- 关联文件：`rules/android/common/error-handling.md`、`rules/android/common/security.md`
- 跨域：涉及服务端 API → 参考 `rules/frontend-backend-collaboration.md`

## D. ViewModel / 状态管理
- 主文件：`rules/android/common/architecture.md`
- 关联文件：`rules/android/common/error-handling.md`

## E. 依赖注入（Hilt / Koin）
- 主文件：`rules/android/common/architecture.md`
- 关联文件：`rules/android/common/code-style.md`

## F. 错误处理 / 用户提示
- 主文件：`rules/android/common/error-handling.md`
- 关联文件：`rules/android/common/observability.md`

## G. 安全（混淆 / 安全存储 / 网络安全）
- 主文件：`rules/android/common/security.md`
- 关联文件：`rules/android/common/configuration.md`

## H. 构建配置（Flavor / 签名 / 变体）
- 主文件：`rules/android/common/configuration.md`
- 关联文件：`rules/android/common/testing-and-release.md`

## I. 日志 / 崩溃报告 / 性能监控
- 主文件：`rules/android/common/observability.md`
- 关联文件：`rules/android/common/error-handling.md`

## J. 性能优化（启动 / 内存 / 电量）
- 主文件：`rules/android/common/performance.md`
- 关联文件：`rules/android/common/ui-framework.md`

## K. 测试 / CI / 发布
- 主文件：`rules/android/common/testing-and-release.md`
- 关联文件：`rules/android/common/code-style.md`
- 模板：`rules/templates/android/pr-review-checklist.md`

## L. 初始化项目结构
- 主文件：当前 profile 的 `project-structure.md`
- 关联文件：`rules/android/common/architecture.md`
- 建议：使用 `$android-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 同时命中多个场景时，合并去重，总量不超过 8 个。
