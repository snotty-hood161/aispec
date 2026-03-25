# rules/node-server/common/forbidden.md

## 禁止事项

### 类型与语言

1. 禁止使用 `any` 类型，必须使用 `unknown` + 类型收窄或泛型替代；确需使用须附 `@ts-expect-error` 并注释原因。
2. 禁止使用 `@ts-ignore`，必须使用 `@ts-expect-error` 并说明原因。
3. 禁止关闭 TypeScript `strict` 模式或其任何子选项（`strictNullChecks`、`noImplicitAny` 等）。
4. 禁止在生产代码中使用 `as any` 类型断言绕过类型检查。

### 调试与日志

5. 禁止将 `console.log`、`console.debug`、`console.info`、`console.warn` 提交到主分支；所有日志必须通过结构化日志组件。
6. 禁止将 `debugger` 语句提交到主分支。
7. 禁止在日志中打印密码、JWT 令牌、信用卡号、身份证号等敏感信息。

### 异步与并发

8. 禁止出现回调嵌套超过两层（callback hell），必须使用 `async/await`。
9. 禁止出现 unhandled Promise rejection（未捕获的 Promise 错误）。
10. 禁止使用 `fs.readFileSync`、`fs.writeFileSync` 等同步 I/O API 处理请求（启动阶段加载配置除外）。
11. 禁止在 Event Loop 中执行 CPU 密集型同步操作（大 JSON 解析、加密计算等）。
12. 禁止使用 `setTimeout`/`setInterval` 实现定时任务或延迟队列（进程重启会丢失）。

### 架构与分层

13. 禁止在 controller 中直接操作数据库、缓存、对象存储或消息队列。
14. 禁止在 controller 中直接引用 repository，必须经由 service 调用。
15. 禁止在 service 中依赖 HTTP 框架类型（如 `Request`、`Response` 对象）。
16. 禁止在 service 中直接编写 ORM 查询代码，数据访问必须通过 repository。
17. 禁止在 controller/service/repository 之间跨层写业务捷径代码。
18. 禁止将业务实体放入通用共享目录后被跨服务直接复用。

### 安全

19. 禁止硬编码数据库、Redis、MinIO 等外部依赖地址和凭据，必须从配置/环境变量加载。
20. 禁止在 CORS 中间件中硬编码域名白名单。
21. 禁止在代码中硬编码 JWT 密钥或 API Key。
22. 禁止直接拼接用户输入到 SQL 语句，必须使用参数化查询。
23. 禁止在 API 响应中暴露数据库错误、堆栈信息、SQL 语句等内部信息。
24. 禁止对失败请求统一返回 `200` 并仅依赖响应体业务 `code` 区分错误。
25. 禁止生产环境启用调试端口（`--inspect`）或 REPL 功能。
26. 禁止使用 MD5/SHA 系列哈希存储密码，必须使用 `bcrypt` 或 `argon2`。

### 依赖与初始化

27. 禁止在模块顶层作用域（文件级）建立数据库、Redis 等外部连接。
28. 禁止通过全局变量暴露可变组件实例（如全局 `prisma`、全局 `redis`）。
29. 禁止在 controller/service 中直接 `new PrismaClient()`、`new Redis()`、`new S3Client()` 等。
30. 禁止在 NestJS Guard/Interceptor 中直接构造基础组件，必须通过 DI 注入。
31. 禁止使用 `require()` 导入模块（动态加载和 CommonJS 互操作除外）。

### 错误处理

32. 禁止在多个 controller 中分散实现错误到响应的映射逻辑，必须走统一错误处理（ExceptionFilter/错误中间件）。
33. 禁止吞掉异常（空 `catch` 块），每个 `catch` 必须有日志记录或重新抛出。
34. 禁止将系统错误（数据库驱动错误、ORM 原始错误、堆栈信息）原样返回给调用方。

### 数据与缓存

35. 禁止新增无上限缓存、无上限队列或无超时外部调用。
36. 禁止使用 `SELECT *`（或无 `select`/`include` 的 ORM 查询）返回无限制字段。
37. 禁止循环内逐条查询数据库（N+1），必须使用批量查询或 eager loading。
38. 禁止使用 `float`/`double` 存储金额，必须使用 `Decimal` 类型。
39. 禁止手动修改生产数据库结构，必须通过迁移文件管理。

### 代码质量

40. 禁止文件命名使用 `util.ts`、`common.ts`、`misc.ts`、`helper.ts` 等模糊命名承载多责任逻辑。
41. 禁止未评审的破坏性 API 变更和数据库结构变更。
42. 禁止在单个类上混用多层装饰器（controller DTO + Entity 装饰器混在同一个类上）。
