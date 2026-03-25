---
name: dotnet-server-project-scaffold
description: 根据部署模式自动初始化 C#/.NET 服务端项目结构。用于新项目启动时，输入部署模式（monolith / microservice）后自动读取对应规则，生成目录结构、配置文件、CI 脚本，并输出初始化报告。
workflow: _templates/project-scaffold-workflow.md
---

# .NET 服务端项目脚手架

## 域参数

- **domain**: dotnet-server
- **scaffold_map**: `references/scaffold-map.md`
- **input_type**: 部署模式
- **supported_modes**:
  - `monolith` — 单体应用（ASP.NET Core API + 后台任务 + Worker Service）
  - `microservice` — 微服务（gRPC/HTTP + 消息消费 + 独立部署）

## 资源
1. 脚手架映射：`references/scaffold-map.md`
