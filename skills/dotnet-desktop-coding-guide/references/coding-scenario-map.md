# .NET 桌面编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/dotnet-desktop/common/baseline.md`
- `rules/dotnet-desktop/common/forbidden.md`

---

## A. 新增窗口/页面（ViewModel + View）
- 主文件：`rules/dotnet-desktop/common/architecture.md`
- 关联文件：`rules/dotnet-desktop/common/code-style.md`
- Profile：当前 profile 的 `project-structure.md`

## B. 数据绑定 / ViewModel 逻辑
- 主文件：`rules/dotnet-desktop/common/architecture.md`
- 关联文件：`rules/dotnet-desktop/common/threading-and-ui.md`

## C. UI 线程 / 后台任务 / 异步操作
- 主文件：`rules/dotnet-desktop/common/threading-and-ui.md`
- 关联文件：`rules/dotnet-desktop/common/error-handling.md`、`rules/dotnet-desktop/common/performance.md`

## D. 本地数据存储 / 远程 API 调用
- 主文件：`rules/dotnet-desktop/common/data-access.md`
- 关联文件：`rules/dotnet-desktop/common/security.md`、`rules/dotnet-desktop/common/error-handling.md`
- 跨域：涉及服务端 API → 参考 `rules/frontend-backend-collaboration.md`

## E. 异常处理 / 全局错误捕获
- 主文件：`rules/dotnet-desktop/common/error-handling.md`
- 关联文件：`rules/dotnet-desktop/common/observability.md`

## F. 应用配置 / 用户设置
- 主文件：`rules/dotnet-desktop/common/configuration.md`
- 关联文件：`rules/dotnet-desktop/common/security.md`

## G. 安全（凭据存储 / 数据保护）
- 主文件：`rules/dotnet-desktop/common/security.md`
- 关联文件：`rules/dotnet-desktop/common/data-access.md`

## H. 日志 / 崩溃报告 / 遥测
- 主文件：`rules/dotnet-desktop/common/observability.md`
- 关联文件：`rules/dotnet-desktop/common/error-handling.md`

## I. 性能优化（启动 / 内存 / 渲染）
- 主文件：`rules/dotnet-desktop/common/performance.md`
- 关联文件：`rules/dotnet-desktop/common/threading-and-ui.md`

## J. 自动更新（Velopack）
- 主文件：`rules/dotnet-desktop/common/auto-update.md`
- 关联文件：`rules/dotnet-desktop/common/testing-and-release.md`

## K. 测试 / 打包发布
- 主文件：`rules/dotnet-desktop/common/testing-and-release.md`
- 关联文件：`rules/dotnet-desktop/common/code-style.md`
- 模板：`rules/templates/dotnet-desktop/pr-review-checklist.md`

## L. 初始化项目结构
- 主文件：当前 profile 的 `project-structure.md`
- 关联文件：`rules/dotnet-desktop/common/architecture.md`
- 建议：使用 `$dotnet-desktop-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 同时命中多个场景时，合并去重，总量不超过 8 个。
