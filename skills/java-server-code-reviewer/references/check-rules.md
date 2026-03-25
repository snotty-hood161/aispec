# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（Checkstyle/SpotBugs/PMD）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、编码基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Java 版本 ≥ 17，pom.xml/build.gradle 中明确声明 | 静态扫描：检查构建文件 |
| BL-02 | P0 | Spring Boot 版本 ≥ 3.0，统一管理依赖版本 | 静态扫描：检查 spring-boot-starter-parent 版本 |
| BL-03 | P0 | 使用 Maven Wrapper 或 Gradle Wrapper，确保构建环境一致 | 静态扫描：检查 mvnw/gradlew 存在性 |
| BL-04 | P0 | 依赖版本锁定，禁止使用 SNAPSHOT 版本于生产环境 | 静态扫描：检查依赖版本声明 |
| BL-05 | P1 | 启用 Checkstyle/SpotBugs 并配置规则文件，CI 中零告警通过 | 静态扫描：Checkstyle/SpotBugs |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 公共类和公共方法必须有 Javadoc 注释 | 静态扫描：Checkstyle（MissingJavadocMethod） |
| CS-02 | P0 | 包名全小写，使用反向域名约定（com.company.project） | 模式匹配：检查 package 声明 |
| CS-03 | P1 | 类名 PascalCase，方法名/变量名 camelCase，常量 UPPER_SNAKE_CASE | 静态扫描：Checkstyle（NamingConventions） |
| CS-04 | P1 | 单个方法体不超过 80 行，圈复杂度 ≤ 15 | 静态扫描：Checkstyle（MethodLength/CyclomaticComplexity） |
| CS-05 | P0 | 分层架构：Controller → Service → Repository，禁止跨层调用 | 人工审查：检查 import 依赖方向 |

## 三、组件初始化（common/component-initialization.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CI-01 | P0 | 使用 Spring 构造器注入，禁止字段注入（@Autowired 字段） | 模式匹配：搜索 @Autowired 字段注入 |
| CI-02 | P0 | Bean 生命周期明确：@PostConstruct 初始化、@PreDestroy 清理 | 人工审查：检查生命周期回调 |
| CI-03 | P1 | 健康检查端点（/actuator/health）已启用并验证依赖可用性 | 模式匹配：搜索 Actuator 配置 |
| CI-04 | P1 | 外部依赖（DB/Redis/MQ）连接在启动时验证，失败则阻止启动 | 人工审查：检查启动流程 |

## 四、API 设计（common/api-design.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AD-01 | P0 | API 路径包含版本号（/api/v1/...），版本变更有迁移方案 | 模式匹配：检查 @RequestMapping 路径 |
| AD-02 | P0 | 统一响应结构：{code, message, data}，禁止裸返回 | 模式匹配：检查 Controller 返回格式 |
| AD-03 | P0 | 请求参数绑定后必须校验（@Valid/@Validated + JSR 303） | 模式匹配：搜索 @RequestBody 后是否有 @Valid |
| AD-04 | P1 | 分页接口使用统一分页结构，默认页大小有上限 | 模式匹配：搜索分页参数定义 |
| AD-05 | P1 | 接口文档（SpringDoc/Swagger）与代码同步，CI 中校验 | 人工审查：检查 @Operation 注解是否完整 |

## 五、异常处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 受检异常必须处理，禁止空 catch 块或仅打印堆栈 | 静态扫描：SpotBugs（EmptyCatchBlock） |
| EH-02 | P0 | 自定义异常体系继承 RuntimeException，携带错误码与上下文 | 模式匹配：搜索异常类定义与继承关系 |
| EH-03 | P0 | 业务错误码体系统一定义（枚举/常量类），禁止硬编码字符串错误 | 模式匹配：搜索 throw new 中的硬编码消息 |
| EH-04 | P1 | 全局异常处理器（@ControllerAdvice）统一处理异常并返回标准响应 | 模式匹配：搜索 @ControllerAdvice 类 |
| EH-05 | P1 | 业务逻辑层禁止捕获 Exception/Throwable，应捕获具体异常类型 | 模式匹配：搜索 catch(Exception) 模式 |

## 六、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 日志必须使用 SLF4J + Logback/Log4j2，禁止 System.out/System.err | 模式匹配：搜索 System.out / System.err 调用 |
| OB-02 | P0 | 日志必须携带 traceId / requestId，通过 MDC 注入 | 模式匹配：搜索 MDC.put 或 Filter 中的 traceId 设置 |
| OB-03 | P1 | 关键业务操作埋点 metrics（Micrometer 指标注册） | 人工审查：检查 MeterRegistry 使用 |
| OB-04 | P1 | 链路追踪（Micrometer Tracing / SkyWalking）覆盖跨服务调用与数据库操作 | 人工审查：检查 Span 创建位置 |
| OB-05 | P1 | 日志级别分层使用（DEBUG/INFO/WARN/ERROR），错误日志包含堆栈 | 模式匹配：检查日志级别使用合理性 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置（密码/密钥/Token）禁止硬编码或提交到代码仓库 | 静态扫描：搜索硬编码密码/密钥模式 |
| CF-02 | P0 | 配置通过 application.yml + Spring Profiles 管理，支持多环境切换 | 模式匹配：检查配置文件组织 |
| CF-03 | P1 | 配置属性使用 @ConfigurationProperties 绑定，集中管理 | 模式匹配：搜索 @Value 散落使用 |
| CF-04 | P1 | 配置项有默认值与校验（@Validated），缺失必要配置时启动失败 | 人工审查：检查配置校验逻辑 |

## 八、并发与资源管理（common/concurrency-and-resource.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CR-01 | P0 | 线程池必须显式配置（@Async + ThreadPoolTaskExecutor），禁止裸 new Thread() | 模式匹配：搜索 new Thread 或未配置线程池的 @Async |
| CR-02 | P0 | 异步任务必须有超时控制与异常处理，禁止静默失败 | 模式匹配：搜索 @Async 方法的异常处理 |
| CR-03 | P0 | 优雅停机：配置 server.shutdown=graceful，设置超时时间 | 模式匹配：搜索 shutdown 配置 |
| CR-04 | P1 | 连接池（HikariCP/Lettuce/Jedis）有大小限制与超时配置 | 人工审查：检查连接池参数 |
| CR-05 | P1 | 共享资源访问使用 synchronized/ReentrantLock/ConcurrentHashMap，禁止无保护并发读写 | 静态扫描：SpotBugs（IS2_INCONSISTENT_SYNC） |

## 九、数据库访问（common/database-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库操作必须通过 Repository/Mapper 层，禁止 Controller/Service 直接拼 SQL | 模式匹配：搜索 Controller/Service 中的 JdbcTemplate/SQL 操作 |
| DA-02 | P0 | 查询必须参数化（JPA 命名参数 / MyBatis #{param}），禁止字符串拼接 SQL（防注入） | 模式匹配：搜索字符串拼接 SQL 模式与 ${param} 使用 |
| DA-03 | P0 | 事务边界在 Service 层控制（@Transactional），Repository 层不自行开启事务 | 人工审查：检查 @Transactional 位置 |
| DA-04 | P1 | 批量操作使用 Batch Insert/Update，禁止循环单条操作 | 模式匹配：搜索循环内的 save/insert 调用 |
| DA-05 | P1 | 数据库迁移使用版本化工具（Flyway/Liquibase），禁止手动 DDL | 人工审查：检查迁移文件管理 |
| DA-06 | P1 | 慢查询有监控告警，查询超时有上限配置 | 人工审查：检查慢查询日志配置 |

## 十、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 所有外部输入必须校验与清洗（@Valid + 自定义 Validator），禁止直接信任用户输入 | 模式匹配：检查入参是否有校验注解 |
| SC-02 | P0 | Spring Security 鉴权配置覆盖所有受保护路由，禁止路由遗漏 | 模式匹配：检查 SecurityFilterChain 配置 |
| SC-03 | P0 | 敏感数据（密码/Token）禁止明文日志输出 | 模式匹配：搜索日志中的敏感字段 |
| SC-04 | P1 | CORS 配置白名单化，禁止 allowedOrigins("*") 用于生产 | 模式匹配：搜索 CORS 配置 |
| SC-05 | P1 | 接口限流（Rate Limiting）已配置，防止暴力请求 | 人工审查：检查限流配置 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | 核心业务逻辑有单元测试，覆盖率 ≥ 60% | 静态扫描：JaCoCo 覆盖率报告 |
| TR-02 | P0 | 测试文件放在 src/test/java 对应包下，与被测类同包 | 模式匹配：检查测试文件位置 |
| TR-03 | P1 | 使用 @ParameterizedTest 进行多场景验证 | 模式匹配：搜索参数化测试使用 |
| TR-04 | P1 | CI 流水线包含 lint → test → build 阶段，质量门禁阻断不合格构建 | 人工审查：检查 CI 配置 |
| TR-05 | P1 | API 接口有集成测试（@SpringBootTest + MockMvc/TestRestTemplate） | 人工审查：检查集成测试存在性 |

## 十二、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P1 | 提供 Actuator 端点与 JVM 监控（/actuator/metrics），生产环境限制访问 | 模式匹配：搜索 Actuator 配置与安全限制 |
| PF-02 | P1 | 大对象避免频繁创建，使用对象池或缓存减少 GC 压力 | 人工审查：检查高频对象分配路径 |
| PF-03 | P1 | 数据库查询有索引覆盖，禁止全表扫描（EXPLAIN 验证） | 人工审查：检查查询与索引匹配 |
| PF-04 | P1 | JSON 序列化热点路径考虑使用 Jackson 流式 API 或预编译 ObjectMapper | 人工审查：检查高频序列化路径 |

## 十三、缓存（common/caching.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CA-01 | P0 | 缓存键设计包含业务前缀与版本号，避免键冲突 | 模式匹配：检查缓存键构造模式 |
| CA-02 | P0 | 所有缓存必须设置 TTL，禁止无过期时间的缓存 | 模式匹配：搜索 @Cacheable 或 RedisTemplate.set 是否带 TTL 参数 |
| CA-03 | P1 | 缓存穿透/击穿/雪崩有防护措施（分布式锁/布隆过滤/随机 TTL） | 人工审查：检查缓存防护策略 |
| CA-04 | P1 | 缓存与数据库一致性策略明确（Cache Aside / Write Through） | 人工审查：检查缓存更新逻辑 |

## 十四、文件存储（common/file-storage.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FS-01 | P0 | 文件上传限制大小与类型，校验 Content-Type 与文件头 | 模式匹配：检查 MultipartFile 校验逻辑 |
| FS-02 | P0 | 文件使用流式读写（InputStream/OutputStream），禁止全量加载到内存 | 模式匹配：搜索 getBytes() 用于大文件 |
| FS-03 | P1 | 文件存储路径使用唯一标识（UUID/Hash），禁止用户原始文件名 | 模式匹配：检查文件存储路径生成 |
| FS-04 | P1 | 对象存储使用预签名 URL 直传，减少服务端中转 | 人工审查：检查上传流程架构 |

## 十五、定时任务（common/scheduled-tasks.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| ST-01 | P0 | 定时任务必须幂等，重复执行不产生副作用 | 人工审查：检查任务逻辑幂等性 |
| ST-02 | P0 | 多实例部署时使用分布式锁（ShedLock/Redisson），防止任务重复执行 | 模式匹配：搜索分布式锁获取逻辑 |
| ST-03 | P1 | 任务执行有超时控制与失败重试机制 | 模式匹配：搜索超时与重试配置 |
| ST-04 | P1 | 任务执行结果有日志记录与监控告警 | 人工审查：检查任务日志与监控 |

## 十六、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止在生产代码中使用 System.out.println / e.printStackTrace() 输出日志 | 静态扫描：PMD/SpotBugs |
| FB-02 | P0 | 禁止提交包含密钥/密码/Token 的代码 | 静态扫描：git-secrets / gitleaks |
| FB-03 | P0 | 禁止使用已废弃 API（@Deprecated），应迁移到推荐替代 | 静态扫描：编译器告警 + SpotBugs |
| FB-04 | P0 | 禁止空 catch 块或仅 e.printStackTrace() 的异常处理 | 静态扫描：SpotBugs（EmptyCatchBlock） |
| FB-05 | P0 | 禁止在 Controller 中直接操作数据库，必须经过 Service 层 | 模式匹配：搜索 Controller 中的 Repository/Mapper 注入 |

---

## Profile 专项检查

### Monolith 专项（profiles/monolith/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MO-01 | P0 | 模块间通过接口解耦，禁止直接依赖其他模块实现类 | 模式匹配：检查 import 中的跨模块引用 |
| MO-02 | P1 | 模块边界清晰，每个模块有独立的 Controller/Service/Repository 层 | 人工审查：检查目录结构 |
| MO-03 | P1 | 共享组件（工具类/通用配置）集中于 common/shared 包 | 模式匹配：检查共享代码位置 |
| MO-04 | P1 | 模块间数据传递使用 DTO，禁止直接共享数据库 Entity | 模式匹配：搜索跨模块的 Entity 引用 |

### Microservice 专项（profiles/microservice/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MS-01 | P0 | 服务间通信使用 Feign/gRPC + 统一序列化，禁止私有协议 | 模式匹配：检查服务间调用方式 |
| MS-02 | P0 | 外部调用有超时、重试与熔断配置（Resilience4j/Sentinel） | 模式匹配：搜索 Feign/RestTemplate Client 配置 |
| MS-03 | P1 | 服务注册与发现配置正确（Nacos/Eureka），健康检查端点可用 | 人工审查：检查服务注册配置 |
| MS-04 | P1 | 分布式事务使用 Saga/Seata/TCC 模式，禁止跨服务本地事务 | 人工审查：检查跨服务事务处理 |
| MS-05 | P1 | 服务间通信携带 traceId，链路追踪完整 | 模式匹配：检查调用链 Header 传播 |
