# rules/java-server/common/component-initialization.md

## 目标
1. 统一 Java 服务端组件初始化方案，规范 Spring 依赖注入方式、Bean 生命周期管理和健康检查。
2. 覆盖常见基础组件：数据库连接、Redis、OSS/MinIO、JWT、消息队列客户端。

## 依赖注入策略（MUST）

1. Spring Bean 必须使用**构造器注入**，禁止字段注入（`@Autowired` 标注在字段上）。
2. 构造器参数超过 5 个时，考虑将相关依赖聚合为配置对象或拆分职责。
3. 构造器注入的类如果只有一个构造函数，可省略 `@Autowired`（Spring 4.3+ 自动推断）。
4. 禁止使用 `@Autowired(required = false)` 隐藏可选依赖；可选依赖必须通过 `Optional<T>` 或 `@Nullable` 显式声明。
5. 配置类（`@Configuration`）统一放在 `config` 包下，禁止散落在业务包中。
6. `@Bean` 方法必须标注作用域（默认 `singleton` 可省略，`prototype` 必须显式标注）。
7. 禁止在业务代码中通过 `ApplicationContext.getBean()` 手动获取 Bean，必须通过构造器注入。

### SHOULD
1. 复杂装配逻辑推荐使用 `@Configuration` + `@Bean` 方法而非组件扫描。
2. 条件化 Bean 注册使用 `@ConditionalOnProperty` / `@ConditionalOnClass` 等条件注解。

## 依赖注入示例

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentClient paymentClient;
    private final EventPublisher eventPublisher;

    public OrderService(OrderRepository orderRepository,
                        PaymentClient paymentClient,
                        EventPublisher eventPublisher) {
        this.orderRepository = orderRepository;
        this.paymentClient = paymentClient;
        this.eventPublisher = eventPublisher;
    }
}
```

## Bean 生命周期管理（MUST）

1. 推荐初始化顺序由 Spring 容器自动推断；需要显式控制时使用 `@DependsOn` 或 `@Order`。
2. Bean 初始化后的自定义逻辑使用 `@PostConstruct`，销毁前的清理逻辑使用 `@PreDestroy`。
3. 组件初始化失败的默认策略是快速失败（fail fast）：抛出异常阻止应用启动。
4. 非关键可选组件的初始化失败需明确定义降级策略，捕获异常后记录 WARN 日志并标记降级状态。
5. 数据库连接池、Redis 连接池、消息队列连接等有状态组件，必须在 `@PreDestroy` 中显式关闭。
6. 进程退出时必须依赖 Spring 的优雅停机机制（`server.shutdown=graceful`），禁止 `System.exit()` 强杀。

## 健康检查与就绪检查（MUST）

1. 必须引入 `spring-boot-starter-actuator`，提供 `/actuator/health` 端点。
2. 存活探针（`/actuator/health/liveness`）仅反映进程可运行状态，不依赖慢速外部依赖。
3. 就绪探针（`/actuator/health/readiness`）必须反映关键依赖可用性（数据库、Redis、消息队列）。
4. 自定义健康指示器通过实现 `HealthIndicator` 接口注册，禁止在业务代码中手动拼装健康状态。
5. Actuator 端点必须绑定在管理端口（`management.server.port`），与业务端口分离。
6. 非关键可选依赖故障时可继续就绪，但必须在健康详情中标记降级状态（`Status.UP` with details）。
7. 健康检查失败原因必须写入结构化日志并附带 `trace_id`（如有）。

### SHOULD
1. 配置 `management.endpoint.health.show-details=when_authorized`，避免向匿名用户暴露内部依赖信息。
2. 自定义 `HealthIndicator` 中的外部依赖检查设置超时（建议 ≤ 3s），避免健康检查阻塞。

## 组件接口约束（MUST）

1. 外部依赖客户端（Redis、OSS、MQ）必须封装为 Spring Bean，通过 `@Configuration` + `@Bean` 创建。
2. 禁止在业务代码中直接 `new` 第三方客户端实例，必须通过 Spring 容器注入。
3. 组件日志必须脱敏，禁止打印密钥、令牌、连接串中的密码部分。
4. 使用方依赖接口而非具体客户端类型，便于注入 mock 或 fake 进行测试。

## 配置绑定（MUST）

1. 组件配置统一使用 `@ConfigurationProperties` 绑定到 POJO，禁止在业务代码中散写 `@Value`。
2. `@ConfigurationProperties` 类必须使用 `@Validated` 标注，配合 `@NotNull`、`@Min` 等校验注解确保启动时发现配置错误。
3. 配置 POJO 必须集中在 `config` 包或 `properties` 包下管理。

## 可测试性要求

### MUST
1. 使用方依赖接口而非具体客户端类型，便于注入 mock 或 fake。
2. Bean 构造函数必须可在测试中传入替代依赖（通过构造器注入天然满足）。
3. 禁止在测试中依赖全局可变静态状态或 `static` 单例。

## 禁止事项
1. 禁止字段注入（`@Autowired` 标注在字段上），测试类除外。
2. 禁止在 `static` 初始化块或 `static` 方法中建立数据库、Redis 等外部连接。
3. 禁止通过全局 `static` 变量暴露可变组件实例（如 `public static DataSource ds`）。
4. 禁止在 Service/Controller 中直接构造 `DataSource`、`RedisTemplate`、`RestTemplate` 等基础组件。
5. 禁止使用 `@PostConstruct` 执行耗时超过 5 秒的阻塞操作，长初始化任务使用 `SmartLifecycle` 管理。
