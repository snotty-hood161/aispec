# Cursor 适配说明

## 概述
Cursor（v2.4+）通过 `.cursor/rules/`、`SKILL.md` 和内建 subagent 机制支持多 Agent 工作流。
本文档说明如何在 Cursor 中使用本仓库的 Agent 模式。

## 机制对应关系

| Agent 模式概念 | Cursor 对应机制 |
|---------------|---------------|
| Agent 定义（agent.md） | `.cursor/rules/` 规则文件（将 agent.md 作为规则加载） |
| Skill（SKILL.md） | Cursor Skills（原生支持，直接引用 `skills/*/SKILL.md`） |
| 域 Agent 并行执行 | Cursor Task subagent（`generalPurpose` / `explore`） |
| Coordinator 调度 | 主对话中 AI 充当 Coordinator，通过 Task 工具 spawn subagent |

## 配置步骤

### 1. 单体模式（默认，无需额外配置）
Cursor 原生支持 SKILL.md。只需确保 `skills/` 目录在项目中，AI 会自动发现并使用 skill。

### 2. 多 Agent 模式

#### 方式 A：手动触发（推荐）
在 Cursor 对话中直接指示 AI 使用多 Agent 模式：

```
请使用多 Agent 模式完成以下任务。
参考 agents/index.md 了解 Agent 体系，
参考 agents/protocols/coordination.md 了解调度协议。
任务：新增一个用户管理功能，包含数据库、API 和前端页面。
```

AI 会读取 Agent 定义文件，理解各 Agent 的职责边界，并通过 Task subagent 并行执行。

#### 方式 B：创建规则文件
将 Agent 模式的入口信息写入 `.cursor/rules/`：

```bash
# 在项目 .cursor/rules/ 下创建规则文件
```

`.cursor/rules/agent-mode.md` 内容示例：
```markdown
---
description: 当用户要求使用多 Agent 模式或提出跨域任务时加载
globs: []
alwaysApply: false
---
多 Agent 模式已启用。请读取 agents/index.md 了解 Agent 体系。
按 agents/protocols/coordination.md 的调度协议执行跨域任务。
每个域 Agent 的定义在 agents/<domain>/agent.md 中。
```

### 3. 并行执行
Cursor 的 Task subagent 支持并行执行。AI 可以：
- 为每个域 Agent 创建一个 Task subagent。
- 每个 subagent 加载对应的 `agents/<domain>/agent.md` 和 `skills/*/SKILL.md`。
- 主对话中的 AI 充当 Coordinator，汇总各 subagent 的结果。

## 使用示例

### 项目规格定义
```
使用多 Agent 模式。参考 agents/index.md。
我要做一个电商平台，请使用 Spec Agent 引导我完成技术规格定义。
参考 agents/spec/agent.md 了解五阶段引导流程。
```

### 跨域编码
```
使用多 Agent 模式。参考 agents/index.md 和 agents/protocols/coordination.md。
任务：新增订单管理功能（数据库 + Go 后端 + 前端页面）。
请按 数据库→服务端→前后端协作→前端 的顺序执行。
```

### 并行代码审查
```
使用多 Agent 模式审查当前分支的代码变更。
为每个涉及的技术域创建一个 subagent 并行审查。
审查规则参考 agents/<domain>/agent.md 中的 code-reviewer skill。
```

## 限制
1. Cursor subagent 不支持自定义 model 配置（使用全局模型设置）。
2. subagent 间不能直接通信，需通过主对话传递上下文。
3. 适合 2-4 个并行 subagent，过多会增加 token 消耗。
