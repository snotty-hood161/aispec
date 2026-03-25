# 脚手架映射表（框架类型 → 规则与模板文件）

本文件定义每种框架类型初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认框架类型后，按下表加载对应文件。
2. "通用必读"对所有框架类型生效。
3. "专项文件"仅对特定框架类型生效。

---

## 一、通用必读（所有框架类型）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-desktop/common/baseline.md` | .NET 版本、项目结构、格式化要求 |
| `rules/dotnet-desktop/common/code-style.md` | 命名、注释、分层编码 |
| `rules/dotnet-desktop/common/architecture.md` | 应用架构与分层模式 |
| `rules/dotnet-desktop/common/error-handling.md` | 异常分类与传播 |
| `rules/dotnet-desktop/common/threading-and-ui.md` | 线程模型与 UI 交互 |
| `rules/dotnet-desktop/common/configuration.md` | 配置文件组织、环境变量 |
| `rules/dotnet-desktop/common/data-access.md` | 数据访问与持久化 |
| `rules/dotnet-desktop/common/security.md` | 输入校验、鉴权基线 |
| `rules/dotnet-desktop/common/observability.md` | 结构化日志、指标 |
| `rules/dotnet-desktop/common/performance.md` | 性能优化与资源管理 |
| `rules/dotnet-desktop/common/testing-and-release.md` | 测试要求与质量门禁 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/dotnet-desktop/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、wpf 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-desktop/profiles/wpf/project-structure.md` | WPF 应用目录结构与模块边界 |

### 技术栈
- 运行时：.NET 8+
- 框架：WPF
- MVVM：CommunityToolkit.Mvvm
- DI：Microsoft.Extensions.DependencyInjection
- 日志：Serilog
- 测试：xUnit + Moq

---

## 三、maui 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-desktop/profiles/maui/project-structure.md` | .NET MAUI 应用目录结构 |

### 技术栈
- 运行时：.NET 8+
- 框架：.NET MAUI
- 工具包：CommunityToolkit.Maui + CommunityToolkit.Mvvm
- DI：Microsoft.Extensions.DependencyInjection
- 日志：Serilog
- 测试：xUnit + Moq

---

## 四、winforms 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-desktop/profiles/winforms/project-structure.md` | WinForms 应用目录结构 |

### 技术栈
- 运行时：.NET 8+
- 框架：WinForms
- 模式：MVP（Model-View-Presenter）
- DI：Microsoft.Extensions.DependencyInjection
- 日志：Serilog
- 测试：xUnit + Moq

---

## 五、生成产物清单（通用）

每种框架类型初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<framework>/project-structure.md` |
| `.sln` 解决方案 | `common/baseline.md` |
| `.csproj` 项目文件 | `common/baseline.md` |
| `App.xaml` / `App.cs` 入口 | `common/architecture.md` |
| `appsettings.json` | `common/configuration.md` |
| `.editorconfig` | `common/code-style.md` |
| `.gitignore` | `common/security.md` |
