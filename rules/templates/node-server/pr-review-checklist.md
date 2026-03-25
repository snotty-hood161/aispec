# Node.js 服务端 PR 评审清单模板

## 文档目标
1. 用于 Node.js 服务端 PR 评审，评审人逐项核对，确保代码质量达标。
2. 默认适用 `common` 全量规则，评审前先标注架构类型。

## 使用方式
1. **谁用**：PR 评审人（Reviewer）。
2. **何时用**：每次 Node.js 服务端 PR 提交评审时。
3. **怎么用**：复制清单到 PR 评审评论中，逐项勾选，未通过项写明阻塞原因。

## 前提
1. 评审前先标注架构类型：`monolith` 或 `microservice`（或混合）。
2. 每项必须给出结果：`[x]` 通过 / `[ ]` 不通过（需写阻塞原因）。
3. 如有例外，必须在 PR 说明中记录：原因、边界、回收时间。

## 优先级说明
1. `P0` 为阻塞项，必须全部通过才可合并。
2. `P1` 为改进项，允许带条件合并，但必须登记技术债与回收计划。
3. 评审结论遵循：任一 `P0` 未通过则 `Request Changes`。

---

## PR 基本信息
- [ ] [P0] 已标注适用 profile：`monolith` / `microservice`
- [ ] [P0] 已说明变更目的、影响范围、回滚方案
- [ ] [P0] 已附关键测试结果与验证方式

## 架构与分层
- [ ] [P0] 依赖方向符合 `controller/resolver -> service -> repository`，无反向依赖
- [ ] [P0] `main.ts / app.ts` 仅做组装与启动，不包含业务逻辑
- [ ] [P0] Controller/Resolver 未直接访问数据库/缓存/对象存储客户端
- [ ] [P0] Service 未直接写 SQL/ORM 查询细节
- [ ] [P0] Repository 未承载业务状态机或流程编排

## 组件初始化与生命周期
- [ ] [P0] 组件通过 DI 注入（NestJS DI / 手动工厂），未在 controller/service 直接构造客户端
- [ ] [P0] 无全局可变单例，无在模块外直接 new 基础设施客户端
- [ ] [P0] 初始化顺序清晰，关闭顺序反向且可验证（onModuleDestroy / process.on('SIGTERM')）
- [ ] [P1] 日志组件优先初始化，初始化失败策略明确（fail-fast/降级）
- [ ] [P0] 提供并验证 `/healthz` 与 `/readyz`（关键依赖故障时不可就绪）

## 配置与环境
- [ ] [P0] 使用 `.env` + `.env.<environment>` 或 ConfigModule 分层配置
- [ ] [P0] 配置使用 joi / class-validator 校验，非法值启动失败
- [ ] [P1] 启动日志明确输出生效环境（NODE_ENV）
- [ ] [P0] 数据库/Redis/MinIO 等参数全部配置化，无硬编码
- [ ] [P0] 数据库类型明确为 `mysql` 或 `postgresql`

## API 与契约
- [ ] [P0] API 版本与契约（OpenAPI/GraphQL Schema）已同步更新
- [ ] [P0] 响应结构统一：`code/message/data/requestId/timestamp`
- [ ] [P0] HTTP 状态码语义正确（非成功不返回统一 `200`）
- [ ] [P0] 错误响应文案可控，不泄露内部实现细节（无堆栈、SQL、内部路径）
- [ ] [P1] `requestId` 注入、透传与日志关联已验证

## 鉴权与安全
- [ ] [P0] Admin 与 Client 认证方案独立，无同 Guard/中间件分支混用
- [ ] [P0] JWT 配置（算法、密钥来源、过期策略）显式且无硬编码
- [ ] [P0] 高风险操作具备权限校验与审计日志
- [ ] [P0] 敏感信息未出现在日志/响应中
- [ ] [P0] 参数校验使用 class-validator / zod / joi，校验失败返回 400

## 数据访问与模型
- [ ] [P0] 常规 CRUD 使用 Entity/Model + Repository 模式
- [ ] [P0] 统计/报表查询使用投影 DTO
- [ ] [P0] 投影 DTO 未用于常规写入路径
- [ ] [P0] 查询使用 select/投影，无等同 `SELECT *` 的全实体查询（只读场景）
- [ ] [P0] 全部参数化查询，无字符串拼接 SQL
- [ ] [P0] 事务边界在 Service 层，Repository 仅执行数据操作

## 异步编程与资源管理
- [ ] [P0] 全链路 async/await，无未处理的 Promise rejection
- [ ] [P0] 请求上下文（requestId、用户信息）通过 AsyncLocalStorage / cls-hooked 传递
- [ ] [P0] 禁止使用 *Sync 同步阻塞方法（fs.readFileSync 等）于请求链路
- [ ] [P0] 外部 HTTP 调用使用统一 HttpService / axios 实例，有超时配置
- [ ] [P0] 流式资源（Stream / DB Connection）正确关闭与释放

## 错误处理与可观测性
- [ ] [P0] 系统异常被记录，未原样返回给调用方
- [ ] [P0] 异常映射集中在统一中间件（NestJS ExceptionFilter / Express error handler），非散落式实现
- [ ] [P0] 重新抛出异常保留原始堆栈（Error cause 链）
- [ ] [P1] 结构化日志（winston / pino）、核心指标（QPS/错误率/P95/P99）与追踪可用
- [ ] [P1] 下游依赖成功率与耗时指标已覆盖

## 测试与发布门禁
- [ ] [P0] 通过 `eslint . && tsc --noEmit && jest --coverage`
- [ ] [P1] 新增代码覆盖率 >= 60%
- [ ] [P0] 缺陷修复包含回归测试
- [ ] [P1] 验证优雅停机：停接新流量、排空在途请求、超时强退
- [ ] [P0] 涉及 API/配置/数据库变更时文档已同步更新
- [ ] [P0] 无 `console.log` / `console.error` 等调试代码残留

---

## 结论
- [ ] `Approve`（全部 `P0` 通过）
- [ ] `Request Changes`（存在任一 `P0` 未通过）
- [ ] `Conditional Approve`（`P0` 通过，存在 `P1` 未通过且已登记技术债）
