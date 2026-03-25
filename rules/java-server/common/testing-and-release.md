# rules/java-server/common/testing-and-release.md

## 测试框架（MUST）

1. 单元测试必须使用 JUnit 5（`junit-jupiter`），禁止使用 JUnit 4（`@RunWith` 风格）。
2. Mock 框架统一使用 Mockito（`mockito-core` + `mockito-junit-jupiter`）。
3. 断言推荐使用 AssertJ（`assertThat(...)`），语义清晰；允许使用 JUnit 5 原生断言。
4. 集成测试使用 `@SpringBootTest` 或 `@DataJpaTest` / `@WebMvcTest` 等切片测试注解。
5. 测试容器推荐使用 Testcontainers（数据库、Redis、Kafka 等），确保测试环境与生产一致。

## 测试要求（MUST）

1. 新增或修改业务逻辑必须配套测试：单元测试优先，必要时补集成测试。
2. 单元测试必须覆盖正常路径、边界条件、异常路径。
3. Service 层优先单元测试，使用 `@ExtendWith(MockitoExtension.class)` + `@Mock` + `@InjectMocks` 验证用例编排。
4. Repository 层优先集成测试，使用 `@DataJpaTest` + Testcontainers 验证 SQL/ORM 行为和事务一致性。
5. Controller 层使用 `@WebMvcTest` + `MockMvc` 测试，验证状态码、错误映射、参数校验和响应结构。
6. 修复缺陷必须补回归测试，确保问题可重复验证与防回归。
7. 必须包含至少一项优雅停机验证：停止接收新请求、在途请求可完成、超时后强退行为符合预期。
8. 必须验证健康探针与就绪探针行为：依赖正常时可就绪、关键依赖故障时不可就绪。

### 测试命名与组织（MUST）
1. 测试类命名：`{被测类名}Test`（单元测试）、`{被测类名}IntegrationTest`（集成测试）。
2. 测试方法命名体现场景：`should_returnOrder_when_orderExists()`、`should_throwException_when_invalidInput()`。
3. 测试必须独立运行，禁止测试之间存在执行顺序依赖。
4. 测试数据必须自包含，每个测试方法在 `@BeforeEach` 中初始化或使用独立数据，禁止依赖共享可变状态。

## 代码覆盖率（MUST）

1. 必须集成 JaCoCo 做代码覆盖率统计。
2. Service 层行覆盖率不低于 70%（建议 80%），核心业务模块不低于 80%。
3. 覆盖率报告纳入 CI，低于阈值阻断合并。
4. 禁止为提高覆盖率编写无断言的空测试。

### SHOULD
1. 分支覆盖率纳入统计，关键决策分支必须覆盖。
2. 定期审查覆盖率趋势，防止新代码拉低整体覆盖率。

## 质量门禁（MUST）

1. 合并前必须通过：编译（`mvn compile` / `gradle compileJava`）、Checkstyle、SpotBugs、单元测试（`mvn test`）、集成测试。
2. PR 描述必须包含变更目的、影响范围、回滚方案、测试结果。
3. PR 评审必须附 Java 服务端 PR 评审清单的勾选结果，且所有 P0 项必须通过。
4. 涉及 API、配置或数据库变更时，必须同步更新文档。

## 发布要求（MUST）

1. 生产发布必须支持健康检查（Actuator）、优雅停机（`server.shutdown=graceful`）、失败回滚。
2. 变更应具备灰度策略或等效风险控制方案。
3. 发布前需演练一次停机流程，确认不会因中断在途写请求而产生脏数据。
4. 发布产物（JAR/Docker Image）必须由 CI 构建，禁止本地构建上传。
5. 发布版本必须打 Git Tag，Tag 格式：`v{MAJOR}.{MINOR}.{PATCH}`。

### SHOULD
1. 发布流程文档化，包含回滚步骤和验证清单。
2. 生产发布后 30 分钟内持续观察核心指标（错误率、延迟、CPU/内存）。
