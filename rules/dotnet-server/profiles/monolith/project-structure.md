# rules/dotnet-server/profiles/monolith/project-structure.md

## 适用场景
1. 单进程部署的 .NET 应用，含管理后台 API、业务 API、后台任务等。
2. 默认采用"模块化单体（Modular Monolith）"而非平铺式目录。

## 推荐解决方案结构
```text
MyApp/
├── src/
│   ├── MyApp.Api/                              # Web API 启动项目
│   │   ├── Program.cs                          # 仅启动、DI 注册和中间件管道
│   │   ├── appsettings.json                    # 默认配置
│   │   ├── appsettings.Development.json        # 开发环境配置
│   │   ├── appsettings.Production.json         # 生产环境配置
│   │   ├── Controllers/                        # Controller 或 Minimal API Endpoints
│   │   │   ├── Admin/                          # 后台管理端 Controller
│   │   │   │   └── UserController.cs
│   │   │   └── Client/                         # 用户端 Controller
│   │   │       └── OrderController.cs
│   │   ├── Middlewares/                         # 自定义中间件
│   │   │   ├── GlobalExceptionHandler.cs       # 统一异常处理
│   │   │   └── RequestIdMiddleware.cs          # RequestId 注入
│   │   ├── Filters/                            # Action Filters
│   │   │   └── ValidationFilter.cs             # 参数校验过滤器
│   │   ├── Auth/                               # 认证授权配置
│   │   │   ├── AdminAuthHandler.cs             # 后台管理端认证
│   │   │   └── ClientAuthHandler.cs            # 用户端认证
│   │   └── Dto/                                # 请求/响应 DTO
│   │       ├── Requests/
│   │       └── Responses/
│   │           └── ApiResponse.cs              # 统一响应结构
│   │
│   ├── MyApp.Application/                      # 应用服务层（用例编排）
│   │   ├── Users/                              # 按业务模块组织
│   │   │   ├── IUserService.cs
│   │   │   ├── UserService.cs
│   │   │   └── Validators/
│   │   │       └── CreateUserValidator.cs      # FluentValidation
│   │   └── Orders/
│   │       ├── IOrderService.cs
│   │       └── OrderService.cs
│   │
│   ├── MyApp.Domain/                           # 领域层（实体、领域规则、业务异常）
│   │   ├── Entities/
│   │   │   ├── User.cs                         # 领域实体
│   │   │   └── Order.cs
│   │   ├── Exceptions/                         # 业务异常
│   │   │   ├── BusinessException.cs            # 基类
│   │   │   ├── UserException.cs                # 用户域异常
│   │   │   └── OrderException.cs               # 订单域异常
│   │   ├── ErrorCodes/                         # 错误码常量
│   │   │   ├── UserErrorCodes.cs
│   │   │   └── OrderErrorCodes.cs
│   │   └── Interfaces/                         # Repository 接口定义
│   │       ├── IUserRepository.cs
│   │       └── IOrderRepository.cs
│   │
│   ├── MyApp.Infrastructure/                   # 基础设施层（数据访问、外部服务）
│   │   ├── Data/                               # 数据库相关
│   │   │   ├── AppDbContext.cs                  # EF Core DbContext
│   │   │   ├── Configurations/                 # 实体 Fluent API 配置
│   │   │   │   ├── UserConfiguration.cs
│   │   │   │   └── OrderConfiguration.cs
│   │   │   ├── Repositories/                   # Repository 实现
│   │   │   │   ├── UserRepository.cs
│   │   │   │   └── OrderRepository.cs
│   │   │   ├── Queries/                        # 投影 DTO（统计/报表）
│   │   │   │   └── OrderStatDto.cs
│   │   │   └── Migrations/                     # EF Core 迁移文件
│   │   ├── Caching/                            # 缓存实现
│   │   │   ├── CacheKeys.cs                    # 缓存键集中定义
│   │   │   └── RedisCacheService.cs
│   │   ├── Storage/                            # 对象存储实现
│   │   │   └── MinioStorageService.cs
│   │   └── Extensions/                         # DI 注册扩展方法
│   │       ├── DatabaseExtensions.cs
│   │       ├── RedisExtensions.cs
│   │       ├── MinioExtensions.cs
│   │       ├── JwtExtensions.cs
│   │       └── HealthCheckExtensions.cs
│   │
│   └── MyApp.Shared/                           # 跨层共享（仅技术组件，无业务语义）
│       ├── Options/                            # 强类型配置类
│       │   ├── DatabaseOptions.cs
│       │   ├── RedisOptions.cs
│       │   └── MinioOptions.cs
│       └── Constants/                          # 公共常量
│
├── tests/
│   ├── MyApp.UnitTests/                        # 单元测试
│   ├── MyApp.IntegrationTests/                 # 集成测试
│   └── MyApp.Api.Tests/                        # API 集成测试（WebApplicationFactory）
│
├── docs/
│   ├── api/                                    # OpenAPI 文档
│   └── migrations/                             # 数据库迁移说明
│
├── scripts/                                    # 构建/部署脚本
├── Dockerfile
├── docker-compose.yml
├── Directory.Build.props                       # 全局构建属性
├── Directory.Packages.props                    # Central Package Management
└── MyApp.sln
```

## 模块边界
1. 模块内依赖只允许 `Api -> Application -> Domain`，`Infrastructure -> Domain`。
2. `Domain` 层不反向依赖外层实现细节（依赖倒置原则）。
3. `Api` 项目引用 `Application` 和 `Infrastructure`（用于 DI 注册），但 Controller 只调用 `Application` 层接口。
4. `Application` 层依赖 `Domain` 层接口，不依赖 `Infrastructure` 实现。
5. `Infrastructure` 实现 `Domain` 层定义的 Repository 接口。
6. `Shared` 只允许沉淀无业务语义的技术组件（配置类、常量、通用工具），不允许放业务实体。

## 认证中间件组织规则
1. 不同作用域（Admin/Client）的认证处理器必须独立实现（`AdminAuthHandler.cs`、`ClientAuthHandler.cs`）。
2. 禁止在同一个 AuthenticationHandler 中通过 `if` 分支区分作用域，必须拆成独立实现和独立 Scheme。
3. 授权策略按作用域独立配置。

## 错误组织规则
1. 业务异常按作用域拆分到 `Domain/Exceptions/`，每个域独立文件。
2. 错误码按作用域拆分到 `Domain/ErrorCodes/`，每个域独立文件。
3. 统一异常处理中间件在 `Api/Middlewares/GlobalExceptionHandler.cs`，负责将异常映射为统一响应。

## 数据模型组织规则
1. 领域实体放在 `Domain/Entities/`，用于表达业务语义。
2. EF Core 实体配置放在 `Infrastructure/Data/Configurations/`，每个实体独立配置文件。
3. Repository 实现放在 `Infrastructure/Data/Repositories/`。
4. 统计/报表投影 DTO 放在 `Infrastructure/Data/Queries/`，仅用于读取结果承载。
5. 请求/响应 DTO 放在 `Api/Dto/`，仅用于协议层。

## 组件初始化规则
1. 各基础组件注册封装为独立扩展方法（`Infrastructure/Extensions/`），在 `Program.cs` 调用。
2. 强类型配置类放在 `Shared/Options/`，使用 Options Pattern 绑定和校验。
3. 初始化顺序在 `Program.cs` 中可读可验证。
4. 组件失败默认快速失败，非关键可选组件需明确定义降级策略。

## 额外约束
1. `Program.cs` 只做装配，不做业务判断，不写 LINQ 查询。
2. 系统异常必须记录并由统一中间件映射为业务错误响应，禁止直接返回异常堆栈。
3. 生产环境必须禁用 Swagger UI 或通过鉴权保护。
