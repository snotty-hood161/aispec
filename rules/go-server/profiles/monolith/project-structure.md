# rules/go-server/profiles/monolith/project-structure.md

## 适用场景
1. 单进程部署的 Go 应用，含管理后台 API、业务 API、任务调度等。
2. 默认采用“模块化单体（Modular Monolith）”而非脚手架式平铺目录。

## 推荐目录结构
```text
.
├── cmd/
│   └── server/
│       └── main.go                     # 仅启动和依赖组装
├── configs/
│   ├── application.yml                 # 默认配置
│   ├── application-dev.yml             # 开发环境配置
│   └── application-prod.yml            # 生产环境配置
├── docs/
│   ├── api/                             # 默认 `openapi.yaml`
│   └── migrations/
├── pkg/
│   ├── middleware/                      # 可复用 HTTP 中间件（无业务语义）
│   │   ├── cors.go                      # 跨域策略
│   │   ├── request_id.go                # 请求标识注入
│   │   ├── logging.go                   # 访问日志
│   │   ├── recovery.go                  # panic 恢复
│   │   └── ratelimit.go                 # 通用限流（可选）
│   └── errkit/                           # 通用错误机制（无业务语义）
│       ├── error.go                     # 通用错误类型
│       ├── code.go                      # 错误码类型与枚举
│       └── wrap.go                      # 包装与辅助函数
├── internal/
│   ├── app/                            # 生命周期、路由装配、模块注册
│   │   ├── bootstrap/
│   │   │   ├── container.go            # 组件容器定义
│   │   │   ├── providers.go            # 组件构建顺序与依赖注入
│   │   │   └── shutdown.go             # 统一优雅关闭
│   │   └── http/
│   │       └── middleware/             # 作用域中间件（有业务语义）
│   │           ├── admin/
│   │           │   ├── auth.go         # 后台管理端认证
│   │           │   └── permission.go   # 后台管理端权限
│   │           └── user/
│   │               ├── auth.go         # 用户端认证
│   │               └── permission.go   # 用户端权限
│   ├── platform/                       # db/cache/queue/http client/logger 等基础设施
│   │   ├── logger/
│   │   │   └── component.go            # 日志组件初始化
│   │   ├── database/
│   │   │   └── component.go            # 数据库连接组件初始化
│   │   ├── gorm/
│   │   │   └── component.go            # GORM 组件初始化
│   │   ├── redis/
│   │   │   └── component.go            # Redis 组件初始化
│   │   ├── minio/
│   │   │   └── component.go            # MinIO 组件初始化
│   │   ├── jwt/
│   │   │   └── component.go            # JWT 组件初始化
│   │   └── errors/
│   │       └── system_error.go         # 系统错误分类（仅内部）
│   ├── shared/                         # 跨模块共享能力（仅技术组件）
│   └── modules/
│       ├── user/
│       │   ├── domain/                 # 领域对象和领域规则（服务私有）
│       │   │   └── user_error.go       # 用户域业务错误
│       │   ├── service/                # 用例编排与事务边界
│       │   ├── repository/             # 数据访问实现
│       │   │   ├── model/
│       │   │   │   └── user_model.go   # 持久化模型（映射表结构）
│       │   │   └── query/
│       │   │       └── user_stat_row.go # 临时读模型（统计/报表）
│       │   ├── transport/
│       │   │   ├── http/
│       │   │   └── dto/
│       │   └── module.go               # 模块装配入口
│       └── order/
│           └── domain/
│               └── order_error.go      # 订单域业务错误
├── scripts/
└── test/
```

## 模块边界
1. 模块内依赖只允许 `transport -> service -> repository`。
2. `domain` 不反向依赖外层实现细节。
3. 模块之间禁止直接调用对方 `repository`。
4. 跨模块协作通过 `service` 接口或模块 Facade。
5. `internal/modules/<module>/domain` 是私有模型，不用于跨服务共享。

## 中间件组织规则
1. `pkg/middleware` 只放“跨作用域可复用”的技术中间件，如 `cors`、`request_id`、`recovery`。
2. 带业务作用域语义的中间件必须放 `internal/app/http/middleware/<scope>`，例如 `admin/auth.go`、`user/auth.go`。
3. 必须按“作用域 + 职责”拆分：每个作用域或职责一个独立文件，禁止把多个责任揉进同一个大文件。
4. 文件命名使用职责语义，如 `auth.go`、`permission.go`、`tenant.go`，避免 `misc.go`、`common.go`。
5. 模块私有中间件放在 `internal/modules/<module>/transport/http/middleware`，不放入公共 `pkg`。
6. 禁止把 `admin` 和 `user` 认证写在同一个中间件里靠 `if` 分支区分，必须拆成独立实现和独立路由装配。
7. `cors` 中间件的 `allowed_origins` 必须从配置加载并支持多值，禁止在代码写死域名。

## 错误组织规则
1. `pkg/errkit` 仅提供通用错误机制，不承载 `user`、`order`、`admin` 等业务语义错误。
2. 业务错误按作用域拆分到 `internal/modules/<module>/domain/*_error.go`，每个作用域独立文件。
3. 系统错误必须在 `internal/platform/errors/system_error.go` 记录与分类，并在边界层通过统一中间件映射为业务错误响应。

## 数据模型组织规则
1. 模块持久化模型放在 `internal/modules/<module>/repository/model`，用于常规查询与写入。
2. 统计分析、多表聚合查询的临时读模型放在 `internal/modules/<module>/repository/query`。
3. 临时读模型仅用于读取结果承载，禁止作为常规写入模型或替代持久化模型。
4. 持久化模型与临时读模型都必须按职责独立文件，禁止 `models.go` 式汇总文件。

## 组件初始化规则
1. 组件装配统一在 `internal/app/bootstrap`，禁止在业务层直接初始化基础组件。
2. 平台组件统一放在 `internal/platform/<component>`，如 `logger`、`database`、`gorm`、`redis`、`minio`、`jwt`。
3. 初始化顺序与关闭顺序必须可读可验证：先初始化配置与日志，后初始化外部依赖，关闭顺序反向执行。
4. 组件失败默认快速失败，非关键可选组件需明确定义降级策略并记录日志。

## 额外约束
1. `internal/shared` 只允许沉淀无业务语义组件，不允许放业务实体。
2. `main.go` 只做装配，不做业务判断，不写 SQL。
3. 系统错误必须记录并由统一中间件映射为业务错误响应，禁止直接返回 `system_error` 原文。
