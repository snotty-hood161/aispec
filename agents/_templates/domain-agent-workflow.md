# 域 Agent 通用工作流

本文件定义所有域 Agent（技术栈域）的共享工作流。各域 `agent.md` 通过 `workflow` 字段引用本模板，并声明域参数。

## 标准工作流

### 1. 接收调度请求
- 从 Coordinator 接收任务摘要、任务类型、域上下文。
- 按域 agent.md 声明的 `context`（如部署模式、应用类型、框架）确定当前上下文。

### 2. 选择 Skill 并执行
- 根据任务类型从域 agent.md 声明的 `skills` 表中选择对应 skill。
- Skill 内部按场景路由表加载规则并执行。

### 3. 跨域交接
- 按域 agent.md 声明的 `handoff` 规则执行交接：
  - 需要数据库 Schema 变更 → 交接给 Database Agent。
  - 需要 API 契约变更 → 交接给 Collaboration Agent。
  - 规则冲突 → 上报 Coordinator Agent。

### 4. 输出报告
- 按 `agents/protocols/agent-output-format.md` 格式输出执行报告。
- 按 `agents/protocols/execution-trace.md` 格式附执行追溯。
