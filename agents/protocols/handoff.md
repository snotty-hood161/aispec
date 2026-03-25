# agents/protocols/handoff.md — 交接协议

## 目的
1. 定义域 Agent 之间任务交接的标准格式与触发条件。
2. 确保跨域依赖（如服务端需要数据库变更、前端需要 API 契约）在 Agent 间正确传递。

## 适用范围
1. 仅在多 Agent 模式下生效。
2. 单体模式中跨域联动通过 skill 内部的"跨域联动"机制实现，不使用本协议。

## 交接触发条件

域 Agent 在执行任务过程中，遇到以下情况必须发起交接：

| 触发场景 | 发起方 | 接收方 | 说明 |
|---------|--------|--------|------|
| PRD 完成，需进入设计阶段 | Product Agent | Design Agent | PRD 作为设计输入 |
| PRD 完成，需进入技术规格阶段 | Product Agent | Spec Agent | PRD 作为 Spec 输入 |
| 设计稿完成，需前端实现 | Design Agent | Frontend / 客户端 Agent | 设计稿作为 UI 实现依据 |
| 设计稿变更影响已实现页面 | Design Agent | Frontend / 客户端 Agent | 同步调整已实现的界面 |
| 发现技术限制影响设计方案 | Spec Agent / 域 Agent | Design Agent | 反馈设计方案的技术可行性 |
| 任务拆解发现 Spec 缺失（SPEC-GAP） | Coordinator（$task-planner） | Spec Agent | Spec 缺少 Design 页面所需的 API/数据结构，需补充 |
| 任务拆解发现 Design 缺失（DESIGN-GAP） | Coordinator（$task-planner） | Design Agent | Design 缺少 Spec 模块对应的页面/组件，需补充 |
| 发现需要数据库 Schema 变更 | 任意域 Agent | Database Agent | 数据库变更必须由 Database Agent 执行 |
| 发现需要新增/修改 API 接口 | 客户端域 Agent | Collaboration Agent | API 契约变更需经协作 Agent 协调 |
| 发现需要服务端配合 | 客户端域 Agent | GoServer / DotnetServer / PythonServer / JavaServer / NodeServer Agent | 服务端实现变更 |
| 发现需要前端配合 | 服务端域 Agent | Frontend Agent | 前端页面或组件需同步调整 |
| Tauri 前端代码变更 | TauriDesktop Agent | Frontend Agent | Tauri 前端遵循前端规范 |
| 开发完成，需进入安全审计 | 客户端域 Agent | Security Agent | 交付待审计产物 |
| 安全审计发现高危漏洞 | Security Agent | 对应域 Agent | 经 Coordinator 调度到正确的域修复 |
| 安全审计通过，需进入测试阶段 | Security Agent | QA Agent | 安全审计通过 + 安全测试场景交付 |
| 测试发现缺陷需修复 | QA Agent | 对应域 Agent | 经 Coordinator 调度到正确的域 |
| 测试通过，需进入部署阶段 | QA Agent | DevOps Agent | 测试通过是部署前置条件 |
| 发现规则冲突需仲裁 | 任意域 Agent | Coordinator Agent | 上报冲突由 Coordinator 仲裁 |

## 交接消息格式

发起交接时，必须使用以下标准格式：

```
## 交接请求
- 发起 Agent：{agent 名称}
- 接收 Agent：{目标 agent 名称}
- 交接类型：{dependency / conflict / collaboration}
- 交接原因：{一句话说明为什么需要交接}
- 上下文数据：
  - {传递给接收方的关键信息，如 Schema 定义、API 路径、错误码等}
- 期望输出：{希望接收方返回什么}
- 阻塞状态：{blocking / non-blocking}
```

## 交接类型

### dependency（依赖交接）
- 当前 Agent 的任务依赖另一个 Agent 的输出。
- 默认为 blocking：发起方等待接收方完成后继续。
- 示例：服务端 Agent 发现需要新建数据表，交接给 Database Agent。

### conflict（冲突上报）
- 当前 Agent 发现自身规则与另一个域的规则冲突。
- 始终交接给 Coordinator Agent 仲裁。
- 发起方暂停冲突相关部分的执行，等待仲裁结果。

### collaboration（协作请求）
- 当前 Agent 需要另一个 Agent 的配合，但不阻塞自身主流程。
- 默认为 non-blocking：发起方继续执行，接收方异步处理。
- 示例：服务端 Agent 完成 API 后通知 Collaboration Agent 更新契约文档。

## 交接状态机

```
initiated → accepted → in_progress → completed
                                    → blocked → escalated（上报 Coordinator）
         → rejected（接收方判断不属于自己的职责，退回 Coordinator 重新路由）
```

- `initiated`：发起方发送交接请求。
- `accepted`：接收方确认接手。
- `in_progress`：接收方正在执行。
- `completed`：接收方完成，返回结果给发起方。
- `blocked`：接收方遇到阻塞，上报 Coordinator。
- `rejected`：接收方认为任务不属于自己的职责，退回 Coordinator 重新路由。

## 交接结果格式

接收方完成交接任务后，返回：

```
## 交接结果
- 发起 Agent：{原始发起方}
- 执行 Agent：{实际执行方}
- 状态：{completed / partial / blocked}
- 输出摘要：{一段话总结执行结果}
- 产出物：{文件清单、Schema 定义、API 契约等}
- 注意事项：{发起方需要关注的后续影响}
```

## 与 Coordinator 的关系
- 所有交接请求对 Coordinator 可见（Coordinator 维护全局交接记录）。
- blocking 交接超时未响应时，Coordinator 自动介入。
- 被 rejected 的交接请求由 Coordinator 重新路由到正确的域 Agent。
