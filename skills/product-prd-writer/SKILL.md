---
name: product-prd-writer
description: 产品需求文档编写器。当需要进行竞品分析、需求定义、用户画像、MVP 规划或编写完整 PRD 文档时触发。通过五阶段引导（市场调研→竞品分析→需求定义→路线图→PRD 汇总）帮助用户产出结构化的 PRD。
---

# 产品需求文档编写器

通过交互式引导，帮助用户完成从市场调研到 PRD 输出的全流程。

## 何时使用
1. 从 0 到 1 做一个新产品，需要产品规划。
2. 用户要求进行竞品分析或编写 PRD。
3. 需要定义用户画像、用户故事、MVP 范围。
4. 由 Coordinator 在 Phase -1 调度时。

## 外部 MCP 依赖
- **搜索 MCP**（Brave Search / Tavily，必需）：竞品调研和市场分析。
- **Playwright MCP**（可选）：竞品产品体验和截图。
- MCP 不可用时按 `agents/adapters/mcp-tools.md` 的引导协议执行。

## 执行原则
1. 按五阶段逐步引导，每个阶段产出明确的中间产物。
2. 以 `references/prd-scenario-map.md` 为阶段路由表。
3. 每个阶段结束后向用户确认，再进入下一阶段。
4. 最终产出使用 `agents/product/templates/prd-template.md` 的模板格式。
5. PRD 中的验收标准要足够具体，可供 QA Agent 直接转化为测试用例。

## 标准工作流（必须执行）

### Phase 1：市场调研
- 参考 `agents/product/phases/01-research.md` 中的引导问题。
- 使用搜索 MCP 调研行业趋势和市场规模。
- 产出：行业概况、目标市场、关键洞察。

### Phase 2：竞品深度分析
- 参考 `agents/product/phases/02-competitive.md` 中的引导问题。
- 分析 3-5 个竞品的功能、定价、用户口碑。
- 产出：竞品对标矩阵、SWOT 分析、差异化定位。

### Phase 3：需求定义
- 参考 `agents/product/phases/03-requirements.md` 中的引导问题。
- 定义用户画像和核心用户故事。
- 每个用户故事包含验收标准。
- 产出：用户画像、用户故事列表、功能优先级矩阵。

### Phase 4：MVP 与路线图
- 参考 `agents/product/phases/04-roadmap.md` 中的引导问题。
- 确定 MVP 功能集和成功指标。
- 产出：MVP 功能清单、成功指标、迭代计划、风险清单。

### Phase 5：PRD 汇总
- 参考 `agents/product/phases/05-summary.md` 中的引导问题。
- 按 `agents/product/templates/prd-template.md` 汇总完整 PRD。
- 标注与 Design Agent / Spec Agent / QA Agent 的衔接点。
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯（skill 名称、任务类型、加载规则清单、跨域联动）。

## 资源
1. 阶段路由表：`references/prd-scenario-map.md`
2. 引导问题模板：`agents/product/phases/`
3. PRD 输出模板：`agents/product/templates/prd-template.md`
4. MCP 工具方案：`agents/adapters/mcp-tools.md`
