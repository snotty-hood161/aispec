# 脚手架映射表（部署模式 → 规则与模板文件）

本文件定义每种部署模式初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认部署模式后，按下表加载对应文件。
2. "通用必读"对所有模式生效。
3. "专项文件"仅对特定模式生效。

---

## 一、通用必读（所有部署模式）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-server/common/baseline.md` | .NET 版本、项目结构、格式化要求 |
| `rules/dotnet-server/common/code-style.md` | 命名、注释、分层编码 |
| `rules/dotnet-server/common/component-initialization.md` | 依赖注入、生命周期、健康检查 |
| `rules/dotnet-server/common/configuration.md` | 配置文件组织、环境变量 |
| `rules/dotnet-server/common/error-handling.md` | 异常分类与传播 |
| `rules/dotnet-server/common/security.md` | 输入校验、鉴权基线 |
| `rules/dotnet-server/common/observability.md` | 结构化日志、指标 |
| `rules/dotnet-server/common/testing-and-release.md` | 测试要求与质量门禁 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/dotnet-server/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、monolith 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-server/profiles/monolith/project-structure.md` | 单体应用目录结构与模块边界 |

### 技术栈
- 运行时：.NET 8+
- Web：ASP.NET Core Minimal API / Controller
- ORM：EF Core / Dapper
- 校验：FluentValidation
- 日志：Serilog
- 测试：xUnit + Moq

---

## 三、microservice 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/dotnet-server/profiles/microservice/project-structure.md` | 微服务目录结构 |

### 技术栈
- 运行时：.NET 8+
- RPC：gRPC + protobuf
- Web：ASP.NET Core（HTTP 网关）
- ORM：EF Core / Dapper
- 消息：RabbitMQ / Kafka（MassTransit）
- 容器：Docker + Kubernetes
- 日志：Serilog
- 测试：xUnit + Moq + TestContainers

---

## 四、生成产物清单（通用）

每种部署模式初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<mode>/project-structure.md` |
| `.sln` 解决方案 | `common/baseline.md` |
| `.csproj` 项目文件 | `common/baseline.md` |
| `.editorconfig` | `common/code-style.md` |
| `appsettings.json` + `appsettings.Development.json` | `common/configuration.md` |
| `Program.cs` 入口 | `common/component-initialization.md` |
| `.gitignore` | `common/security.md` |
