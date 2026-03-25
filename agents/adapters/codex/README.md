# OpenAI Codex 适配说明

## 概述
本目录包含 22 个 `.toml` 配置文件，对应 Agent 模式中的 21 个 Agent + Coordinator。
这些文件遵循 [Codex Custom Agents](https://developers.openai.com/codex/multi-agent/) 规范，可直接复制到项目的 `.codex/agents/` 目录使用。

## 安装步骤

### 1. 复制 Agent 配置
```bash
# 在项目根目录执行
mkdir -p .codex/agents
cp agents/adapters/codex/*.toml .codex/agents/
```

### 2. 配置全局设置
在项目的 `.codex/config.toml` 中添加：
```toml
[agents]
max_threads = 6
max_depth = 1
```

### 3. 模型配置（可选）
`.toml` 文件中不硬编码模型，由用户在 `.codex/config.toml` 中按需统一配置：
```toml
[model]
default = "o3"              # 默认模型，按 API 额度和偏好选择
reasoning_effort = "medium"  # low / medium / high
```
也可在单个 `.toml` 文件中通过 `model = "..."` 覆盖全局设置。推荐：
- Coordinator / Security / Spec / Product Agent：推理能力强的模型（如 o3）
- 域 Agent（编码/审查）：平衡速度和质量的模型（如 o4-mini）

### 4. 关联 Skills
确保 `.codex/config.toml` 中的 `skills.config` 指向本仓库的 skills 目录：
```toml
[[skills.config]]
path = "skills/task-router/SKILL.md"

[[skills.config]]
path = "skills/go-server-coding-guide/SKILL.md"

# ... 按需添加各域 skill
```

## 使用方式

### 自动多 Agent 编排
```
请使用多 Agent 模式完成以下任务：新增一个用户管理功能，包含数据库表、API 接口和前端页面。
让 coordinator 分析任务并调度各域 Agent 执行。
```

### 手动指定 Agent
```
使用 go_server agent 审查当前 PR 中的 Go 服务端代码变更。
```

### 并行审查
```
使用多 Agent 模式审查当前 PR。让 coordinator 分析变更文件，为每个涉及的域分配一个 Agent 并行审查，最后汇总结果。
```

## Agent 文件清单

| 文件 | Agent 名称 | 说明 |
|------|-----------|------|
| `coordinator.toml` | coordinator | 任务协调器 |
| `go-server.toml` | go_server | Go 服务端 |
| `dotnet-server.toml` | dotnet_server | .NET 服务端 |
| `frontend.toml` | frontend | 前端 |
| `dotnet-desktop.toml` | dotnet_desktop | .NET 桌面 |
| `tauri-desktop.toml` | tauri_desktop | Tauri 桌面 |
| `android.toml` | android | Android |
| `ios.toml` | ios | iOS |
| `flutter.toml` | flutter | Flutter |
| `database.toml` | database | 数据库 |
| `collaboration.toml` | collaboration | 前后端协作 |
| `design.toml` | design | UI/UX 设计 |
| `spec.toml` | spec | 项目规格说明书 |
| `product.toml` | product | AI 产品经理 |
| `security.toml` | security | 安全工程师 |
| `qa.toml` | qa | 质量保障 |
| `python-server.toml` | python_server | Python 服务端 |
| `java-server.toml` | java_server | Java 服务端 |
| `node-server.toml` | node_server | Node.js 服务端 |
| `electron-desktop.toml` | electron_desktop | Electron 桌面 |
| `react-native.toml` | react_native | React Native |
| `devops.toml` | devops | 部署运维 |

## 注意事项
1. Codex agent name 中不允许使用连字符，因此使用下划线（如 `go_server`）。
2. 域 Agent 默认使用 `workspace-write` 沙箱模式；Coordinator 使用 `read-only`。
3. 每个 `.toml` 文件的 `developer_instructions` 引用对应的 `agents/<domain>/agent.md` 核心内容。
