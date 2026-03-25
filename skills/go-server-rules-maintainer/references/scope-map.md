# 主题落点映射（需求 -> 规则文件）

用此表将用户需求映射到“主定义文件”，避免多文件重复修改。

## 通用主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| 工程基线/通用约束 | `common/baseline.md` | `common/forbidden.md` |
| 代码风格/分层边界 | `common/code-style.md` | `profiles/*/project-structure.md` |
| 组件初始化/DI/生命周期 | `common/component-initialization.md` | `common/testing-and-release.md`, `profiles/*/project-structure.md` |
| API 契约与响应格式 | `common/api-design.md` | `common/error-handling.md`, `common/security.md` |
| 错误分类与映射 | `common/error-handling.md` | `common/forbidden.md`, `common/api-design.md` |
| 日志/指标/追踪 | `common/observability.md` | `common/component-initialization.md` |
| 配置加载与 profile | `common/configuration.md` | `common/database-access.md` |
| 并发、资源与优雅停机 | `common/concurrency-and-resource.md` | `common/testing-and-release.md` |
| 数据库访问与模型策略 | `common/database-access.md` | `common/code-style.md`, `profiles/*/project-structure.md` |
| 安全、鉴权与审计 | `common/security.md` | `common/error-handling.md` |
| 测试与发布门禁 | `common/testing-and-release.md` | `rules/templates/go-server/pr-review-checklist.md` |
| 禁止项（反模式） | `common/forbidden.md` | 各主题文件（反向校验） |
| PR 评审清单 | `rules/templates/go-server/pr-review-checklist.md` | `common/testing-and-release.md` |
| 前后端协作（契约/联调/发布） | `rules/frontend-backend-collaboration.md` | `common/api-design.md`, `common/error-handling.md`, `common/testing-and-release.md` |

## Profile 主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| 单体目录与模块边界 | `profiles/monolith/project-structure.md` | `common/code-style.md` |
| 微服务目录与边界 | `profiles/microservice/project-structure.md` | `common/component-initialization.md` |
| 微服务通信与契约 | `profiles/microservice/communication-and-contracts.md` | `common/api-design.md`, `common/observability.md` |
| 缓存策略与多级缓存 | `common/caching.md` | `common/database-access.md`, `common/observability.md` |
| 文件存储与 CDN 策略 | `common/file-storage.md` | `common/api-design.md`, `common/security.md` |
| 定时任务与调度 | `common/scheduled-tasks.md` | `common/observability.md`, `common/concurrency-and-resource.md` |
| 性能优化与基准测试 | `common/performance.md` | `common/code-style.md`, `common/testing-and-release.md` |
| 微服务服务发现 | `profiles/microservice/service-discovery.md` | `profiles/microservice/communication-and-contracts.md`, `common/observability.md` |
| 微服务容错与降级 | `profiles/microservice/resilience.md` | `common/error-handling.md`, `common/observability.md` |
| 微服务消息队列 | `profiles/microservice/messaging.md` | `common/observability.md`, `common/concurrency-and-resource.md` |
| 微服务网关设计 | `profiles/microservice/gateway.md` | `common/api-design.md`, `common/security.md` |
| 微服务间安全通信 | `profiles/microservice/security-communication.md` | `common/security.md`, `common/observability.md` |
| 微服务发布与部署 | `profiles/microservice/deployment-and-release.md` | `common/testing-and-release.md` |
| 微服务配置中心 | `profiles/microservice/config-center.md` | `common/configuration.md` |
| 微服务容器化 | `profiles/microservice/containerization.md` | `profiles/microservice/project-structure.md`, `common/observability.md` |

## 冲突决策
1. 同主题冲突：`profile` 规则优先于 `common`。
2. 数据库迁移冲突：以 `<rules-root>/database/database.md` 为准。
3. 无法消解：采用“更严格且可验证”的规则并在输出中标注。
