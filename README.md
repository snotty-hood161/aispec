<div align="center">

# AISpec

**AI-Driven Engineering Specification System**

让 AI 编码助手输出一致、高质量、符合工程规范的代码

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

[快速开始](#-快速开始) · [平台支持](#-平台支持) · [覆盖范围](#-覆盖范围) · [贡献指南](CONTRIBUTING.md)

</div>

<br />

## 为什么需要 AISpec？

AI 编码助手（Cursor、Codex、Claude Code 等）能力强大，但缺乏统一的工程规范约束，容易在不同会话、不同成员间产生风格不一致、结构不统一、最佳实践遗漏等问题。

**AISpec 解决这个问题。** 它是一套结构化的规则 + 能力 + 编排体系，让 AI 在编码、审查、架构设计等环节始终遵循团队约定的工程标准。

<br />

## 核心特性

<table>
<tr>
<td width="50%">

**15 个技术域全覆盖**

服务端 · 前端 · 桌面端 · 移动端 · 数据库
涵盖 Go / .NET / Python / Java / Node.js /
Vue / React / WPF / Tauri / Electron /
Android / iOS / Flutter / React Native

</td>
<td width="50%">

**68 个 AI Skills**

编码引导 · 代码审查 · 项目脚手架 · 规则维护
以及产品、设计、安全、测试、DevOps 等
横切能力，即插即用

</td>
</tr>
<tr>
<td>

**22 个专业 Agents**

支持多 Agent 协作编排，覆盖
产品 → 规格 → 设计 → 编码 →
安全 → 测试 → 部署全生命周期

</td>
<td>

**多平台开箱适配**

Cursor · OpenAI Codex · Claude Code · Gemini ADK
每个平台都有专属适配方案和配置文件

</td>
</tr>
</table>

<br />

## 体系架构

```
┌───────────────────────────────────────────────────────────────┐
│  agents/ (编排层)                    ※ 仅多 Agent 模式使用    │
│  Coordinator + Product + Spec + Design + 15 域 Agent         │
│  + Security + QA + DevOps + 协作协议                          │
├───────────────────────────────────────────────────────────────┤
│  skills/ (能力层)                    ※ 两种模式共用           │
│  68 Skill：coding-guide / code-reviewer / project-scaffold   │
│  / rules-maintainer / router / prd-writer / qa ...           │
├───────────────────────────────────────────────────────────────┤
│  rules/ (规则层)                     ※ 唯一规则真源           │
│  15 域规则 + 设计 + 安全 + 环境 + 可观测性 + 测试 + 模板     │
└───────────────────────────────────────────────────────────────┘
```

> **rules** 是所有规范的唯一真源；**skills** 是 AI 的执行入口，负责加载规则并引导任务；**agents** 提供多 Agent 协作编排能力。

<br />

## 🚀 快速开始

### 第一步：获取

```bash
# 克隆到项目中
git clone https://github.com/gnmsss/aispec.git

# 或作为 Git submodule 引入
git submodule add https://github.com/gnmsss/aispec.git
```

### 第二步：选择模式

| | 单体模式 | 多 Agent 模式 |
|---|---------|-------------|
| **适用场景** | 单域任务、日常编码和审查 | 新项目立项、跨域全栈开发 |
| **工作方式** | 单个 AI 通过 Skill 直接调用规则 | 多个专业 Agent 按调度协议协作 |
| **入口文件** | `rules/index.md` | `agents/index.md` |

### 第三步：按平台配置

根据你使用的 AI 工具平台，参考下方 [平台支持](#-平台支持) 完成配置。

<br />

## 🔌 平台支持

<table>
<tr>
<td width="25%" align="center"><b>Cursor</b></td>
<td width="25%" align="center"><b>OpenAI Codex</b></td>
<td width="25%" align="center"><b>Claude Code</b></td>
<td width="25%" align="center"><b>Gemini ADK</b></td>
</tr>
<tr>
<td align="center">v2.4+<br/>原生 SKILL.md 支持</td>
<td align="center">.toml Agent 配置<br/>22 个预置文件</td>
<td align="center">CLAUDE.md 集成<br/>Task subagent</td>
<td align="center">Python class<br/>Sequential / Parallel</td>
</tr>
</table>

<br />

<details open>
<summary><b>Cursor</b> — 原生支持，零配置可用</summary>

<br />

> 版本要求：v2.4+

**单体模式**：无需任何配置，Cursor 会自动发现 `skills/` 目录下的 Skill。

**多 Agent 模式**：在对话中直接触发——

```
请使用多 Agent 模式。参考 agents/index.md 和 agents/protocols/coordination.md。
任务：新增用户管理功能（数据库 + API + 前端页面）。
```

也可创建 `.cursor/rules/agent-mode.md` 规则文件实现自动加载。

📖 详细配置 → [`agents/adapters/cursor/README.md`](agents/adapters/cursor/README.md)

</details>

<details>
<summary><b>OpenAI Codex</b> — .toml Agent 定义</summary>

<br />

```bash
mkdir -p .codex/agents
cp aispec/agents/adapters/codex/*.toml .codex/agents/
```

提供 22 个预配置的 `.toml` 文件，涵盖 Coordinator 和所有域 Agent。

📖 详细配置 → [`agents/adapters/codex/README.md`](agents/adapters/codex/README.md)

</details>

<details>
<summary><b>Claude Code</b> — CLAUDE.md 集成</summary>

<br />

在项目根目录 `CLAUDE.md` 中引用规范体系和多 Agent 调度协议即可使用。

📖 详细配置 → [`agents/adapters/claude-code/README.md`](agents/adapters/claude-code/README.md)

</details>

<details>
<summary><b>Gemini ADK</b> — Python Agent 编排</summary>

<br />

将 `agents/<domain>/agent.md` 映射为 `LlmAgent`，组合 `SequentialAgent` / `ParallelAgent` 实现工作流编排。

📖 详细实现 → [`agents/adapters/gemini-adk/README.md`](agents/adapters/gemini-adk/README.md)

</details>

<br />

## 📋 覆盖范围

### 技术域

| 类别 | 技术栈 | 规则入口 |
|-----|--------|---------|
| **服务端** | Go · .NET · Python · Java · Node.js | `rules/<domain>/index.md` |
| **前端** | Vue3 · React · uni-app（Admin / H5 / 小程序） | [`rules/frontend/`](rules/frontend/) |
| **桌面端** | .NET (WPF/MAUI) · Tauri (Rust) · Electron | `rules/<domain>/index.md` |
| **移动端** | Android (Kotlin/Compose) · iOS (Swift/SwiftUI) · Flutter · React Native | `rules/<domain>/index.md` |
| **数据库** | Schema 初始化与迁移 | [`rules/database/`](rules/database/) |
| **前后端协作** | API 契约 · 联调流程 · 发布回滚 | [`rules/frontend-backend-collaboration.md`](rules/frontend-backend-collaboration.md) |

### 跨域工程规范

| 规范 | 入口 |
|------|------|
| 安全基线 | [`rules/security/`](rules/security/) |
| 环境管理 | [`rules/environment/`](rules/environment/) |
| 可观测性（监控 / 日志 / 追踪） | [`rules/observability/`](rules/observability/) |
| API 版本管理 | [`rules/api-versioning/`](rules/api-versioning/) |
| 版本发布（SemVer / Changelog） | [`rules/release/`](rules/release/) |
| 测试（E2E + 性能） | [`rules/testing/`](rules/testing/) |
| 国际化 | [`rules/i18n/`](rules/i18n/) |
| 错误码体系 | [`rules/design/error-code-system.md`](rules/design/error-code-system.md) |

### 生命周期 Agents

| Agent | 职责 | 定义 |
|-------|------|------|
| Product | 竞品分析、需求定义、PRD、路线图 | [`agents/product/`](agents/product/) |
| Spec | 技术规格说明书（五阶段引导） | [`agents/spec/`](agents/spec/) |
| Design | 交互设计、视觉设计、设计系统 | [`agents/design/`](agents/design/) |
| Security | 威胁建模、OWASP 检查、依赖扫描 | [`agents/security/`](agents/security/) |
| QA | 测试策略、测试用例、验收测试 | [`agents/qa/`](agents/qa/) |
| DevOps | CI/CD、基础设施、监控告警 | [`agents/devops/`](agents/devops/) |

<br />

## 🧩 Skills 一览

每个技术域包含 **4 类 Skill**，共计 **59 个域 Skill** + **9 个横切 Skill**：

| 类型 | 数量 | 说明 |
|------|:----:|------|
| `*-coding-guide` | 15 | 根据场景加载规则，引导 AI 编写规范代码 |
| `*-code-reviewer` | 15 | 对代码变更进行规范性审查 |
| `*-project-scaffold` | 14 | 生成符合规范的项目初始结构 |
| `*-rules-maintainer` | 15 | 校验和维护规则文件一致性 |

<details>
<summary><b>横切 Skills（9 个）</b></summary>

<br />

| Skill | 说明 |
|-------|------|
| `task-router` | 任务域路由器 — 识别任务涉及的技术域 |
| `task-planner` | 任务拆解 — 将复杂任务拆分为可执行步骤 |
| `product-prd-writer` | PRD 撰写 — 引导完成产品需求文档 |
| `spec-generator` | 规格生成 — 引导完成技术规格说明书 |
| `ui-ux-designer` | UI/UX 设计 — 交互与视觉设计引导 |
| `design-reviewer` | 设计审查 — 设计走查与规范检查 |
| `security-auditor` | 安全审计 — 威胁建模与安全检查 |
| `qa-test-strategist` | 测试策略 — 测试规划与用例设计 |
| `devops-engineer` | DevOps — CI/CD 与部署策略 |

</details>

<br />

## 📁 项目结构

```
aispec/
├── rules/                    ← 规则层（唯一规则真源）
│   ├── index.md              ← 总入口
│   ├── <domain>/             ← 15 个技术域规则
│   ├── security/             ← 安全基线
│   ├── testing/              ← E2E + 性能测试
│   ├── i18n/                 ← 国际化
│   └── templates/            ← 可复用模板
│
├── skills/                   ← 能力层（AI 执行入口）
│   ├── task-router/          ← 任务域路由器
│   ├── *-coding-guide/       ← 编码引导 ×15
│   ├── *-code-reviewer/      ← 代码审查 ×15
│   ├── *-project-scaffold/   ← 项目脚手架 ×14
│   ├── *-rules-maintainer/   ← 规则维护 ×15
│   └── (9 个横切 skill)
│
├── agents/                   ← 编排层（多 Agent 模式）
│   ├── index.md              ← 总入口
│   ├── protocols/            ← 协作协议（4 个）
│   ├── coordinator/          ← 任务协调器
│   ├── <domain>/             ← 15 个域 Agent + 支持 Agent
│   └── adapters/             ← 平台适配
│       ├── codex/            ← OpenAI Codex
│       ├── cursor/           ← Cursor
│       ├── claude-code/      ← Claude Code
│       └── gemini-adk/       ← Gemini ADK
│
├── CONTRIBUTING.md
└── LICENSE (MIT)
```

<br />

## 🤝 贡献

欢迎参与贡献！请阅读 **[CONTRIBUTING.md](CONTRIBUTING.md)** 了解规则、Skill、Agent 的贡献规范、提交流程和审查标准。

## 📄 许可证

[MIT License](LICENSE) &copy; 2026 AI Engineering Standard

---

<div align="center">

如果 AISpec 对你有帮助，请给个 Star ⭐ 支持一下！

[回到顶部](#aispec)

</div>
