# rules/java-server/profiles/monolith/project-structure.md

## 适用场景
1. 单进程部署的 Java/Spring Boot 应用，含管理后台 API、业务 API、定时任务等。
2. 默认采用"模块化单体（Modular Monolith）"而非平铺式包结构。

## 推荐目录结构

```text
.
├── pom.xml / build.gradle                  # 根构建文件
├── src/main/java/com/example/app/
│   ├── Application.java                    # @SpringBootApplication 启动类
│   ├── config/                             # 全局配置类
│   │   ├── SecurityConfig.java             # Spring Security 配置
│   │   ├── WebMvcConfig.java               # MVC 配置（CORS、拦截器等）
│   │   ├── CacheConfig.java                # 缓存配置
│   │   ├── AsyncConfig.java                # 异步线程池配置
│   │   └── JacksonConfig.java              # JSON 序列化配置
│   ├── common/                             # 跨模块共享能力（仅技术组件）
│   │   ├── exception/                      # 统一异常定义
│   │   │   ├── BaseException.java
│   │   │   ├── BusinessException.java
│   │   │   ├── SystemException.java
│   │   │   └── GlobalExceptionHandler.java # @ControllerAdvice
│   │   ├── response/                       # 统一响应结构
│   │   │   └── ApiResponse.java
│   │   ├── errorcode/                      # 通用错误码（无业务语义）
│   │   │   └── CommonErrorCode.java
│   │   └── util/                           # 纯工具类（日期、加密等）
│   ├── infrastructure/                     # 基础设施适配层
│   │   ├── persistence/                    # 数据库基础配置
│   │   ├── cache/                          # Redis/Caffeine 配置
│   │   ├── storage/                        # OSS/MinIO 适配
│   │   ├── messaging/                      # MQ 客户端封装
│   │   └── security/                       # JWT/OAuth2 组件
│   │       ├── JwtTokenProvider.java
│   │       └── JwtAuthenticationFilter.java
│   └── modules/                            # 业务模块（模块化单体核心）
│       ├── user/
│       │   ├── controller/                 # 用户模块 Controller
│       │   │   └── UserController.java
│       │   ├── service/                    # 用户模块 Service
│       │   │   ├── UserService.java        # 接口
│       │   │   └── UserServiceImpl.java    # 实现
│       │   ├── repository/                 # 用户模块 Repository
│       │   │   ├── UserRepository.java     # JPA Repository / MyBatis Mapper
│       │   │   └── entity/                 # 持久化模型
│       │   │       └── UserEntity.java
│       │   ├── dto/                        # 请求/响应 DTO
│       │   │   ├── UserCreateRequest.java
│       │   │   └── UserDetailVO.java
│       │   ├── errorcode/                  # 用户模块业务错误码
│       │   │   └── UserErrorCode.java
│       │   └── converter/                  # 模型转换器（MapStruct）
│       │       └── UserConverter.java
│       └── order/
│           ├── controller/
│           ├── service/
│           ├── repository/
│           │   ├── entity/
│           │   │   └── OrderEntity.java    # 持久化模型
│           │   └── query/
│           │       └── OrderStatDTO.java   # 临时读模型（统计/报表）
│           ├── dto/
│           ├── errorcode/
│           │   └── OrderErrorCode.java     # 订单域业务错误码
│           └── converter/
├── src/main/resources/
│   ├── application.yml                     # 默认配置
│   ├── application-dev.yml                 # 开发环境配置
│   ├── application-prod.yml                # 生产环境配置
│   ├── logback-spring.xml                  # 日志配置
│   ├── db/migration/                       # Flyway 迁移脚本
│   └── mapper/                             # MyBatis XML（选用 MyBatis 时）
├── src/test/java/
│   └── com/example/app/
│       └── modules/
│           ├── user/
│           │   ├── service/
│           │   │   └── UserServiceTest.java
│           │   └── controller/
│           │       └── UserControllerTest.java
│           └── order/
└── docs/
    └── api/                                # API 文档
```

## 模块边界

### MUST
1. 模块内依赖只允许 `Controller → Service → Repository`，禁止反向依赖。
2. `domain`/`entity` 不反向依赖外层实现细节。
3. 模块之间禁止直接调用对方 `Repository`，必须通过 `Service` 接口调用。
4. 跨模块协作通过 `Service` 接口或模块 Facade，禁止直接注入对方内部组件。
5. `modules/{module}/errorcode` 是模块私有错误码，不用于跨服务共享。
6. 每个模块必须有独立的 `controller`、`service`、`repository` 包，禁止跨模块共享这些包。

## 异常组织规则

### MUST
1. `common/exception` 仅提供通用异常基类（`BaseException`、`BusinessException`、`SystemException`）和全局异常处理器，不承载业务语义错误。
2. `common/errorcode` 仅提供通用错误码（如 `INTERNAL_ERROR`、`INVALID_PARAM`），不承载 `user`、`order` 等业务语义。
3. 业务错误码按模块拆分到 `modules/{module}/errorcode/`，每个模块独立文件。
4. 全局异常处理器（`@ControllerAdvice`）统一在 `common/exception/GlobalExceptionHandler.java` 中实现，禁止每个模块单独定义异常处理器。

## DTO 与模型组织规则

### MUST
1. 请求/响应 DTO 放在 `modules/{module}/dto/`，仅在 Controller 层使用。
2. 持久化模型（Entity/Model）放在 `modules/{module}/repository/entity/`，仅在 Repository 层使用。
3. 统计分析、多表聚合查询的临时读模型放在 `modules/{module}/repository/query/`。
4. 临时读模型仅用于查询结果承载，禁止用于常规写入或替代持久化模型。
5. 模型转换（Entity ↔ DTO）使用 MapStruct 或手动转换，集中在 `modules/{module}/converter/` 中。
6. 禁止在单个类上混用多层注解（如同时标注 `@Entity` 和 `@JsonProperty`）。

## 配置类组织规则

### MUST
1. 全局配置类统一放在 `config/` 包下，包括 Security、MVC、Cache、Async、Jackson 等。
2. 模块私有配置（如模块内专用的 `@ConfigurationProperties`）放在 `modules/{module}/config/`。
3. 基础设施适配类（Redis、OSS、MQ 客户端封装）统一放在 `infrastructure/` 包下。
4. 禁止在业务代码（Controller/Service）中直接构造基础设施客户端。

## 中间件组织规则

### MUST
1. 全局 Filter/Interceptor（如 RequestId 注入、访问日志、CORS）统一在 `config/WebMvcConfig.java` 或独立 `@Component` 中注册。
2. 带业务作用域的 Filter（如 admin 认证、user 认证）在 `SecurityConfig` 中通过不同的 `SecurityFilterChain` 配置。
3. 禁止把 `admin` 和 `user` 认证写在同一个 Filter 中靠 if 分支区分，必须拆成独立的 `SecurityFilterChain`。
4. CORS 配置的 `allowedOrigins` 必须从配置文件加载，禁止硬编码域名。

## 额外约束

### MUST
1. `common/` 只允许沉淀无业务语义组件（异常基类、响应结构、通用工具），不允许放业务实体。
2. 启动类（`Application.java`）只做启动，不做业务判断，不写 SQL。
3. 系统异常必须记录日志并由 `GlobalExceptionHandler` 映射为业务错误响应，禁止直接返回原始异常信息。
4. `@SpringBootApplication` 的 `scanBasePackages` 必须明确指定，避免扫描范围过大。
