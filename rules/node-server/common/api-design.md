# rules/node-server/common/api-design.md

## RESTful 设计规范

### MUST
1. URL 使用 `kebab-case` 命名，名词复数形式表示资源集合（如 `/api/v1/user-orders`），禁止使用动词（如 `/api/getUsers`）。
2. HTTP 方法语义必须正确：`GET` 读取、`POST` 创建、`PUT` 全量更新、`PATCH` 部分更新、`DELETE` 删除。
3. 集合查询统一支持分页，必须返回 `total`、`page`、`pageSize` 字段，禁止返回无限制的全量数据。
4. API 路径必须包含版本号前缀（如 `/api/v1/`），版本变更须遵循语义化规则。
5. 嵌套资源路径最多两层（如 `/users/:userId/orders`），超过两层必须扁平化设计。
6. 批量操作使用 `POST /resources/batch` + `action` 字段区分操作类型，禁止在 URL 中拼接多个 ID。

### SHOULD
1. 推荐使用 `cursor-based` 分页替代 `offset-based` 分页，适合大数据量和实时数据场景。
2. 推荐集合查询支持字段过滤（`fields` 参数）和排序（`sort` 参数）。
3. 推荐幂等接口（POST 创建、支付等）支持 `Idempotency-Key` 请求头。

检查方式：OpenAPI 规范审查 + 接口测试
阻断级别：阻断合并

---

## DTO 校验（MUST）

1. 所有请求参数必须通过 DTO 定义和校验，禁止在 controller 中手写参数校验。
2. NestJS 项目必须使用 `class-validator` + `class-transformer` 或 `zod` 进行 DTO 校验。
3. Express/Fastify 项目推荐使用 `zod`、`joi` 或 `ajv` 进行请求校验。
4. DTO 校验必须覆盖：类型、必填、格式（邮箱/手机号/URL）、长度、范围、枚举白名单。
5. 全局启用 `ValidationPipe`（NestJS），配置 `whitelist: true`（剥离未声明字段）和 `forbidNonWhitelisted: true`（拒绝未声明字段）。
6. 文件上传 DTO 必须校验文件大小、MIME 类型、文件扩展名，禁止信任客户端提供的 Content-Type。
7. 嵌套对象和数组元素必须使用 `@ValidateNested()` + `@Type()` 递归校验。

### SHOULD
1. 推荐创建自定义校验装饰器封装常用业务校验（如手机号、身份证号）。
2. 推荐 DTO 错误消息使用中文或 i18n key，便于前端直接展示。

检查方式：单元测试 + 集成测试
阻断级别：阻断合并

---

## 统一响应结构（MUST）

1. 所有 API 必须使用统一的响应结构：
   ```typescript
   interface ApiResponse<T> {
     code: number;        // 业务状态码
     message: string;     // 人类可读提示
     data: T | null;      // 业务数据
     timestamp: number;   // 响应时间戳
     requestId: string;   // 请求追踪 ID
   }
   ```
2. 成功响应 HTTP 状态码使用 `200`（查询）、`201`（创建）、`204`（删除/无返回体），业务 `code` 为 `0`。
3. 失败响应 HTTP 状态码与错误类型对应：`400`（参数错误）、`401`（未认证）、`403`（无权限）、`404`（资源不存在）、`409`（冲突）、`500`（服务器内部错误）。
4. 禁止对失败请求统一返回 `200` 并仅依赖响应体业务 `code` 区分错误。
5. 列表查询响应必须包含分页元数据（`total`、`page`、`pageSize`、`totalPages`）。
6. 响应中禁止暴露服务器内部错误堆栈、SQL 语句、数据库表名等敏感信息。

### SHOULD
1. 推荐通过 NestJS Interceptor 统一包装成功响应，避免在每个 controller 中手动包装。
2. 推荐分页响应使用独立的 `PaginatedResponse<T>` 类型。

---

## OpenAPI 文档（MUST）

1. 必须生成 OpenAPI 3.0+ 规范文档，NestJS 项目使用 `@nestjs/swagger`。
2. 所有 API 端点必须有 `@ApiOperation`（描述）、`@ApiResponse`（响应示例）装饰器。
3. DTO 属性必须使用 `@ApiProperty()` 标注类型、描述和示例值。
4. 文档必须区分认证接口和公开接口（使用 `@ApiBearerAuth()` 等标记）。
5. API 文档在非生产环境自动暴露，生产环境默认关闭或需鉴权访问。

### SHOULD
1. 推荐在 CI 中生成 OpenAPI JSON 并做向后兼容性检查（使用 `openapi-diff` 等工具）。
2. 推荐为常用错误码提供 `@ApiResponse` 示例。
3. 推荐导出 OpenAPI JSON 供前端 SDK 自动生成使用。

检查方式：`@nestjs/swagger` 生成 + CI 检查
阻断级别：阻断合并
