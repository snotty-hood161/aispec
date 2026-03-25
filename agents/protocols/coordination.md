# agents/protocols/coordination.md — 协调协议

## 目的
1. 定义 Coordinator Agent 如何接收任务、识别域、调度域 Agent 的标准流程。
2. 确保多 Agent 模式下的执行顺序、并行策略、上下文传递有统一规范。

## 适用范围
1. 仅在多 Agent 模式下生效。
2. 单体模式（单个 AI 实例直接调用 `$skill-name`）不受本协议约束。

## 调度算法

### 1. 域识别
- Coordinator 复用 `skills/task-router/references/domain-detect-map.md` 的关键词映射表。
- 新增产品、设计、测试、运维域的关键词识别（见下文任务类型识别）。
- 从用户任务描述中提取关键词，匹配到涉及的域。
- 若无法确定，向用户询问确认。

### 2. 执行顺序 — 全生命周期
- 默认顺序（按产品开发生命周期）：

| 阶段 | 域 | 说明 |
|------|-----|------|
| -1 | Product | 产品需求定义：竞品分析、PRD（新产品/重大迭代时执行，已有 PRD 则跳过） |
| 0 | Spec | 技术规格定义：架构、选型、模块拆分（新项目/重大迭代时执行，已有 Spec 则跳过） |
| 0.5 | Design | UI/UX 设计：交互流程、视觉设计、设计系统（可与 Spec 并行） |
| 0.8 | **Task Planning** | Coordinator 调用 `$task-planner` 将 Spec + Design 产出拆解为任务清单（Spec 和 Design 均完成后执行） |
| 1 | Database | 数据库 Schema 与迁移必须先行 |
| 2 | GoServer / DotnetServer / PythonServer / JavaServer / NodeServer | 服务端 API 基于数据库结构开发 |
| 3 | Collaboration | 前后端契约对齐，确保接口一致性 |
| 4 | Frontend / DotnetDesktop / TauriDesktop / ElectronDesktop / Android / iOS / Flutter / ReactNative | 客户端基于 Design 设计稿 + API 契约开发 |
| 4.5 | Security | 安全审计：威胁建模、OWASP 检查、依赖扫描（开发阶段完成后执行） |
| 5 | QA | 系统测试、验收测试（安全审计通过后执行） |
| 6 | DevOps | 部署上线、监控配置（测试通过后执行） |

- 同阶段内的域 Agent 可并行执行（如 Android 和 iOS 可并行）。
- Spec（阶段 0）和 Design（阶段 0.5）可并行执行，互不阻塞。
- 仅涉及单域的任务直接调度对应域 Agent，无需经过全部阶段。
- 阶段 -1（Product）和阶段 5-6（QA/DevOps）仅在完整产品流程中触发，日常编码任务可跳过。

### 3. MCP 可用性前置检查
在调度涉及外部 MCP 的 Agent 之前，Coordinator 必须检查所需 MCP 是否可用：

- 调度 Product Agent → 检查搜索 MCP（必需）和 Playwright MCP（可选）。
- 调度 Design Agent → 检查 Pencil MCP（必需）、搜索 MCP（可选）和 Playwright MCP（可选）。
- 调度 QA Agent → 检查 Playwright MCP（可选）。
- 调度 Security Agent → 无需检查（安全审计不依赖外部 MCP）。
- 调度其他域 Agent → 无需检查。

检查不通过时，按 `agents/adapters/mcp-tools.md` 中的"MCP 可用性检查与安装引导协议"执行（告知→询问→安装/退化）。所有 MCP 状态确认后，再正式调度 Agent 执行任务。

### 4. 并行/串行决策规则
- 同一阶段内无数据依赖的域 Agent → 并行。
- 跨阶段有数据依赖的域 Agent → 串行（前一阶段完成后再启动下一阶段）。
- Coordinator 标注每个域 Agent 的依赖关系，域 Agent 不自行决定执行顺序。

## 上下文传递

### 调度请求格式（Coordinator → 域 Agent）
Coordinator 向每个域 Agent 发送调度请求时，必须包含以下信息：

```
## 调度请求
- 任务摘要：{用户原始任务的精简描述}
- 任务类型：{product / spec / design / design-review / coding / review / scaffold / rule-maintenance / security-audit / testing / devops}
- 任务 ID：{$task-planner 生成的任务 ID，如 ORDER-DB-001；无则留空}
- 域上下文：{前序域 Agent 的输出摘要，如 Schema 定义、API 契约等}
- Spec 输入：{从 Spec 中截取的相关章节内容}
- Design 输入：{从设计稿中截取的相关页面/组件信息，无则留空}
- 约束提示：{跨域冲突仲裁提示，如"数据库规则优先级最高"}
```

### 结果回传格式（域 Agent → Coordinator）
遵循 `agents/protocols/agent-output-format.md` 的标准输出格式，按 `agents/protocols/execution-trace.md` 格式附执行追溯。

## 跨域冲突仲裁
- 多 Agent 模式下的跨域冲突仲裁规则与单体模式一致，以 `rules/index.md` 的仲裁规则为准。
- Coordinator 在汇总各域 Agent 结果时执行冲突检测：
  1. 数据库相关冲突 → 以 Database Agent 的输出为准。
  2. 前后端接口冲突 → 以 Collaboration Agent 的输出为准。
  3. 域内冲突 → 以"更严格且可验证"的条款为准。
- 若冲突无法自动消解，Coordinator 向用户报告冲突并请求裁定。

## 任务类型识别
Coordinator 根据用户意图识别任务类型，决定调度哪个 Agent 及其 skill：

| 用户意图 | 任务类型 | 域 Agent 调用的 skill |
|---------|---------|---------------------|
| 产品需求/竞品分析/PRD | product | Product Agent 的 `$product-prd-writer` |
| 新项目立项/技术方案设计/规格定义 | spec | Spec Agent 的 `$spec-generator` |
| UI/UX 设计/界面原型/设计系统 | design | Design Agent 的 `$ui-ux-designer` |
| 设计走查/设计还原度审查 | design-review | Design Agent 的 `$design-reviewer` |
| 编写/修改业务代码 | coding | `*-coding-guide` |
| 审查代码变更 / PR 评审 | review | `*-code-reviewer` |
| 初始化新项目 | scaffold | `*-project-scaffold` |
| 新增/修改/审计规则 | rule-maintenance | `*-rules-maintainer` |
| 安全审计/威胁建模/漏洞扫描/安全合规 | security-audit | Security Agent 的 `$security-auditor` |
| 测试策略/测试用例/验收测试 | testing | QA Agent 的 `$qa-test-strategist` |
| CI/CD/部署/监控/基础设施 | devops | DevOps Agent 的 `$devops-engineer` |

注：
- product 类型任务由 Product Agent 独立执行（Phase -1），产出 PRD 作为后续 Agent 输入。
- spec 类型任务由 Spec Agent 独立执行（Phase 0），产出 Spec 作为后续 Agent 输入。
- design 类型任务由 Design Agent 执行（Phase 0.5），可与 Spec 并行。
- security-audit 类型任务由 Security Agent 在开发完成后执行（Phase 4.5）。
- testing 类型任务由 QA Agent 在安全审计通过后执行（Phase 5）。
- devops 类型任务由 DevOps Agent 在测试通过后执行（Phase 6）。
- 完整产品流程：Product → Spec ∥ Design → Task Planning → Database → Server → Collaboration → Client → Security → QA → DevOps。
- Task Planning（阶段 0.8）由 Coordinator 调用 `$task-planner` 自动执行，将 Spec + Design 产出拆解为按域分组的可执行任务清单。

## 汇总输出
- Coordinator 收集所有域 Agent 的结果后，按 `agents/protocols/agent-output-format.md` 的汇总格式输出，按 `agents/protocols/execution-trace.md` 格式附执行追溯。
- 汇总内容包括：各域执行结果、跨域依赖关系、冲突处理记录、整体规则清单。
