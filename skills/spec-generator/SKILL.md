---
name: spec-generator
description: 项目规格说明书生成器。当需要进行技术选型、架构设计、模块拆分或编写完整项目 Spec 时触发。通过五阶段引导（愿景→技术决策→全局约束→模块拆分→汇总）帮助用户产出结构化的技术规格文档。每个技术决策提供 1-3 个方案对比。
---

# 项目规格说明书生成器

通过交互式引导，帮助用户完成从项目愿景到模块 Spec 的全流程技术规格定义。

## 何时使用
1. 新项目立项，需要技术选型和架构设计。
2. 用户要求编写 Spec 或技术方案。
3. 需要进行模块拆分和接口定义。
4. 由 Coordinator 在 Phase 0 调度时。

## 执行原则
1. 按五阶段逐步引导，每个阶段产出明确的中间产物。
2. 以 `references/spec-scenario-map.md` 为阶段路由表。
3. 每个技术决策提供 1-3 个备选方案，包含优缺点对比和推荐理由。
4. 推荐必须引用具体上下文（项目规模、团队能力、性能需求），不做泛泛推荐。
5. 最终产出使用 `agents/spec/templates/` 下的模板格式。
6. Spec 中的技术决策和约束要足够具体，可供各域 Agent 直接消费。

## 标准工作流（必须执行）

### Phase 1：项目愿景
- 参考 `agents/spec/phases/01-vision.md` 中的引导问题。
- 明确系统目标、核心用户、功能矩阵、MVP 范围。
- 产出：项目愿景文档。

### Phase 2：技术决策
- 参考 `agents/spec/phases/02-decisions.md` 中的引导问题。
- 逐项决策：架构模式、编程语言、数据库、缓存、消息队列、认证方案、API 风格、文件存储、搜索方案、部署模式。
- 每个决策点提供 1-3 个方案对比。
- 产出：技术决策清单（含 ADR）。

### Phase 3：全局约束
- 参考 `agents/spec/phases/03-constraints.md` 中的引导问题。
- 定义 10 个维度的约束：安全、性能、可用性、扩展性、合规、成本、部署、三方集成、数据策略、监控。
- 产出：全局约束矩阵。

### Phase 4：模块拆分
- 参考 `agents/spec/phases/04-modules.md` 中的引导问题。
- 拆分模块，定义模块间依赖关系。
- 每个模块产出 12 维 Spec（职责/数据结构/API/业务规则/边界/状态机/权限/事件/错误处理/依赖/测试/迁移）。
- 产出：模块清单 + 各模块 Spec。

### Phase 5：汇总输出
- 参考 `agents/spec/phases/05-summary.md` 中的引导问题。
- 一致性检查（5 项）。
- 产出：完整项目 Spec + ADR + 风险清单 + 里程碑计划。
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯（skill 名称、任务类型、加载规则清单、跨域联动）。

## 资源
1. 阶段路由表：`references/spec-scenario-map.md`
2. 引导问题模板：`agents/spec/phases/`
3. 项目级 Spec 模板：`agents/spec/templates/project-spec-template.md`
4. 模块级 Spec 模板：`agents/spec/templates/module-spec-template.md`
