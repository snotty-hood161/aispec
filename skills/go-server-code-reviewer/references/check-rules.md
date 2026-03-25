# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（golangci-lint/go vet）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、编码基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Go 版本 ≥ 1.21，go.mod 中明确声明 | 静态扫描：检查 go.mod |
| BL-02 | P0 | 所有代码通过 gofmt 格式化，无手动风格调整 | 静态扫描：gofmt -d |
| BL-03 | P0 | 使用 goimports 管理导入，分组排列（标准库 / 第三方 / 内部） | 静态扫描：goimports -l |
| BL-04 | P0 | go.mod 中依赖版本锁定，禁止使用 replace 指向本地路径（CI 环境） | 静态扫描：检查 go.mod replace 指令 |
| BL-05 | P1 | 启用 golangci-lint 并配置 .golangci.yml，CI 中零告警通过 | 静态扫描：golangci-lint run |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 导出标识符必须有 GoDoc 注释 | 静态扫描：golangci-lint（revive exported） |
| CS-02 | P0 | 包名小写单词，禁止下划线和大写 | 模式匹配：检查 package 声明 |
| CS-03 | P1 | 变量/函数命名遵循 Go 惯例（MixedCaps），禁止 snake_case | 静态扫描：golangci-lint（stylecheck） |
| CS-04 | P1 | 单个函数体不超过 80 行，圈复杂度 ≤ 15 | 静态扫描：golangci-lint（cyclop/funlen） |
| CS-05 | P0 | 分层架构：handler → service → repository，禁止跨层调用 | 人工审查：检查 import 依赖方向 |

## 三、组件初始化（common/component-initialization.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CI-01 | P0 | 使用依赖注入（构造函数注入），禁止 init() 中初始化业务组件 | 模式匹配：搜索 func init() 中的业务逻辑 |
| CI-02 | P0 | 组件生命周期明确：启动顺序可控，关闭时逆序释放资源 | 人工审查：检查 main/启动编排 |
| CI-03 | P1 | 健康检查端点（/healthz, /readyz）已注册并验证依赖可用性 | 模式匹配：搜索健康检查路由注册 |
| CI-04 | P1 | 外部依赖（DB/Redis/MQ）连接在启动时验证，失败则阻止启动 | 人工审查：检查启动流程 |

## 四、API 设计（common/api-design.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AD-01 | P0 | API 路径包含版本号（/api/v1/...），版本变更有迁移方案 | 模式匹配：检查路由注册路径 |
| AD-02 | P0 | 统一响应结构：{code, message, data}，禁止裸返回 | 模式匹配：检查 handler 返回格式 |
| AD-03 | P0 | 请求参数绑定后必须校验（validator tag 或自定义校验） | 模式匹配：搜索 ShouldBind 后是否有 validate |
| AD-04 | P1 | 分页接口使用统一分页结构，默认页大小有上限 | 模式匹配：搜索分页参数定义 |
| AD-05 | P1 | 接口文档（Swagger/OpenAPI）与代码同步，CI 中校验 | 人工审查：检查 swag 注解是否完整 |

## 五、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 所有 error 返回值必须检查，禁止 _ 忽略 | 静态扫描：golangci-lint（errcheck） |
| EH-02 | P0 | 错误向上传播时必须 wrap 上下文：fmt.Errorf("xxx: %w", err) | 模式匹配：搜索 return err（无 wrap） |
| EH-03 | P0 | 业务错误码体系统一定义，禁止硬编码字符串错误 | 模式匹配：搜索 errors.New 中的硬编码消息 |
| EH-04 | P1 | panic 仅用于不可恢复错误，业务逻辑禁止 panic | 模式匹配：搜索 panic() 调用位置 |
| EH-05 | P1 | HTTP handler 层统一错误处理中间件，禁止各 handler 自行格式化错误响应 | 人工审查：检查错误响应一致性 |

## 六、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 日志必须结构化输出（JSON），禁止 fmt.Println/log.Println | 模式匹配：搜索 fmt.Print/log.Print 调用 |
| OB-02 | P0 | 日志必须携带 trace_id / request_id，从 context 中提取 | 模式匹配：搜索日志调用是否传入 ctx |
| OB-03 | P1 | 关键业务操作埋点 metrics（请求量/延迟/错误率） | 人工审查：检查 metrics 注册 |
| OB-04 | P1 | 链路追踪 span 覆盖跨服务调用与数据库操作 | 人工审查：检查 span 创建位置 |
| OB-05 | P1 | 日志级别分层使用（Debug/Info/Warn/Error），错误日志包含堆栈 | 模式匹配：检查日志级别使用合理性 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置（密码/密钥/Token）禁止硬编码或提交到代码仓库 | 静态扫描：搜索硬编码密码/密钥模式 |
| CF-02 | P0 | 配置通过环境变量或配置中心注入，支持多环境切换 | 模式匹配：检查配置加载方式 |
| CF-03 | P1 | 配置结构体定义集中管理，使用 mapstructure/viper 绑定 | 模式匹配：搜索配置结构定义 |
| CF-04 | P1 | 配置项有默认值与校验，缺失必要配置时启动失败并输出明确提示 | 人工审查：检查配置校验逻辑 |

## 八、并发与资源管理（common/concurrency-and-resource.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CR-01 | P0 | goroutine 必须可控退出，禁止裸 go func() 无回收机制 | 模式匹配：搜索 go func 是否有 context/errgroup 管理 |
| CR-02 | P0 | context.Context 作为首参传递，禁止使用 context.Background() 于业务逻辑 | 模式匹配：搜索函数签名首参是否为 ctx |
| CR-03 | P0 | 优雅停机：监听 SIGTERM/SIGINT，超时强制退出 | 模式匹配：搜索 signal.Notify 与 Shutdown |
| CR-04 | P1 | 连接池（DB/Redis/HTTP Client）有大小限制与超时配置 | 人工审查：检查连接池参数 |
| CR-05 | P1 | 共享资源访问使用 sync.Mutex/RWMutex 或 channel，禁止无保护并发读写 | 静态扫描：go vet -race / golangci-lint |

## 九、数据库访问（common/database-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库操作必须通过 Repository 层，禁止 handler/service 直接拼 SQL | 模式匹配：搜索 handler/service 中的 SQL 操作 |
| DA-02 | P0 | 查询必须参数化，禁止字符串拼接 SQL（防注入） | 模式匹配：搜索字符串拼接 SQL 模式 |
| DA-03 | P0 | 事务边界在 service 层控制，Repository 层不自行开启事务 | 人工审查：检查事务管理位置 |
| DA-04 | P1 | 批量操作使用 Batch Insert/Update，禁止循环单条操作 | 模式匹配：搜索循环内的 DB 调用 |
| DA-05 | P1 | 数据库迁移使用版本化工具（golang-migrate/goose），禁止手动 DDL | 人工审查：检查迁移文件管理 |
| DA-06 | P1 | 慢查询有监控告警，查询超时有上限配置 | 人工审查：检查慢查询日志配置 |

## 十、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 所有外部输入必须校验与清洗，禁止直接信任用户输入 | 模式匹配：检查输入绑定后是否有校验 |
| SC-02 | P0 | 鉴权中间件覆盖所有受保护路由，禁止路由遗漏 | 模式匹配：检查路由分组与中间件绑定 |
| SC-03 | P0 | 敏感数据（密码/Token）禁止明文日志输出 | 模式匹配：搜索日志中的敏感字段 |
| SC-04 | P1 | CORS 配置白名单化，禁止 AllowAll 用于生产 | 模式匹配：搜索 CORS 配置 |
| SC-05 | P1 | 接口限流（Rate Limiting）已配置，防止暴力请求 | 人工审查：检查限流中间件 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | 核心业务逻辑有单元测试，覆盖率 ≥ 60% | 静态扫描：go test -cover |
| TR-02 | P0 | 测试文件命名 *_test.go，与被测文件同目录 | 模式匹配：检查测试文件位置 |
| TR-03 | P1 | 表驱动测试（Table-Driven Tests）用于多场景验证 | 模式匹配：搜索测试函数中的 []struct 模式 |
| TR-04 | P1 | CI 流水线包含 lint → test → build 阶段，质量门禁阻断不合格构建 | 人工审查：检查 CI 配置 |
| TR-05 | P1 | API 接口有集成测试，覆盖核心业务路径 | 人工审查：检查集成测试存在性 |

## 十二、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P1 | 提供 pprof 端点（/debug/pprof），生产环境限制访问 | 模式匹配：搜索 pprof 注册与访问控制 |
| PF-02 | P1 | 大对象使用 sync.Pool 复用，减少 GC 压力 | 模式匹配：搜索频繁分配的大对象 |
| PF-03 | P1 | 数据库查询有索引覆盖，禁止全表扫描（EXPLAIN 验证） | 人工审查：检查查询与索引匹配 |
| PF-04 | P1 | JSON 序列化热点路径考虑使用 sonic/jsoniter 替代 encoding/json | 人工审查：检查高频序列化路径 |

## 十三、缓存（common/caching.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CA-01 | P0 | 缓存键设计包含业务前缀与版本号，避免键冲突 | 模式匹配：检查缓存键构造模式 |
| CA-02 | P0 | 所有缓存必须设置 TTL，禁止无过期时间的缓存 | 模式匹配：搜索 Set 调用是否带 TTL 参数 |
| CA-03 | P1 | 缓存穿透/击穿/雪崩有防护措施（singleflight/布隆过滤） | 人工审查：检查缓存防护策略 |
| CA-04 | P1 | 缓存与数据库一致性策略明确（Cache Aside / Write Through） | 人工审查：检查缓存更新逻辑 |

## 十四、文件存储（common/file-storage.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FS-01 | P0 | 文件上传限制大小与类型，校验 MIME Type | 模式匹配：检查上传处理中的校验逻辑 |
| FS-02 | P0 | 文件使用流式读写（io.Reader/Writer），禁止全量加载到内存 | 模式匹配：搜索 ioutil.ReadAll 用于大文件 |
| FS-03 | P1 | 文件存储路径使用唯一标识（UUID/Hash），禁止用户原始文件名 | 模式匹配：检查文件存储路径生成 |
| FS-04 | P1 | 对象存储使用预签名 URL 直传，减少服务端中转 | 人工审查：检查上传流程架构 |

## 十五、定时任务（common/scheduled-tasks.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| ST-01 | P0 | 定时任务必须幂等，重复执行不产生副作用 | 人工审查：检查任务逻辑幂等性 |
| ST-02 | P0 | 多实例部署时使用分布式锁，防止任务重复执行 | 模式匹配：搜索分布式锁获取逻辑 |
| ST-03 | P1 | 任务执行有超时控制与失败重试机制 | 模式匹配：搜索超时与重试配置 |
| ST-04 | P1 | 任务执行结果有日志记录与监控告警 | 人工审查：检查任务日志与监控 |

## 十六、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止在生产代码中使用 fmt.Println / log.Fatal 输出日志 | 静态扫描：golangci-lint（forbidigo） |
| FB-02 | P0 | 禁止提交包含密钥/密码/Token 的代码 | 静态扫描：git-secrets / gitleaks |
| FB-03 | P0 | 禁止使用 ioutil 包（Go 1.16 已废弃） | 静态扫描：golangci-lint（staticcheck SA1019） |
| FB-04 | P0 | 禁止忽略 error 返回值（_ = SomeFunc()） | 静态扫描：golangci-lint（errcheck） |
| FB-05 | P0 | 禁止在 handler 中直接操作数据库，必须经过 service 层 | 模式匹配：搜索 handler 中的 DB 调用 |

---

## Profile 专项检查

### Monolith 专项（profiles/monolith/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MO-01 | P0 | 模块间通过接口（interface）解耦，禁止直接引用其他模块实现 | 模式匹配：检查 import 中的跨模块引用 |
| MO-02 | P1 | 模块边界清晰，每个模块有独立的 handler/service/repository 层 | 人工审查：检查目录结构 |
| MO-03 | P1 | 共享组件（中间件/工具函数）集中于 pkg/common 目录 | 模式匹配：检查共享代码位置 |
| MO-04 | P1 | 模块间数据传递使用 DTO，禁止直接共享数据库 Model | 模式匹配：搜索跨模块的 model 引用 |

### Microservice 专项（profiles/microservice/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MS-01 | P0 | 服务间通信使用 gRPC/HTTP + 统一序列化，禁止私有协议 | 模式匹配：检查服务间调用方式 |
| MS-02 | P0 | 外部调用有超时、重试与熔断配置 | 模式匹配：搜索 HTTP/gRPC Client 配置 |
| MS-03 | P1 | 服务注册与发现配置正确，健康检查端点可用 | 人工审查：检查服务注册配置 |
| MS-04 | P1 | 分布式事务使用 Saga/TCC 模式，禁止跨服务本地事务 | 人工审查：检查跨服务事务处理 |
| MS-05 | P1 | 服务间通信携带 trace_id，链路追踪完整 | 模式匹配：检查调用链 header 传播 |
