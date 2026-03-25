# rules/node-server/common/testing-and-release.md

## 测试框架与工具

### MUST
1. 项目必须选定统一的测试框架（推荐 Vitest，备选 Jest），禁止同项目混用多套测试框架。
2. API 集成测试必须使用 `supertest`（Express/Fastify）或 NestJS 内建的 `Testing` 模块。
3. 测试文件命名统一使用 `*.spec.ts`（单元测试）或 `*.e2e-spec.ts`（端到端测试）。
4. 测试文件必须与被测文件放在同目录（`co-location`）或统一放在 `__tests__/` 目录。
5. 禁止测试之间共享可变状态，每个测试用例必须独立可重复执行。

### SHOULD
1. 推荐使用 `vitest` 的 in-source testing 能力进行快速迭代开发。
2. 推荐使用 `@faker-js/faker` 生成测试数据，禁止在测试中硬编码大量测试数据。

检查方式：CI 测试流水线
阻断级别：阻断合并

---

## 测试分层与覆盖

### MUST
1. 测试必须按以下分层组织：
   - **单元测试**：覆盖 service 层业务逻辑、工具函数、纯函数，使用 mock 隔离外部依赖。
   - **集成测试**：覆盖 repository 层数据访问、事务行为，使用真实数据库（推荐 testcontainers 或 Docker）。
   - **API 测试**：覆盖 controller 层端到端请求响应，验证状态码、响应结构、错误处理。
2. service 层优先单元测试，使用 mock/stub 验证用例编排和业务规则。
3. repository 层优先集成测试，验证 ORM 查询行为、事务一致性与索引假设。
4. controller 层使用 API 测试验证请求校验、状态码映射、响应结构、错误格式。
5. 每个测试用例必须覆盖至少：成功路径、参数错误、权限不足、资源不存在场景。

### SHOULD
1. 推荐使用 `testcontainers`（`@testcontainers/postgresql`）启动测试数据库容器，保证测试环境一致性。
2. 推荐为关键业务流程编写端到端场景测试（如注册→登录→下单→支付）。

---

## 覆盖率要求（MUST）

1. 项目整体代码覆盖率不低于 80%（行覆盖率）。
2. service 层（核心业务逻辑）覆盖率不低于 90%。
3. 新增/修改代码的增量覆盖率不低于 80%。
4. 覆盖率报告必须在 CI 中自动生成（`vitest --coverage` 或 `jest --coverage`），低于阈值阻断合并。
5. 覆盖率统计必须排除自动生成代码（Prisma Client、GraphQL Schema 等）和配置文件。

### SHOULD
1. 推荐将覆盖率报告上传到 Codecov/Coveralls 等平台，在 PR 中展示覆盖率变化。
2. 推荐定期清理无效测试（永远通过但不验证行为的测试）。

检查方式：CI 覆盖率检查
阻断级别：阻断合并

---

## Mock 与测试替身规范（MUST）

1. 外部依赖（数据库、Redis、第三方 API、消息队列）在单元测试中必须使用 mock/stub。
2. NestJS 测试必须使用 `Test.createTestingModule()` + `overrideProvider()` 替换依赖。
3. Mock 对象必须验证交互行为（如调用次数、参数），禁止只 mock 不验证。
4. 禁止 mock 被测试对象本身的方法，mock 仅用于隔离外部依赖。
5. 时间相关测试必须使用 `vi.useFakeTimers()`（Vitest）或 `jest.useFakeTimers()`，禁止依赖真实时间。

---

## CI 质量门禁（MUST）

1. PR 合并前必须通过以下 CI 检查（全部通过方可合并）：
   - TypeScript 编译（`tsc --noEmit`）
   - ESLint 检查（`eslint . --max-warnings 0`）
   - 单元测试和集成测试通过
   - 代码覆盖率达标
   - 依赖安全扫描通过
2. CI 流水线必须在 5 分钟内完成（不含端到端测试），超过须优化。
3. 主分支推送必须触发完整测试套件（含端到端测试），失败立即通知。
4. PR 必须至少有 1 位代码审查者批准。

### SHOULD
1. 推荐在 CI 中集成 SonarQube 进行代码质量扫描（圈复杂度、重复代码、代码异味）。
2. 推荐为 PR 自动生成测试覆盖率差异报告。

检查方式：CI 流水线配置审查
阻断级别：阻断合并

---

## 发布规范（MUST）

1. 版本号遵循语义化版本（Semantic Versioning）：`MAJOR.MINOR.PATCH`。
2. 发布必须基于主分支或发布分支的 CI 通过构建产物，禁止从开发环境直接发布。
3. 生产发布必须有回滚方案，支持一键回退到上一个稳定版本。
4. 数据库迁移必须在应用发布前独立执行并验证，禁止与应用部署同步进行。
5. 灰度发布（金丝雀发布）必须监控关键指标（错误率、延迟、CPU/内存），异常自动回滚。

### SHOULD
1. 推荐使用 `changesets` 或 `semantic-release` 自动化版本管理和 CHANGELOG 生成。
2. 推荐发布后自动通知相关团队（Slack/飞书/钉钉）。
