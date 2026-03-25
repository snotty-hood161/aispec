# Agent 输出格式定义

本文件定义多 Agent 模式下域 Agent 和 Coordinator 的标准输出格式。单体模式无需加载本文件。

## 适用范围
1. 多 Agent 模式下所有域 Agent 的最终输出必须遵循本格式。
2. 执行追溯摘要格式见 `execution-trace.md`（两种模式通用）。

## 域 Agent 标准输出格式

每个域 Agent 完成任务后，必须按以下结构输出：

```
## Agent 执行报告

### 1. 基本信息
- Agent：{agent 名称}
- 调用 Skill：{本次实际调用的 skill 名称，如 $go-server-coding-guide}
- 任务类型：{product / spec / design / design-review / coding / review / scaffold / rule-maintenance / security-audit / testing / devops}
- 任务摘要：{一句话描述本次执行的任务}

### 2. 执行结果
- 状态：{completed / partial / blocked}
- 产出物清单：
  - {文件路径或产出描述}
  - ...

### 3. 遵循的规则清单
- 始终加载：{baseline.md, forbidden.md 等}
- 场景命中：{本次加载的规则文件列表}
- 跨域规则：{如适用，列出跨域规则文件}

### 4. 跨域交接记录
- {列出本次执行中发起或接收的交接，无则写"无"}

### 5. 风险与建议
- P0 阻断项：{列出或写"无"}
- P1 改进项：{列出或写"无"}
- 后续建议：{1-3 条可执行建议}
```

## Coordinator 汇总输出格式

Coordinator 收集所有域 Agent 的报告后，按以下结构汇总：

```
## 任务执行汇总

### 1. 任务概览
- 用户原始任务：{原始任务描述}
- 涉及的域：{列出所有被调度的域}
- 执行顺序：{实际执行顺序，标注并行/串行}

### 2. 各域执行结果

#### {域名 1}
{嵌入该域 Agent 的执行报告}

#### {域名 2}
{嵌入该域 Agent 的执行报告}

...

### 3. 跨域一致性检查
- 契约一致性：{前后端接口、错误码、时间格式是否一致}
- 安全一致性：{安全基线是否各域统一遵循}
- 冲突处理：{列出冲突及仲裁结果，无则写"无冲突"}

### 4. 整体规则清单
- {去重合并所有域 Agent 加载的规则文件}

### 5. 整体风险评估
- P0 阻断项：{汇总所有域的 P0 项}
- P1 改进项：{汇总所有域的 P1 项}
- 整体结论：{Approve / Request Changes / Conditional Approve}

### 6. 后续建议
- {合并各域建议，去重后给出 1-5 条整体建议}
```

## 与 skill 级 output-contract 的关系
1. 域 Agent 内部执行 skill 时，skill 按自身的 output-contract 输出。
2. 域 Agent 将 skill 输出映射到本文件的标准格式。
3. 映射规则：
   - skill 的"本次目标" → Agent 的"任务摘要"
   - skill 的"变更清单" → Agent 的"产出物清单"
   - skill 的"校验结果" → Agent 的"风险与建议"
   - skill 的"需求 -> 规则映射" → Agent 的"遵循的规则清单"
4. Agent 额外补充 skill 未覆盖的信息：跨域交接记录、Agent 身份标识。

## 输出约束
1. 所有输出使用中文。
2. 产出物路径使用相对于项目根目录的格式。
3. 规则文件路径使用相对于 `rules/` 的格式。
4. P0/P1 风险分级标准与各 skill 的 checklist 保持一致。
