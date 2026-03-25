# 主题落点映射（需求 -> 规则文件）

用此表将用户需求映射到"主定义文件"，避免多文件重复修改。

## 通用主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| 技术基线/通用约束 | `common/baseline.md` | `common/forbidden.md` |
| 代码风格/分层边界 | `common/code-style.md` | `profiles/*/project-structure.md` |
| MVVM/MVP 架构 | `common/architecture.md` | `common/code-style.md`, `profiles/*/project-structure.md` |
| 异常处理 | `common/error-handling.md` | `common/forbidden.md`, `common/observability.md` |
| UI 线程/异步 | `common/threading-and-ui.md` | `common/performance.md`, `common/error-handling.md` |
| 数据访问 | `common/data-access.md` | `common/code-style.md`, `profiles/*/project-structure.md` |
| 配置/设置 | `common/configuration.md` | `common/data-access.md` |
| 安全 | `common/security.md` | `common/error-handling.md`, `common/configuration.md` |
| 日志/崩溃报告 | `common/observability.md` | `common/error-handling.md` |
| 性能 | `common/performance.md` | `common/threading-and-ui.md`, `common/code-style.md` |
| 测试/发布 | `common/testing-and-release.md` | `common/performance.md` |
| 自动更新 | `common/auto-update.md` | `common/security.md`, `common/configuration.md` |
| 禁止项（反模式） | `common/forbidden.md` | 各主题文件（反向校验） |

## Profile 主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| WPF MVVM 与项目结构 | `profiles/wpf/project-structure.md` | `common/architecture.md`, `common/code-style.md` |
| MAUI Shell 导航与项目结构 | `profiles/maui/project-structure.md` | `common/architecture.md`, `common/threading-and-ui.md` |
| WinForms MVP 与项目结构 | `profiles/winforms/project-structure.md` | `common/architecture.md`, `common/code-style.md` |

## 冲突决策
1. 同主题冲突：`profile` 规则优先于 `common`。
2. 架构模式冲突：以对应 `profile` 的 `project-structure.md` 为准。
3. 无法消解：采用"更严格且可验证"的规则并在输出中标注。
