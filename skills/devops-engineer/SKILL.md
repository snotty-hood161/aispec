---
name: devops-engineer
description: DevOps 工程师技能。当用户需要设计 CI/CD 流水线、部署方案、基础设施配置、监控告警方案或环境管理策略时触发。基于项目技术栈和约束条件，产出可执行的 DevOps 方案。
---

# DevOps 工程师

根据项目技术栈和架构约束，设计 CI/CD、部署策略、监控方案和环境管理方案。

## 何时使用
1. 新项目需要设计 CI/CD 流水线。
2. 用户要求制定部署方案或基础设施方案。
3. 需要设计监控告警体系。
4. 需要规划多环境管理方案。
5. 由 Coordinator 在 Phase 6 调度时。

## 执行原则
1. 以 `references/devops-scenario-map.md` 为场景路由表。
2. 以 `rules/environment/environment-management.md` 为环境管理规范。
3. 以 `rules/observability/observability.md` 为可观测性规范。
4. 以 `rules/release/release-management.md` 为发布管理规范。
5. 以 `rules/security/security-baseline.md` 中的安全基础设施要求为安全基线。
6. 方案必须基于 Spec 中的架构约束和性能需求。

## 标准工作流（必须执行）

### 1. 理解项目上下文
- 阅读 Spec 中的技术选型和架构决策。
- 确认技术栈组合（语言/框架/数据库/缓存/消息队列）。
- 确认部署目标（云平台/私有化/混合）。
- 确认 SLA 要求（可用性/延迟/吞吐）。

### 2. 查表确定方案集
- 读取 `references/devops-scenario-map.md`。
- 按技术栈和部署目标确定需要设计的方案模块。
- 加载对应的规范文件。

### 3. 设计方案
- CI/CD 流水线：构建→测试→安全扫描→部署的完整管道。
- 基础设施：容器化、编排、负载均衡、CDN。
- 部署策略：滚动/蓝绿/金丝雀，附回滚方案。
- 监控告警：按 `rules/observability/observability.md` 设计指标、日志、追踪、告警方案。
- 环境管理：按 `rules/environment/environment-management.md` 设计多环境方案。

### 4. 输出交付物
- CI/CD 配置文件（GitHub Actions / GitLab CI 等）。
- Dockerfile 和编排配置。
- 环境清单和配置模板。
- 监控告警规则。
- 发布检查清单。
- 回滚手册。
- 按 `agents/protocols/execution-trace.md` 格式，在输出末尾附执行追溯（skill 名称、任务类型、加载规则清单、跨域联动）。

## 资源
1. 场景路由表：`references/devops-scenario-map.md`
2. 环境管理规范：`rules/environment/environment-management.md`
3. 可观测性规范：`rules/observability/observability.md`
4. 发布管理规范：`rules/release/release-management.md`
5. 安全基线：`rules/security/security-baseline.md`
6. DevOps Agent 定义：`agents/devops/agent.md`
