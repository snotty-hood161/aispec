# rules/java-server/common/forbidden.md

## 禁止事项

### 依赖注入与组件管理
1. 禁止字段注入（`@Autowired` 标注在字段上），必须使用构造器注入（测试类除外）。
2. 禁止在业务代码中通过 `ApplicationContext.getBean()` 手动获取 Bean。
3. 禁止在 Service/Controller 中直接构造 `DataSource`、`RedisTemplate`、`RestTemplate` 等基础组件，必须通过 Spring DI 注入。
4. 禁止通过 `static` 全局变量暴露可变组件实例（如 `public static DataSource ds`）。
5. 禁止在 `static` 初始化块中建立数据库、Redis 等外部连接。

### 分层架构
6. 禁止在 Controller 中直接注入 Repository/DAO，必须经由 Service 调用。
7. 禁止在 Controller 中直接操作数据库、缓存、对象存储、消息中间件客户端。
8. 禁止在 Service 中依赖 `HttpServletRequest`/`HttpServletResponse` 等 Servlet API。
9. 禁止在 Repository 中编写业务状态机逻辑或跨聚合用例编排。
10. 禁止将 JPA Entity / MyBatis Model 直接作为 API 响应返回，必须转换为 DTO/VO。

### 异常与错误处理
11. 禁止将系统异常（数据库驱动异常、RPC 原始异常、未捕获 NPE）原样返回给调用方。
12. 禁止在多个 Controller 中分散实现异常到响应的映射逻辑，必须走 `@ControllerAdvice` 统一异常处理。
13. 禁止空 catch 块吞异常（`catch (Exception e) {}`），至少记录日志或重新抛出。
14. 禁止使用 `e.printStackTrace()`，必须通过 SLF4J Logger 记录。
15. 禁止对失败请求统一返回 HTTP `200` 并仅依赖响应体业务 `code` 区分错误。

### 代码质量
16. 禁止将 `System.out.println`、`System.err.println` 提交到主分支。
17. 禁止使用 `@SneakyThrows`（Lombok），异常必须显式处理。
18. 禁止在 JPA Entity 上使用 `@Data`（Lombok），会导致 `equals`/`hashCode` 问题。
19. 禁止使用 `Executors.newFixedThreadPool()` / `Executors.newCachedThreadPool()` 创建线程池。
20. 禁止使用 `@Async` 未指定线程池名称（默认使用 `SimpleAsyncTaskExecutor`，每次创建新线程）。

### 配置与安全
21. 禁止硬编码数据库、Redis、OSS 等外部依赖地址和凭据，必须从配置文件或密钥管理服务加载。
22. 禁止在 CORS 配置中硬编码域名白名单，必须从配置文件加载。
23. 禁止将密钥、Token、密码等敏感信息提交到代码仓库。
24. 禁止在生产环境暴露 Swagger/OpenAPI 文档端点而不加鉴权保护。
25. 禁止使用 `@SuppressWarnings` 绕过 SpotBugs/PMD 告警而不在 PR 中说明原因。

### 数据库
26. 禁止使用 `SELECT *`，必须显式列字段。
27. 禁止字符串拼接 SQL（SQL 注入风险），必须使用参数化查询。
28. 禁止修改历史数据库迁移脚本（Flyway/Liquibase），变更必须新增脚本。
29. 禁止在事务中执行远程调用（HTTP/RPC），事务应短小高效。
30. 禁止 `@Transactional` 标注在 `private` 方法上（Spring AOP 不生效）。

### 缓存与资源
31. 禁止永不过期的缓存数据（静态配置除外需注释说明）。
32. 禁止大量缓存使用相同 TTL（缓存雪崩风险）。
33. 禁止每次 HTTP 请求创建新的 `RestTemplate` / `WebClient` 实例。
34. 禁止 I/O 操作不设置超时。
35. 禁止在业务代码中直接使用 `Timer`、`ScheduledExecutorService` 创建定时任务。
