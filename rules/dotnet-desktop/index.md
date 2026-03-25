# rules/dotnet-desktop/index.md

## 目的
1. 统一 C#/.NET 桌面应用开发与交付标准，降低架构漂移和协作成本。
2. 采用"共性规则 + 框架规则"模式，避免重复和冲突。

## 适用范围
1. 适用于所有 C#/.NET 桌面客户端代码：WPF、.NET MAUI（桌面端）、WinForms。
2. 本规则默认高于个人编码习惯；若需例外，必须在评审中记录原因、边界、回收时间。

## 规则组成
1. `common`：所有 C#/.NET 桌面应用必须遵守。
2. `profiles/wpf`：WPF 项目额外规则。
3. `profiles/maui`：.NET MAUI 项目额外规则。
4. `profiles/winforms`：WinForms 项目额外规则。

## 适用方式
1. WPF 项目：`common + profiles/wpf`。
2. .NET MAUI 项目：`common + profiles/maui`。
3. WinForms 项目：`common + profiles/winforms`。
4. 混合框架（同仓多项目）：每个可执行程序独立选择 profile，不得混用一套架构定义。

## Skill 协作（推荐）
1. 编写 C#/.NET 桌面应用代码时优先使用 `$dotnet-desktop-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 规则维护优先使用 `$dotnet-desktop-rules-maintainer`。

## 冲突优先级
1. 具体 profile 规则优先于 `common` 中同主题的描述。
2. 数据库变更规则以 `rules/database/database.md` 为准。
3. 当规则冲突无法消解时，以"更严格、更可验证"的规则为准。

## 目录索引

### 通用规则（common）— 所有 C#/.NET 桌面应用必须遵守
1. `common/baseline.md` — 技术基线与基础工程要求
2. `common/code-style.md` — 命名、注释、调试代码清理
3. `common/architecture.md` — MVVM/MVP 架构、分层规则、依赖注入
4. `common/error-handling.md` — 异常分类、全局异常处理、用户反馈
5. `common/threading-and-ui.md` — UI 线程模型、后台任务、异步编程
6. `common/data-access.md` — 本地数据库、远程 API 调用、离线支持
7. `common/configuration.md` — 应用配置、用户设置、环境管理
8. `common/security.md` — 本地数据保护、凭据存储、输入校验
9. `common/observability.md` — 日志、崩溃报告、使用遥测
10. `common/performance.md` — UI 响应性、内存管理、启动优化
11. `common/testing-and-release.md` — 测试策略、打包分发、自动更新
12. `common/auto-update.md` — 自动更新方案（Velopack）
13. `common/forbidden.md` — 禁止事项汇总

### 框架专属规则（profiles）
14. `profiles/wpf/project-structure.md` — WPF 项目结构与 MVVM 实践
15. `profiles/maui/project-structure.md` — .NET MAUI 项目结构与跨平台适配
16. `profiles/winforms/project-structure.md` — WinForms 项目结构与 MVP 实践

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/dotnet-desktop/pr-review-checklist.md` — C#/.NET 桌面应用 PR 评审清单
- `templates/exception-request-template.md` — 规范例外申请模板（通用）
