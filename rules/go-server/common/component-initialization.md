# rules/go-server/common/component-initialization.md

## 目标
1. 统一服务端组件初始化方案，避免隐藏依赖、全局单例滥用和启动顺序漂移。
2. 覆盖常见基础组件：日志、数据库/GORM、Redis、MinIO、JWT。

## DI 总体策略
1. 默认采用手动 DI（构造函数注入），依赖必须显式传参，不得隐式获取。
2. 允许使用编译期注入工具（如 `google/wire`）；反射型容器仅在评审通过后使用。
3. 组装根（Composition Root）必须位于 `cmd/*/main.go` 或 `internal/app/bootstrap`。
4. `main` 仅负责：加载配置、构建组件、注册模块、启动服务、优雅退出。

## 初始化与生命周期
1. 推荐初始化顺序：`config -> logger -> metrics/tracing -> db -> gorm -> redis -> minio -> jwt -> repository -> service -> transport`。
2. 组件初始化失败的默认策略是快速失败（fail fast）；可选组件需明确定义降级策略并记录日志。
3. 所有可关闭组件必须实现统一关闭路径，关闭顺序与初始化顺序相反。
4. 进程退出时必须有超时控制，避免阻塞在资源回收阶段。

## 健康检查与就绪检查
1. 服务必须提供存活探针与就绪探针（建议 `/healthz` 与 `/readyz`）。
2. 存活探针仅反映进程可运行状态，不应依赖慢速外部依赖检查。
3. 就绪探针必须反映关键依赖可用性（如数据库、关键缓存、关键消息链路）。
4. 非关键可选依赖故障时可继续就绪，但必须有降级标识和告警日志。
5. 探针结果必须可观测：失败原因应写入结构化日志并附带 `request_id/trace_id`（如有）。

## 组件接口约束
1. 每个组件包至少提供 `Config`、`New`、`Close`（如适用）和 `Health`（如适用）能力。
2. 禁止在业务代码中直接构造第三方客户端，必须通过组件层提供的实例注入。
3. 组件日志必须脱敏，禁止打印密钥、令牌、连接串完整内容。

## 目录与职责
1. 组件实现放在 `internal/platform/<component>`，例如：
2. `internal/platform/logger`
3. `internal/platform/database`
4. `internal/platform/gorm`
5. `internal/platform/redis`
6. `internal/platform/minio`
7. `internal/platform/jwt`
8. 组件装配代码放在 `internal/app/bootstrap`，如 `container.go`、`providers.go`、`shutdown.go`。

## 重点组件规则
1. 数据库组件负责连接池、超时与健康检查，不承载业务 SQL。
2. GORM 组件必须复用数据库连接配置，禁止与数据库组件配置漂移。
3. Redis 组件必须配置超时、重试和连接池，禁止默认无限制。
4. MinIO 组件必须显式配置 endpoint、bucket、TLS 策略与超时。
5. JWT 组件必须显式配置签名算法、密钥来源、过期策略，禁止硬编码密钥。
6. 日志组件必须优先初始化，保证后续组件初始化失败可被记录。

## 可测试性要求
1. 使用方依赖接口而非具体客户端类型，便于注入 mock 或 fake。
2. 组件构造函数必须可在测试中传入替代配置或替代依赖。
3. 禁止在测试中依赖全局可变单例状态。

## 禁止事项
1. 禁止在 `init()` 中建立数据库、Redis、MinIO 等外部连接。
2. 禁止通过包级全局变量暴露可变组件实例（如全局 `DB`、全局 `RedisClient`）。
3. 禁止在 handler/service 中直接 `gorm.Open`、`redis.NewClient`、`minio.New`、`jwt` 组件构造。
