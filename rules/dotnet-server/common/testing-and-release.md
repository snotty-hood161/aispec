# rules/dotnet-server/common/testing-and-release.md

## 测试要求
1. 新增或修改业务逻辑必须配套测试：单元测试优先，必要时补集成测试。
2. 测试框架推荐 xUnit + FluentAssertions，Mock 框架推荐 Moq 或 NSubstitute。
3. 单元测试命名规范：`{方法名}_{场景}_{预期结果}`（如 `CreateUser_WhenEmailDuplicate_ThrowsBusinessException`）。
4. 修复缺陷必须补回归测试，确保问题可重复验证与防回归。
5. 必须包含至少一项优雅停机验证：停止接收新请求、在途请求可完成、超时后强退行为符合预期。
6. 必须验证健康探针与就绪探针行为：依赖正常时可就绪、关键依赖故障时不可就绪。

## 集成测试
1. API 集成测试使用 `WebApplicationFactory<T>`，在真实 HTTP 管道中测试端到端行为。
2. 数据库集成测试推荐使用 Testcontainers（`Testcontainers.MySql` / `Testcontainers.PostgreSql`），禁止依赖共享开发数据库。
3. 集成测试必须覆盖：认证授权、参数校验、错误响应格式、分页、幂等等核心行为。

## 质量门禁
1. 合并前必须通过 `dotnet build --warnaserrors`、`dotnet test`、Roslyn 分析器检查。
2. PR 描述必须包含变更目的、影响范围、回滚方案、测试结果。
3. PR 评审必须附 `templates/dotnet-server/pr-review-checklist.md` 的勾选结果（或等价结构化记录），且所有 `P0` 必须通过。
4. 涉及 API、配置或数据库变更时，必须同步更新文档。
5. 代码覆盖率建议：新增业务代码行覆盖率 >= 80%（通过 `coverlet` 或等效工具收集）。

## 发布要求
1. 生产发布必须支持健康检查、优雅停机、失败回滚。
2. 变更应具备灰度策略或等效风险控制方案。
3. 发布前需演练一次停机流程，确认不会因中断在途写请求而产生脏数据。
4. 发布产物必须为 Docker 镜像或自包含发布（Self-Contained），禁止在生产环境依赖 `dotnet run` 源码编译运行。
