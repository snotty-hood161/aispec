# rules/java-server/profiles/microservice/project-structure.md

## 适用场景
1. 独立部署、独立伸缩、独立发布的 Java/Spring Boot 微服务。
2. 每个服务仓库或每个服务目录都应作为独立可交付单元。

## 推荐目录结构

```text
.
├── pom.xml / build.gradle                    # 服务构建文件
├── Dockerfile                                # Docker 构建文件
├── src/main/java/com/example/orderservice/
│   ├── OrderServiceApplication.java          # @SpringBootApplication 启动类
│   ├── config/                               # 服务配置类
│   │   ├── SecurityConfig.java               # Spring Security 配置
│   │   ├── WebMvcConfig.java                 # MVC 配置（CORS、拦截器）
│   │   ├── FeignConfig.java                  # Feign 客户端配置
│   │   ├── CacheConfig.java                  # 缓存配置
│   │   ├── AsyncConfig.java                  # 异步线程池配置
│   │   └── JacksonConfig.java                # JSON 序列化配置
│   ├── api/                                  # 对外契约定义
│   │   ├── openapi/                          # OpenAPI 3.x 契约
│   │   └── proto/                            # gRPC Proto 定义（可选）
│   ├── common/                               # 服务内通用能力（无业务语义）
│   │   ├── exception/                        # 统一异常定义
│   │   │   ├── BaseException.java
│   │   │   ├── BusinessException.java
│   │   │   ├── SystemException.java
│   │   │   └── GlobalExceptionHandler.java
│   │   ├── response/                         # 统一响应结构
│   │   │   └── ApiResponse.java
│   │   └── errorcode/                        # 通用错误码
│   │       └── CommonErrorCode.java
│   ├── infrastructure/                       # 基础设施适配层
│   │   ├── persistence/                      # 数据库配置
│   │   ├── cache/                            # Redis 配置
│   │   │   └── CacheKeyConstants.java        # 缓存键常量
│   │   ├── storage/                          # OSS/MinIO 适配
│   │   ├── messaging/                        # MQ 生产者/消费者封装
│   │   │   ├── producer/
│   │   │   │   └── OrderEventProducer.java
│   │   │   └── consumer/
│   │   │       └── PaymentResultConsumer.java
│   │   ├── feign/                            # Feign 客户端定义
│   │   │   ├── UserServiceClient.java        # @FeignClient
│   │   │   └── fallback/
│   │   │       └── UserServiceFallback.java  # 降级实现
│   │   └── security/                         # JWT/认证组件
│   │       ├── JwtTokenProvider.java
│   │       └── JwtAuthenticationFilter.java
│   ├── domain/                               # 服务私有领域模型
│   │   ├── event/                            # 领域事件
│   │   │   └── OrderCreatedEvent.java
│   │   └── valueobject/                      # 值对象
│   ├── service/                              # Service 层
│   │   ├── OrderService.java
│   │   └── OrderServiceImpl.java
│   ├── repository/                           # Repository 层
│   │   ├── OrderRepository.java
│   │   ├── entity/                           # 持久化模型
│   │   │   └── OrderEntity.java
│   │   └── query/                            # 临时读模型（统计/报表）
│   │       └── OrderStatDTO.java
│   ├── controller/                           # Controller 层
│   │   └── OrderController.java
│   ├── dto/                                  # 请求/响应 DTO
│   │   ├── OrderCreateRequest.java
│   │   └── OrderDetailVO.java
│   ├── errorcode/                            # 业务错误码
│   │   └── OrderErrorCode.java
│   └── converter/                            # 模型转换器
│       └── OrderConverter.java
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-prod.yml
│   ├── bootstrap.yml                         # 配置中心引导配置（Nacos/Apollo）
│   ├── logback-spring.xml
│   ├── db/migration/                         # Flyway 迁移脚本
│   └── mapper/                               # MyBatis XML（选用 MyBatis 时）
├── src/test/java/
└── docs/
```

## 边界与依赖

### MUST
1. 服务内部 `domain` 模型仅服务私有，禁止被其他服务直接依赖。
2. 对外通信契约统一放 `api/openapi/` 或 `api/proto/`。
3. 其他服务只能依赖契约与生成代码（Feign 接口 / gRPC Stub），不能依赖本服务内部 Entity/Model。
4. 启动类只做启动和组件扫描，不承载业务逻辑。
5. 服务间调用通过 Feign Client 或 gRPC Stub，禁止直接引用对方 Service 类。

## 异常组织规则

### MUST
1. `common/exception` 提供通用异常基类和全局异常处理器，不承载业务语义。
2. `common/errorcode` 提供通用错误码（`INTERNAL_ERROR`、`INVALID_PARAM`），不承载业务语义。
3. 业务错误码放在 `errorcode/` 包（服务级），如 `OrderErrorCode.java`。
4. 全局异常处理器统一在 `common/exception/GlobalExceptionHandler.java` 实现。

## 数据模型组织规则

### MUST
1. 持久化模型放在 `repository/entity/`，用于常规查询与写入。
2. 统计分析、多表聚合查询的临时读模型放在 `repository/query/`。
3. 临时读模型仅用于读取结果承载，禁止作为常规写入模型或替代持久化模型。
4. 持久化模型与临时读模型都必须按职责独立文件，禁止 `Models.java` 式汇总文件。
5. DTO 放在 `dto/` 包，仅在 Controller 层使用。

## Feign 客户端组织规则

### MUST
1. Feign Client 接口统一放在 `infrastructure/feign/`，使用 `@FeignClient` 注解。
2. 每个目标服务对应一个 Feign Client 接口。
3. 必须配置降级实现（`fallback` 或 `fallbackFactory`），禁止下游不可用时直接报错。
4. Feign 配置（超时、重试、编解码器）统一在 `config/FeignConfig.java` 中管理。
5. Feign Client 禁止返回对方服务的内部 Entity 类型，必须定义独立的 Response DTO。

## 消息通信组织规则

### MUST
1. 消息生产者封装在 `infrastructure/messaging/producer/`。
2. 消息消费者封装在 `infrastructure/messaging/consumer/`。
3. 消息事件类定义在 `domain/event/`，包含事件 ID、类型、版本号、时间戳、payload。
4. 消费者必须实现幂等消费（参见 `messaging.md`）。

## 组件初始化规则

### MUST
1. 基础设施组件统一在 `config/` 或 `infrastructure/` 中通过 `@Configuration` + `@Bean` 创建。
2. 禁止在业务层直接初始化基础组件（Redis、OSS、MQ 客户端等）。
3. 组件失败默认快速失败；非关键可选组件需明确定义降级策略并记录日志。
