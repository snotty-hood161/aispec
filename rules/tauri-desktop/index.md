# rules/tauri-desktop/index.md

## 目的
1. 统一 Rust + Tauri 桌面应用开发与交付标准，降低架构漂移和协作成本。
2. 采用"共性规则 + 框架规则"模式，避免重复和冲突。

## 适用范围
1. 适用于所有基于 Tauri 框架的桌面客户端代码（Rust 后端 + Web 前端）。
2. 本规则默认高于个人编码习惯；若需例外，必须在评审中记录原因、边界、回收时间。

## 规则组成
1. `common`：所有 Tauri 桌面应用必须遵守。
2. `profiles/tauri-v2`：Tauri v2 项目额外规则与项目结构。

## 适用方式
1. Tauri v2 项目：`common + profiles/tauri-v2`。
2. 前端框架不限（React/Vue/Svelte/Solid），但前端代码需同时遵守 `rules/frontend` 中的对应规范。

## Skill 协作（推荐）
1. 编写 Tauri 桌面应用代码时优先使用 `$tauri-desktop-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 规则维护优先使用 `$tauri-desktop-rules-maintainer`。
4. 前端代码优先使用 `$frontend-coding-guide`。
5. 涉及远程 API 调用时优先使用 `$frontend-backend-coding-guide`。

## 冲突优先级
1. 具体 profile 规则优先于 `common` 中同主题的描述。
2. 前端代码规范以 `rules/frontend` 为准，本规则仅约束 Tauri 特有部分。
3. 当规则冲突无法消解时，以"更严格、更可验证"的规则为准。

## 目录索引

### 通用规则（common）— 所有 Tauri 桌面应用必须遵守
1. `common/baseline.md` — 技术基线与基础工程要求
2. `common/code-style.md` — Rust 命名、格式化、Clippy 规则
3. `common/architecture.md` — 前后端分层、IPC 通信、状态管理
4. `common/error-handling.md` — Rust 错误处理、前端错误边界
5. `common/security.md` — 权限模型、CSP、文件系统隔离
6. `common/data-access.md` — 本地数据库、远程 API、离线支持
7. `common/configuration.md` — 应用配置、用户设置、环境管理
8. `common/observability.md` — 日志、崩溃报告、遥测
9. `common/performance.md` — 启动优化、内存管理、渲染性能
10. `common/auto-update.md` — 自动更新方案（Tauri Updater Plugin）
11. `common/testing-and-release.md` — 测试策略、打包分发、CI/CD
12. `common/forbidden.md` — 禁止事项汇总

### 框架专属规则（profiles）
13. `profiles/tauri-v2/project-structure.md` — Tauri v2 项目结构与最佳实践

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/tauri-desktop/pr-review-checklist.md` — Tauri 桌面应用 PR 评审清单
- `templates/exception-request-template.md` — 规范例外申请模板（通用）
