# rules/node-server/common/file-storage.md

## 文件上传规范

### MUST
1. 文件上传必须使用 `multer`（Express/NestJS）或 `@fastify/multipart`（Fastify），禁止手动解析 multipart 请求体。
2. 必须配置文件大小限制（`limits.fileSize`），根据业务需求设置（如图片 5MB、文档 20MB、视频 500MB）。
3. 必须校验文件 MIME 类型，推荐使用 `file-type` 库基于 Magic Bytes 检测真实类型，禁止仅依赖客户端提供的 `Content-Type` 或文件扩展名。
4. 必须限制允许的文件扩展名白名单，禁止上传可执行文件（`.exe`、`.sh`、`.bat`、`.js`）。
5. 上传文件必须重命名为随机文件名（UUID + 原始扩展名），禁止使用用户提供的原始文件名存储。
6. 临时文件上传目录必须与业务数据目录分离，上传完成后临时文件必须清理。
7. NestJS 项目推荐使用 `@nestjs/platform-express` 的 `FileInterceptor` / `FilesInterceptor` 处理文件上传。

### SHOULD
1. 推荐大文件使用分片上传（Multipart Upload），支持断点续传。
2. 推荐在文件上传前生成预签名 URL（Presigned URL），客户端直传对象存储，减轻服务端压力。
3. 推荐对上传的图片进行压缩和尺寸限制。

检查方式：安全扫描 + 接口测试
阻断级别：阻断合并

---

## 对象存储（MinIO/OSS）

### MUST
1. 生产环境文件必须存储到对象存储（MinIO、阿里云 OSS、AWS S3），禁止存储在应用服务器本地文件系统。
2. 对象存储客户端必须通过 DI 注入（参见 `common/component-initialization.md`），禁止在业务代码中直接构造客户端。
3. Bucket 必须按业务域划分（如 `avatars`、`documents`、`exports`），禁止所有文件放入同一 Bucket。
4. Bucket 访问策略必须配置为私有（private），公开访问的文件通过 CDN 或预签名 URL 提供。
5. 必须配置上传超时和下载超时，禁止无限等待。
6. 文件路径组织推荐 `{bucket}/{业务域}/{年月}/{UUID}.{ext}`，如 `avatars/2026/03/abc123.jpg`。
7. 上传后必须验证文件完整性（Content-MD5 或 ETag），确保传输无损。

### SHOULD
1. 推荐使用 `@aws-sdk/client-s3`（S3 兼容 API）统一对接 MinIO、OSS、S3。
2. 推荐为静态文件配置 CDN 加速。
3. 推荐设置 Bucket 生命周期策略，自动清理过期的临时文件。

检查方式：配置审查 + 集成测试
阻断级别：阻断合并

---

## 流式处理（MUST）

1. 大文件下载必须使用流式响应（`stream.pipe(res)`），禁止将整个文件加载到内存后返回。
2. 文件上传到对象存储必须使用流式传输（`upload` + `ReadableStream`），禁止先存本地再上传。
3. 流式处理必须正确处理错误事件（`stream.on('error')`），错误时必须清理已创建的临时资源。
4. 流式处理必须处理背压（backpressure），禁止忽略 `highWaterMark` 导致内存溢出。
5. 下载接口必须设置正确的响应头：
   - `Content-Type`：文件 MIME 类型
   - `Content-Disposition`：`attachment; filename="..."`（下载）或 `inline`（预览）
   - `Content-Length`：文件大小（如已知）

### SHOULD
1. 推荐使用 `pipeline`（`node:stream/promises`）替代手动 `pipe`，自动处理错误和清理。
2. 推荐支持 Range 请求（`Accept-Ranges: bytes`），实现断点续传下载。

检查方式：集成测试 + 内存监控
阻断级别：阻断合并

---

## 临时文件管理（MUST）

1. 临时文件必须存储在专用临时目录（如 `/tmp/app-uploads/`），禁止存放在项目源码目录。
2. 临时文件必须在处理完成后立即删除，禁止依赖操作系统自动清理。
3. 必须设置定时清理任务，删除超过 24 小时未被处理的临时文件。
4. 临时文件路径禁止使用用户输入构造，防止路径遍历攻击。

### SHOULD
1. 推荐使用 `tmp` 库创建临时文件和目录，自动管理清理。
2. 推荐在优雅停机时清理所有未完成的临时文件。

检查方式：代码审查 + 安全扫描
阻断级别：阻断合并

---

## 文件访问控制（MUST）

1. 文件下载接口必须进行权限校验，禁止通过可预测的 URL 直接访问私有文件。
2. 公开文件推荐使用有时效的预签名 URL（Presigned URL），有效期不超过 1 小时。
3. 文件删除操作必须校验操作者权限，记录审计日志。
4. 禁止通过 API 暴露对象存储的内部路径或 Bucket 名称。
