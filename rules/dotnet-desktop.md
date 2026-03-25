# rules/dotnet-desktop.md

本文件保留为兼容入口，详细规则已拆分到目录化规范。

## 阅读入口
1. 总入口：`rules/dotnet-desktop/index.md`
2. 通用规则：`rules/dotnet-desktop/common/`
3. WPF 规则：`rules/dotnet-desktop/profiles/wpf/`
4. .NET MAUI 规则：`rules/dotnet-desktop/profiles/maui/`
5. WinForms 规则：`rules/dotnet-desktop/profiles/winforms/`

## 使用方式
1. 所有 C#/.NET 桌面应用项目必须先遵守 `common`。
2. WPF 项目再叠加 `profiles/wpf`。
3. .NET MAUI 项目再叠加 `profiles/maui`。
4. WinForms 项目再叠加 `profiles/winforms`。
5. 编写代码时使用 `$dotnet-desktop-coding-guide` 按编码场景自动加载对应规则。
6. 跨域业务任务使用 `$task-router` 自动路由到涉及的域。
7. 涉及后端 API 交互时建议参考 `rules/dotnet-server/common/api-design.md` 中的契约规范。
