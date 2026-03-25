# Spec 生成阶段 → 工作内容映射表

用此表引导 Spec 生成的五个阶段和每个阶段的工作内容。

## 使用方式
1. 按阶段顺序逐步执行。
2. 每个阶段结束后确认产出，再进入下一阶段。
3. 已有 PRD 时以 PRD 作为 Phase 1 的输入，加速愿景阶段。

---

## 阶段路由表

| 阶段 | 名称 | 引导问题文件 | 核心产出 | 输出模板 |
|------|------|------------|---------|---------|
| Phase 1 | 项目愿景 | `agents/spec/phases/01-vision.md` | 系统目标、用户画像、功能矩阵、MVP | — |
| Phase 2 | 技术决策 | `agents/spec/phases/02-decisions.md` | 10 项技术选型 + ADR | — |
| Phase 3 | 全局约束 | `agents/spec/phases/03-constraints.md` | 10 维约束定义 | — |
| Phase 4 | 模块拆分 | `agents/spec/phases/04-modules.md` | 模块清单 + 依赖图 + 各模块 Spec | `agents/spec/templates/module-spec-template.md` |
| Phase 5 | 汇总输出 | `agents/spec/phases/05-summary.md` | 完整项目 Spec | `agents/spec/templates/project-spec-template.md` |

## 技术决策点清单

| 编号 | 决策点 | 备选方案示例 | 决策依据 |
|------|--------|------------|---------|
| TD-01 | 架构模式 | 单体 / 微服务 / Serverless | 团队规模、业务复杂度、扩展需求 |
| TD-02 | 编程语言 | Go / .NET / Java / Python / Node.js | 团队能力、生态、性能需求 |
| TD-03 | 数据库 | MySQL / PostgreSQL / MongoDB | 数据模型、事务需求、规模 |
| TD-04 | 缓存 | Redis / Memcached / 本地缓存 | 数据结构需求、持久化需求 |
| TD-05 | 消息队列 | RabbitMQ / Kafka / NATS / Redis Streams | 吞吐量、顺序性、持久化 |
| TD-06 | 认证方案 | JWT / Session / OAuth2 / OIDC | 分布式需求、三方登录、安全等级 |
| TD-07 | API 风格 | REST / gRPC / GraphQL | 客户端类型、性能需求、类型安全 |
| TD-08 | 文件存储 | OSS / MinIO / 本地磁盘 | 文件量、访问频率、合规要求 |
| TD-09 | 搜索方案 | Elasticsearch / Meilisearch / 数据库全文 | 搜索复杂度、数据量 |
| TD-10 | 部署模式 | Docker Compose / K8s / Serverless / 裸机 | 运维能力、扩展需求、成本 |

## 方案对比输出格式

```markdown
### TD-{编号}：{决策点名称}

**解决什么问题**：{一句话说明}

| 维度 | 方案 A：{名称} | 方案 B：{名称} | 方案 C：{名称} |
|------|--------------|--------------|--------------|
| 简介 | {一句话} | {一句话} | {一句话} |
| 优点 | {列出} | {列出} | {列出} |
| 缺点 | {列出} | {列出} | {列出} |
| 适用场景 | {场景} | {场景} | {场景} |
| 学习成本 | 低/中/高 | 低/中/高 | 低/中/高 |

**推荐**：方案 {X}
**推荐理由**：{引用具体项目上下文的理由}
```

## Spec 质量检查清单

- [ ] 所有技术决策都有方案对比和推荐理由
- [ ] 全局约束 10 个维度均已定义
- [ ] 每个模块的 12 维 Spec 均已填写
- [ ] 模块间依赖关系明确且无循环依赖
- [ ] 技术选型与 PRD 的非功能性需求一致
- [ ] 已标注与 Design / Database / QA / DevOps 的衔接点
