# Gemini ADK 适配说明

## 概述
Google Agent Development Kit（ADK）通过 Python class 定义 Agent，支持层级编排（Sequential / Parallel / Loop）。
本文档说明如何将本仓库的 Agent 模式映射到 Gemini ADK 实现。

## 机制对应关系

| Agent 模式概念 | Gemini ADK 对应机制 |
|---------------|-------------------|
| Agent 定义（agent.md） | `LlmAgent` class + instruction 参数 |
| Coordinator Agent | Root Agent / Coordinator pattern |
| 域 Agent | Sub-agent（通过 `sub_agents` 参数传入） |
| 串行执行 | `SequentialAgent` |
| 并行执行 | `ParallelAgent` |
| 交接协议 | Agent 间 handoff / tool call |
| Skill（SKILL.md） | Agent 的 instruction 中引用规则，或封装为 Tool |

## 实现指引

### 1. Agent 定义映射
将每个 `agents/<domain>/agent.md` 映射为一个 `LlmAgent`：

```python
from google.adk.agents import LlmAgent

go_server_agent = LlmAgent(
    name="go_server",
    model="gemini-2.0-flash",
    instruction=open("agents/go-server/agent.md").read(),
    sub_agents=[],  # 域 Agent 通常无 sub-agent
)
```

### 2. Spec Agent 实现
Spec Agent 处于 Phase 0（Product 之后），负责项目规格定义：

```python
from google.adk.agents import LlmAgent

spec_agent = LlmAgent(
    name="spec",
    model="gemini-2.0-flash",
    instruction=open("agents/spec/agent.md").read(),
    sub_agents=[],
)
```

### 3. Coordinator 实现
Coordinator Agent 作为 Root Agent，管理 Spec Agent 和所有域 Agent：

```python
from google.adk.agents import LlmAgent

coordinator = LlmAgent(
    name="coordinator",
    model="gemini-2.0-flash",
    instruction=open("agents/coordinator/agent.md").read(),
    sub_agents=[
        spec_agent,
        go_server_agent,
        dotnet_server_agent,
        frontend_agent,
        database_agent,
        collaboration_agent,
        # ... 其他域 Agent
    ],
)
```

### 4. 工作流编排
对于已知执行顺序的任务，使用 Workflow Agent：

```python
from google.adk.agents import SequentialAgent, ParallelAgent

# 完整生命周期：Product → Spec ∥ Design → DB → Server → Collab → Client → Security → QA → DevOps
fullstack_workflow = SequentialAgent(
    name="fullstack_workflow",
    sub_agents=[
        product_agent,            # Phase -1: 产品需求（可选）
        ParallelAgent(            # Phase 0 ∥ 0.5: Spec 与 Design 并行
            name="spec_and_design",
            sub_agents=[spec_agent, design_agent],
        ),
        database_agent,           # Phase 1
        go_server_agent,          # Phase 2
        collaboration_agent,      # Phase 3
        ParallelAgent(            # Phase 4: 客户端并行
            name="clients",
            sub_agents=[frontend_agent, android_agent, ios_agent],
        ),
        security_agent,           # Phase 4.5
        qa_agent,                 # Phase 5
        devops_agent,             # Phase 6
    ],
)
```

### 5. Skill 集成
将 SKILL.md 内容作为 Agent instruction 的一部分，或封装为 ADK Tool：

```python
from google.adk.tools import FunctionTool

def load_coding_guide(domain: str, scenario: str) -> str:
    """根据域和场景加载对应的编码规范"""
    # 读取 skills/<domain>-coding-guide/references/coding-scenario-map.md
    # 例如：skills/go-server-coding-guide/references/coding-scenario-map.md
    # 并返回命中的规则文件内容
    ...

coding_guide_tool = FunctionTool(func=load_coding_guide)
```

### 6. 项目结构示例
```
adk_project/
├── agents/              # 从本仓库复制的 agent 定义
├── rules/               # 从本仓库复制的规则
├── skills/              # 从本仓库复制的 skill
├── app.py               # ADK 应用入口
├── agent_definitions.py # Agent 定义（LlmAgent 实例化）
└── tools.py             # 自定义 Tool（Skill 封装）
```

## 使用方式

### 通过 ADK CLI 运行
```bash
adk run app.py --prompt "新增一个用户管理功能，包含数据库、Go API 和前端页面"
```

### 通过 ADK Web UI
```bash
adk web app.py
# 在浏览器中输入任务描述
```

## 限制
1. Gemini ADK 需要 Python 环境，不支持纯 Markdown 声明式定义。
2. Agent 间通信依赖 ADK 的 Session 机制，需要适配交接协议格式。
3. 建议将 `agents/<domain>/agent.md` 的内容直接嵌入 `instruction` 参数，保持单一来源。
