# Claude Code 适配说明

## 概述
Claude Code 通过 `CLAUDE.md` 项目配置文件和实验性 Agent Teams 功能支持多 Agent 工作流。
本文档说明如何在 Claude Code 中使用本仓库的 Agent 模式。

## 机制对应关系

| Agent 模式概念 | Claude Code 对应机制 |
|---------------|---------------------|
| Agent 定义（agent.md） | `CLAUDE.md` 中的指令 + Task subagent |
| Skill（SKILL.md） | 通过 `CLAUDE.md` 引用或直接读取 |
| 域 Agent 并行执行 | Task 工具 spawn parallel subagent |
| Coordinator 调度 | 主会话中 AI 充当 Coordinator |

## 配置步骤

### 1. 单体模式
在项目根目录的 `CLAUDE.md` 中引用 skill 体系：

```markdown
## 编码规范
- 编写代码时参考 skills/ 目录下对应技术域的 coding-guide。
- 跨域任务使用 skills/task-router/SKILL.md 进行域识别。
- 规则文件位于 rules/ 目录，按需加载。
```

### 2. 多 Agent 模式

#### 方式 A：CLAUDE.md 配置 + 手动触发
在 `CLAUDE.md` 中添加 Agent 模式说明：

```markdown
## 多 Agent 模式
当用户要求使用多 Agent 模式或提出跨域任务时：
1. 读取 agents/index.md 了解 Agent 体系。
2. 按 agents/protocols/coordination.md 的调度协议执行。
3. 为每个涉及的域创建 Task subagent，加载对应 agents/<domain>/agent.md。
4. 汇总各 subagent 结果，按 agents/protocols/agent-output-format.md 格式输出，按 agents/protocols/execution-trace.md 格式附执行追溯。
```

#### 方式 B：Agent Teams（实验性功能）
启用 Agent Teams 功能（需设置环境变量）：

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

然后在 Claude Code 中配置各 Agent 角色：
- 每个域 Agent 是一个独立的 Claude Code 实例。
- 通过共享文件系统传递上下文。
- Coordinator 角色由主实例承担。

## 使用示例

### 项目规格定义
```
使用多 Agent 模式。参考 agents/index.md。
我要做一个 SaaS 管理平台，请使用 Spec Agent 引导我完成技术规格定义。
按五阶段流程（愿景→技术决策→全局约束→模块拆分→汇总）逐步引导。
```

### 跨域编码
```
使用多 Agent 模式。参考 agents/index.md。
任务：新增用户管理功能（数据库 + .NET 后端 + Flutter 前端）。
请创建 subagent 分别处理各域，按调度协议的顺序执行。
```

### 规则审计
```
使用多 Agent 模式对所有规则域进行一致性审计。
为每个域创建一个 subagent，各自加载 *-rules-maintainer skill 执行审计。
汇总所有域的审计结果。
```

## 限制
1. Agent Teams 功能仍为实验性，可能不稳定。
2. Claude Code subagent 共享同一个 context window，大量并行可能影响性能。
3. 建议优先使用 Task subagent 方式，稳定性更好。
