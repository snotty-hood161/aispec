# rules/go-server/profiles/microservice/project-structure.md

## 适用场景
1. 独立部署、独立伸缩、独立发布的 Go 微服务。
2. 每个服务仓库或每个服务目录都应作为独立可交付单元。

## 推荐目录结构
```text
.
├── cmd/
│   ├── http-server/main.go             # 对外 API
│   ├── grpc-server/main.go             # 可选
│   └── worker/main.go                  # 消费或异步任务
├── api/
│   ├── openapi/                        # HTTP 对外契约源（OpenAPI 3.x）
│   └── proto/                          # gRPC 对外契约源（proto3）
├── configs/
│   ├── application.yml                 # 默认配置
│   ├── application-dev.yml             # 开发环境配置
│   └── application-prod.yml            # 生产环境配置
├── docs/
│   └── migrations/
├── pkg/
│   ├── middleware/                      # 可跨服务复用中间件（无业务语义）
│   │   ├── cors.go                      # 跨域策略
│   │   ├── request_id.go                # 请求标识注入
│   │   ├── logging.go                   # 访问日志
│   │   └── recovery.go                  # panic 恢复
│   └── errkit/                           # 通用错误机制（无业务语义）
│       ├── error.go                     # 通用错误类型
│       ├── code.go                      # 错误码类型与枚举
│       └── wrap.go                      # 包装与辅助函数
├── internal/
│   ├── app/
│   │   └── bootstrap/
│   │       ├── container.go            # 组件容器定义
│   │       ├── providers.go            # 组件构建顺序与依赖注入
│   │       └── shutdown.go             # 统一优雅关闭
│   ├── platform/
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
│   ├── domain/                         # 服务私有领域模型
│   │   ├── user_error.go               # 用户域业务错误
│   │   └── order_error.go              # 订单域业务错误
│   ├── service/
│   ├── repository/
│   │   ├── model/
│   │   │   └── order_model.go          # 持久化模型（映射表结构）
│   │   └── query/
│   │       └── order_stat_row.go       # 临时读模型（统计/报表）
│   └── transport/
│       ├── http/
│       │   └── middleware/
│       │       ├── admin/
│       │       │   ├── auth.go         # 后台管理端认证
│       │       │   └── permission.go   # 后台管理端权限
│       │       └── user/
│       │           ├── auth.go         # 用户端认证
│       │           └── permission.go   # 用户端权限
│       ├── grpc/
│       └── event/
├── scripts/
└── test/
```

## 边界与依赖
1. `internal/domain` 仅服务内部使用，禁止被其他服务直接 import。
2. 对外通信契约统一放 `api/openapi` 或 `api/proto`。
3. 其他服务只能依赖契约与生成代码，不能依赖本服务内部 model。
4. `cmd/*/main.go` 只做装配，不承载业务逻辑。

## 中间件组织规则
1. 公共中间件放 `pkg/middleware`，仅提供技术能力，不承载业务语义。
2. 作用域中间件放 `internal/transport/http/middleware/<scope>`，如 `admin/auth.go`、`user/auth.go`。
3. 必须按“作用域 + 职责”拆文件：每个作用域或职责一个文件，不允许把 `admin` 与 `user` 鉴权揉在同一实现里。
4. 禁止新增“汇总式”中间件文件（如 `middlewares.go`）承载多个无关责任。
5. `cors` 中间件的 `allowed_origins` 必须从配置加载并支持多值，禁止在代码写死域名。

## 错误组织规则
1. `pkg/errkit` 仅提供通用错误机制，不承载 `user`、`order`、`admin` 等业务语义错误。
2. 业务错误按作用域拆分到 `internal`（如 `user_error.go`、`order_error.go`），每个作用域独立文件。
3. 系统错误必须在 `platform/errors` 记录与分类，并在边界层通过统一中间件映射为业务错误响应。

## 数据模型组织规则
1. 持久化模型放在 `internal/repository/model`，用于常规查询与写入。
2. 统计分析、多表聚合查询的临时读模型放在 `internal/repository/query`。
3. 临时读模型仅用于读取结果承载，禁止作为常规写入模型或替代持久化模型。
4. 持久化模型与临时读模型都必须按职责独立文件，禁止 `models.go` 式汇总文件。

## 组件初始化规则
1. 组件装配统一在 `internal/app/bootstrap`，禁止在业务层直接初始化基础组件。
2. 平台组件统一放在 `internal/platform/<component>`，如 `logger`、`database`、`gorm`、`redis`、`minio`、`jwt`。
3. 初始化顺序与关闭顺序必须可读可验证：先初始化配置与日志，后初始化外部依赖，关闭顺序反向执行。
4. 组件失败默认快速失败，非关键可选组件需明确定义降级策略并记录日志。
