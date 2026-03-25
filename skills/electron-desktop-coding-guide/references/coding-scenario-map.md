# Electron 桌面编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/electron-desktop/common/baseline.md`
- `rules/electron-desktop/common/forbidden.md`

---

## A. 主进程 IPC Handler
- 主文件：`rules/electron-desktop/common/ipc-communication.md`
- 关联文件：`rules/electron-desktop/common/architecture.md`、`rules/electron-desktop/common/error-handling.md`

## B. preload 脚本（contextBridge）
- 主文件：`rules/electron-desktop/common/security.md`
- 关联文件：`rules/electron-desktop/common/ipc-communication.md`、`rules/electron-desktop/common/architecture.md`

## C. 窗口管理（BrowserWindow）
- 主文件：`rules/electron-desktop/common/architecture.md`
- 关联文件：`rules/electron-desktop/common/security.md`、`rules/electron-desktop/common/performance.md`

## D. 安全配置（contextIsolation / CSP / sandbox）
- 主文件：`rules/electron-desktop/common/security.md`
- 关联文件：`rules/electron-desktop/common/configuration.md`

## E. 主进程错误处理
- 主文件：`rules/electron-desktop/common/error-handling.md`
- 关联文件：`rules/electron-desktop/common/observability.md`

## F. 应用配置 / 用户设置
- 主文件：`rules/electron-desktop/common/configuration.md`
- 关联文件：`rules/electron-desktop/common/security.md`

## G. 日志 / 崩溃报告
- 主文件：`rules/electron-desktop/common/observability.md`
- 关联文件：`rules/electron-desktop/common/error-handling.md`

## H. 性能优化（启动 / 内存 / IPC）
- 主文件：`rules/electron-desktop/common/performance.md`
- 关联文件：`rules/electron-desktop/common/architecture.md`

## I. 自动更新（electron-updater）
- 主文件：`rules/electron-desktop/common/auto-update.md`
- 关联文件：`rules/electron-desktop/common/testing-and-release.md`

## J. 测试 / 打包分发
- 主文件：`rules/electron-desktop/common/testing-and-release.md`
- 关联文件：`rules/electron-desktop/common/code-style.md`
- 模板：`rules/templates/electron-desktop/pr-review-checklist.md`

## K. 初始化项目结构
- 主文件：`rules/electron-desktop/profiles/electron-v30/project-structure.md`
- 关联文件：`rules/electron-desktop/common/architecture.md`
- 建议：使用 `$electron-desktop-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 渲染进程前端代码以 `rules/frontend` 为准。
