# 主题落点映射（需求 -> 规则文件）

用此表将用户需求映射到"主定义文件"，避免多文件重复修改。

## 通用主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| 技术基线/TypeScript 工具链 | `common/baseline.md` | `common/forbidden.md` |
| 主进程/preload 代码风格 | `common/code-style.md` | `profiles/*/project-structure.md` |
| 主进程/渲染进程分层/模块架构 | `common/architecture.md` | `common/code-style.md`, `common/performance.md` |
| 主进程错误处理/渲染进程错误边界 | `common/error-handling.md` | `common/forbidden.md`, `common/observability.md` |
| contextIsolation/nodeIntegration/CSP/沙箱 | `common/security.md` | `common/configuration.md`, `common/forbidden.md` |
| IPC 通信设计（invoke/handle/send） | `common/ipc-communication.md` | `common/security.md`, `common/architecture.md` |
| 配置/用户设置/凭据管理 | `common/configuration.md` | `common/security.md` |
| 日志/崩溃报告 | `common/observability.md` | `common/error-handling.md` |
| 启动/内存/IPC 性能优化 | `common/performance.md` | `common/architecture.md`, `common/code-style.md` |
| electron-updater 自动更新 | `common/auto-update.md` | `common/security.md`, `common/testing-and-release.md` |
| 测试/CI/CD/发布 | `common/testing-and-release.md` | `common/auto-update.md` |
| 禁止项（反模式） | `common/forbidden.md` | 各主题文件（反向校验） |

## Profile 主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| Electron v30+ 项目结构 | `profiles/electron-v30/project-structure.md` | `common/code-style.md`, `common/architecture.md` |

## 冲突决策
1. 同主题冲突：`profile` 规则优先于 `common`。
2. 无法消解：采用"更严格且可验证"的规则并在输出中标注。
