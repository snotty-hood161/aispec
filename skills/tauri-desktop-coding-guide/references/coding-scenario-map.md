# Tauri 桌面编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/tauri-desktop/common/baseline.md`
- `rules/tauri-desktop/common/forbidden.md`

---

## A. Rust 后端命令（IPC Command）
- 主文件：`rules/tauri-desktop/common/architecture.md`
- 关联文件：`rules/tauri-desktop/common/code-style.md`、`rules/tauri-desktop/common/error-handling.md`

## B. 前后端 IPC 通信（invoke / event）
- 主文件：`rules/tauri-desktop/common/architecture.md`
- 关联文件：`rules/tauri-desktop/common/security.md`

## C. 安全权限配置（tauri.conf.json / CSP）
- 主文件：`rules/tauri-desktop/common/security.md`
- 关联文件：`rules/tauri-desktop/common/configuration.md`

## D. 本地数据存储 / 远程 API 调用
- 主文件：`rules/tauri-desktop/common/data-access.md`
- 关联文件：`rules/tauri-desktop/common/error-handling.md`、`rules/tauri-desktop/common/security.md`

## E. Rust 错误处理
- 主文件：`rules/tauri-desktop/common/error-handling.md`
- 关联文件：`rules/tauri-desktop/common/observability.md`

## F. 应用配置 / 用户设置
- 主文件：`rules/tauri-desktop/common/configuration.md`
- 关联文件：`rules/tauri-desktop/common/security.md`

## G. 日志 / 崩溃报告
- 主文件：`rules/tauri-desktop/common/observability.md`
- 关联文件：`rules/tauri-desktop/common/error-handling.md`

## H. 性能优化（启动 / 内存 / 渲染）
- 主文件：`rules/tauri-desktop/common/performance.md`
- 关联文件：`rules/tauri-desktop/common/architecture.md`

## I. 自动更新（Tauri Updater Plugin）
- 主文件：`rules/tauri-desktop/common/auto-update.md`
- 关联文件：`rules/tauri-desktop/common/testing-and-release.md`

## J. 测试 / 打包分发
- 主文件：`rules/tauri-desktop/common/testing-and-release.md`
- 关联文件：`rules/tauri-desktop/common/code-style.md`
- 模板：`rules/templates/tauri-desktop/pr-review-checklist.md`

## K. 初始化项目结构
- 主文件：`rules/tauri-desktop/profiles/tauri-v2/project-structure.md`
- 关联文件：`rules/tauri-desktop/common/architecture.md`
- 建议：使用 `$tauri-desktop-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 前端代码以 `rules/frontend` 为准。
