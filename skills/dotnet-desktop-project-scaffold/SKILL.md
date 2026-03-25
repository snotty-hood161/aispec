---
name: dotnet-desktop-project-scaffold
description: 根据框架类型自动初始化 C#/.NET 桌面应用项目结构。用于新项目启动时，输入框架类型（wpf / maui / winforms）后自动读取对应规则，生成目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# .NET 桌面应用项目脚手架

## 域参数

- **domain**: dotnet-desktop
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 框架
- **supported_modes**:
  - `wpf` — WPF 桌面应用（MVVM + CommunityToolkit.Mvvm）
  - `maui` — .NET MAUI 跨平台应用（CommunityToolkit.Maui）
  - `winforms` — WinForms 桌面应用（MVP 模式）

## 资源
1. 脚手架映射：`references/scaffold-map.md`
