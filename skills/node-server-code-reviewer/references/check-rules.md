# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（ESLint/TypeScript Compiler）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、编码基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Node.js 版本 ≥ 18 LTS，package.json 中 engines 字段明确声明 | 静态扫描：检查 package.json |
| BL-02 | P0 | TypeScript strict 模式开启，tsconfig.json 中 strict: true | 静态扫描：检查 tsconfig.json |
| BL-03 | P0 | 使用 ESLint + Prettier 统一代码风格，CI 中零告警通过 | 静态扫描：eslint . && prettier --check |
| BL-04 | P0 | package-lock.json 或 pnpm-lock.yaml 必须提交，禁止 `npm install --no-package-lock` | 静态扫描：检查锁文件存在 |
| BL-05 | P1 | 启用 husky + lint-staged 预提交检查 | 静态扫描：检查 .husky 配置 |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 导出接口/类型必须有 JSDoc/TSDoc 注释 | 静态扫描：ESLint（jsdoc/require-jsdoc） |
| CS-02 | P0 | 文件命名 kebab-case，类名 PascalCase，变量/函数 camelCase | 模式匹配：ESLint naming-convention |
| CS-03 | P1 | 单个函数体不超过 80 行，圈复杂度 ≤ 15 | 静态扫描：ESLint（complexity/max-lines-per-function） |
| CS-04 | P0 | 分层架构：controller → service → repository，禁止跨层调用 | 人工审查：检查 import 依赖方向 |
| CS-05 | P0 | 禁止使用 `any` 类型（明确豁免场景除外） | 静态扫描：ESLint（@typescript-eslint/no-explicit-any） |

## 三、组件初始化（common/component-initialization.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CI-01 | P0 | 使用依赖注入（NestJS DI / 手动工厂），禁止在 controller/service 直接构造客户端 | 模式匹配：搜索 new 实例化基础设施对象 |
| CI-02 | P0 | 组件生命周期明确：启动顺序可控，关闭时逆序释放资源（onModuleDestroy / graceful shutdown） | 人工审查：检查启动/关闭编排 |
| CI-03 | P1 | 健康检查端点（/healthz, /readyz）已注册并验证依赖可用性 | 模式匹配：搜索健康检查路由注册 |
| CI-04 | P1 | 外部依赖（DB/Redis/MQ）连接在启动时验证，失败则阻止启动 | 人工审查：检查启动流程 |

## 四、API 设计（common/api-design.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AD-01 | P0 | API 路径包含版本号（/api/v1/...），版本变更有迁移方案 | 模式匹配：检查路由注册路径 |
| AD-02 | P0 | 统一响应结构：{code, message, data}，禁止裸返回 | 模式匹配：检查 controller 返回格式 |
| AD-03 | P0 | 请求参数使用 DTO + class-validator / zod / joi 校验，禁止裸取 body | 模式匹配：搜索参数绑定后是否有校验 |
| AD-04 | P1 | 分页接口使用统一分页结构，默认页大小有上限 | 模式匹配：搜索分页参数定义 |
| AD-05 | P1 | 接口文档（Swagger/OpenAPI）与代码同步，CI 中校验 | 人工审查：检查 @ApiProperty / schema 注解完整 |

## 五、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | 所有异步操作必须 try/catch 或 .catch()，禁止未捕获的 Promise rejection | 静态扫描：ESLint（no-floating-promises） |
| EH-02 | P0 | 错误向上传播时必须包装上下文（自定义 Error 类 + cause 链） | 模式匹配：搜索 throw new Error 是否携带 cause |
| EH-03 | P0 | 业务错误码体系统一定义，禁止硬编码字符串错误 | 模式匹配：搜索分散的 throw new Error('...') |
| EH-04 | P1 | 未捕获异常与 unhandledRejection 由全局处理器兜底，进程不可静默崩溃 | 模式匹配：搜索 process.on('unhandledRejection') |
| EH-05 | P1 | HTTP 层统一异常过滤器（NestJS ExceptionFilter / Express error middleware），禁止各 handler 自行格式化错误 | 人工审查：检查错误响应一致性 |

## 六、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 日志必须结构化输出（JSON），禁止 console.log 用于生产日志 | 模式匹配：搜索 console.log/console.error 调用 |
| OB-02 | P0 | 日志必须携带 traceId / requestId，从请求上下文中提取 | 模式匹配：搜索日志调用是否传入上下文 |
| OB-03 | P1 | 关键业务操作埋点 metrics（请求量/延迟/错误率） | 人工审查：检查 metrics 注册 |
| OB-04 | P1 | 链路追踪 span 覆盖跨服务调用与数据库操作（OpenTelemetry） | 人工审查：检查 span 创建位置 |
| OB-05 | P1 | 日志级别分层使用（debug/info/warn/error），错误日志包含堆栈 | 模式匹配：检查日志级别使用合理性 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置（密码/密钥/Token）禁止硬编码或提交到代码仓库 | 静态扫描：搜索硬编码密码/密钥模式 |
| CF-02 | P0 | 配置通过环境变量或配置中心注入，支持多环境切换 | 模式匹配：检查配置加载方式 |
| CF-03 | P1 | 配置使用 ConfigModule（NestJS）/ dotenv + joi 验证，集中管理 | 模式匹配：搜索配置结构定义 |
| CF-04 | P1 | 配置项有默认值与校验，缺失必要配置时启动失败并输出明确提示 | 人工审查：检查配置校验逻辑 |

## 八、异步与资源管理（common/concurrency-and-resource.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CR-01 | P0 | 异步操作必须正确 await，禁止 fire-and-forget 无错误处理的异步调用 | 静态扫描：ESLint（no-floating-promises） |
| CR-02 | P0 | 请求上下文（requestId、用户信息）通过 AsyncLocalStorage / cls-hooked 传递 | 模式匹配：搜索上下文传递机制 |
| CR-03 | P0 | 优雅停机：监听 SIGTERM/SIGINT，排空在途请求，超时强制退出 | 模式匹配：搜索 process.on('SIGTERM') |
| CR-04 | P1 | 连接池（DB/Redis/HTTP Client）有大小限制与超时配置 | 人工审查：检查连接池参数 |
| CR-05 | P1 | 流式数据处理使用 Stream/Pipeline，大文件禁止全量加载到内存 | 模式匹配：搜索大文件读取方式 |

## 九、数据库访问（common/database-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | 数据库操作必须通过 Repository/DAO 层，禁止 controller/service 直接拼 SQL | 模式匹配：搜索 controller/service 中的 SQL 操作 |
| DA-02 | P0 | 查询必须参数化（TypeORM / Prisma / Knex 参数绑定），禁止字符串拼接 SQL | 模式匹配：搜索字符串拼接 SQL 模式 |
| DA-03 | P0 | 事务边界在 service 层控制，repository 层不自行开启事务 | 人工审查：检查事务管理位置 |
| DA-04 | P1 | 批量操作使用 Batch Insert/Update，禁止循环单条操作 | 模式匹配：搜索循环内的 DB 调用 |
| DA-05 | P1 | 数据库迁移使用版本化工具（TypeORM Migration / Prisma Migrate / Knex Migrate） | 人工审查：检查迁移文件管理 |
| DA-06 | P1 | 慢查询有监控告警，查询超时有上限配置 | 人工审查：检查慢查询日志配置 |

## 十、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | 所有外部输入必须校验与清洗（class-validator / zod / joi），禁止直接信任用户输入 | 模式匹配：检查输入绑定后是否有校验 |
| SC-02 | P0 | 鉴权中间件/守卫（Guard）覆盖所有受保护路由，禁止路由遗漏 | 模式匹配：检查路由分组与中间件/Guard 绑定 |
| SC-03 | P0 | 敏感数据（密码/Token）禁止明文日志输出 | 模式匹配：搜索日志中的敏感字段 |
| SC-04 | P1 | CORS 配置白名单化，禁止 origin: '*' 用于生产 | 模式匹配：搜索 CORS 配置 |
| SC-05 | P1 | 接口限流（Rate Limiting / @nestjs/throttler）已配置，防止暴力请求 | 人工审查：检查限流中间件/守卫 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | 核心业务逻辑有单元测试，覆盖率 ≥ 60% | 静态扫描：jest --coverage |
| TR-02 | P0 | 测试文件命名 *.spec.ts / *.test.ts，与被测文件同目录或 __tests__ 目录 | 模式匹配：检查测试文件位置 |
| TR-03 | P1 | 使用 describe/it 组织测试用例，每个测试用例独立且可重复运行 | 模式匹配：搜索测试组织结构 |
| TR-04 | P1 | CI 流水线包含 lint → test → build 阶段，质量门禁阻断不合格构建 | 人工审查：检查 CI 配置 |
| TR-05 | P1 | API 接口有集成测试（supertest / pactum），覆盖核心业务路径 | 人工审查：检查集成测试存在性 |

## 十二、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P1 | 提供 profiling 能力（--inspect / clinic.js），生产环境限制访问 | 模式匹配：搜索 profiling 配置 |
| PF-02 | P1 | 避免同步阻塞操作（fs.readFileSync / crypto.pbkdf2Sync），使用异步替代 | 模式匹配：搜索 *Sync 方法调用 |
| PF-03 | P1 | 数据库查询有索引覆盖，禁止全表扫描（EXPLAIN 验证） | 人工审查：检查查询与索引匹配 |
| PF-04 | P1 | JSON 序列化热点路径考虑使用流式序列化或 fast-json-stringify | 人工审查：检查高频序列化路径 |

## 十三、缓存（common/caching.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CA-01 | P0 | 缓存键设计包含业务前缀与版本号，避免键冲突 | 模式匹配：检查缓存键构造模式 |
| CA-02 | P0 | 所有缓存必须设置 TTL，禁止无过期时间的缓存 | 模式匹配：搜索 set 调用是否带 TTL 参数 |
| CA-03 | P1 | 缓存穿透/击穿/雪崩有防护措施（singleflight 模式/布隆过滤） | 人工审查：检查缓存防护策略 |
| CA-04 | P1 | 缓存与数据库一致性策略明确（Cache Aside / Write Through） | 人工审查：检查缓存更新逻辑 |

## 十四、文件存储（common/file-storage.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FS-01 | P0 | 文件上传限制大小与类型，校验 MIME Type | 模式匹配：检查上传处理中的校验逻辑 |
| FS-02 | P0 | 文件使用流式读写（Stream），禁止全量加载到内存 | 模式匹配：搜索 readFileSync / Buffer.from 用于大文件 |
| FS-03 | P1 | 文件存储路径使用唯一标识（UUID/Hash），禁止用户原始文件名 | 模式匹配：检查文件存储路径生成 |
| FS-04 | P1 | 对象存储使用预签名 URL 直传，减少服务端中转 | 人工审查：检查上传流程架构 |

## 十五、定时任务（common/scheduled-tasks.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| ST-01 | P0 | 定时任务必须幂等，重复执行不产生副作用 | 人工审查：检查任务逻辑幂等性 |
| ST-02 | P0 | 多实例部署时使用分布式锁（Redis Lock / Bull 内置），防止任务重复执行 | 模式匹配：搜索分布式锁获取逻辑 |
| ST-03 | P1 | 任务执行有超时控制与失败重试机制 | 模式匹配：搜索超时与重试配置 |
| ST-04 | P1 | 任务执行结果有日志记录与监控告警 | 人工审查：检查任务日志与监控 |

## 十六、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止在生产代码中使用 console.log / console.error 输出日志 | 静态扫描：ESLint（no-console） |
| FB-02 | P0 | 禁止提交包含密钥/密码/Token 的代码 | 静态扫描：git-secrets / gitleaks |
| FB-03 | P0 | 禁止使用 `var` 声明变量 | 静态扫描：ESLint（no-var） |
| FB-04 | P0 | 禁止忽略 Promise rejection（必须 await 或 .catch()） | 静态扫描：ESLint（no-floating-promises） |
| FB-05 | P0 | 禁止在 controller 中直接操作数据库，必须经过 service 层 | 模式匹配：搜索 controller 中的 DB 调用 |

---

## Profile 专项检查

### Monolith 专项（profiles/monolith/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MO-01 | P0 | 模块间通过接口（interface / abstract class）解耦，禁止直接引用其他模块实现 | 模式匹配：检查 import 中的跨模块引用 |
| MO-02 | P1 | 模块边界清晰，每个模块有独立的 controller/service/repository 层 | 人工审查：检查目录结构 |
| MO-03 | P1 | 共享组件（中间件/工具函数）集中于 shared/ 或 common/ 目录 | 模式匹配：检查共享代码位置 |
| MO-04 | P1 | 模块间数据传递使用 DTO，禁止直接共享数据库 Entity | 模式匹配：搜索跨模块的 entity 引用 |

### Microservice 专项（profiles/microservice/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MS-01 | P0 | 服务间通信使用 gRPC/HTTP + 统一序列化，禁止私有协议 | 模式匹配：检查服务间调用方式 |
| MS-02 | P0 | 外部调用有超时、重试与熔断配置 | 模式匹配：搜索 HTTP/gRPC Client 配置 |
| MS-03 | P1 | 服务注册与发现配置正确，健康检查端点可用 | 人工审查：检查服务注册配置 |
| MS-04 | P1 | 分布式事务使用 Saga 模式，禁止跨服务本地事务 | 人工审查：检查跨服务事务处理 |
| MS-05 | P1 | 服务间通信携带 traceId，链路追踪完整 | 模式匹配：检查调用链 header 传播 |
