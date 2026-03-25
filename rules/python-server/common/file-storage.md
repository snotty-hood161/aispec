# rules/python-server/common/file-storage.md

## 文档目标
1. 定义文件上传下载、对象存储（MinIO/OSS）使用规范。
2. 对象存储组件初始化参见 `common/component-initialization.md`。

---

## 对象存储选型（MUST）

1. 文件存储统一使用对象存储服务（MinIO / 阿里云 OSS / 腾讯云 COS / AWS S3），禁止将文件存储在应用服务器本地磁盘。
2. 对象存储 SDK 必须封装在 `app/platform/` 或 `app/infrastructure/` 适配层中，业务代码通过接口调用，禁止直接引用 SDK 内部类型。
3. 推荐使用 `boto3`（S3 兼容）或 `minio` 官方 Python SDK。
4. Bucket 命名规范：`{环境}-{服务名}-{用途}`（如 `prod-order-svc-attachments`）。

检查方式：架构评审
阻断级别：阻断合并

---

## 文件上传（MUST）

1. 上传文件必须校验：文件大小上限、文件类型白名单（按 MIME 和文件头校验，不仅依赖扩展名）。
2. 上传文件名必须重命名为唯一标识（如 UUID + 原始扩展名），禁止使用用户原始文件名存储（防止路径注入和覆盖）。
3. 大文件（> 10MB）必须使用分片上传（Multipart Upload），禁止一次性读入内存。
4. 上传接口必须设置超时，超时后取消上传并清理已上传分片。
5. 上传后必须记录文件元信息（文件 ID、原始文件名、大小、类型、上传者、时间戳）到数据库。
6. FastAPI 项目中 MUST 使用 `UploadFile` 接收文件，配合 `python-multipart` 处理表单上传。

### 文件上传校验示例
```python
import uuid
from fastapi import UploadFile, HTTPException

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "application/pdf"}
MAX_SIZE = 10 * 1024 * 1024  # 10MB

async def validate_upload(file: UploadFile) -> str:
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=400, detail="unsupported file type")
    content = await file.read()
    if len(content) > MAX_SIZE:
        raise HTTPException(status_code=400, detail="file too large")
    await file.seek(0)
    ext = file.filename.rsplit(".", 1)[-1] if file.filename else "bin"
    return f"{uuid.uuid4()}.{ext}"
```

检查方式：代码审查
阻断级别：阻断合并

---

## 文件访问分级（MUST）

### 分级定义

| 级别 | 说明 | 示例 | Bucket 权限 | 访问方式 |
|------|------|------|------------|---------|
| **公开** | 无隐私性、面向所有用户可见的资源 | 商品图片、品牌 Logo | 公开读（Public Read） | CDN 直接访问 |
| **受限** | 仅登录用户或特定角色可见 | 用户头像、订单附件 | 私有（Private） | 签名 URL（Pre-signed URL） |
| **敏感** | 涉及隐私或合规要求 | 身份证照片、银行卡照片 | 私有（Private） | 签名 URL + 访问审计日志 |

1. 上传文件时必须标注访问级别，级别决定存储 Bucket 和访问策略。
2. 不同访问级别的文件必须存储在不同 Bucket 中，禁止混存。
3. Bucket 命名体现级别：如 `prod-order-svc-public`、`prod-order-svc-private`。

### 公开文件（MUST）
1. 公开文件的 Bucket 设置为公开读（Public Read），禁止公开写。
2. 公开文件必须通过 CDN 分发，配置强缓存（文件名含 hash 或版本号）。
3. 公开文件上传后返回 CDN 完整 URL，前端直接使用，无需再经服务端中转。

### 受限文件（MUST）
1. 受限文件的 Bucket 设置为私有（Private）。
2. 访问时通过服务端生成签名 URL，签名有效期可配置（建议 ≤ 30 分钟）。
3. 签名 URL 生成接口必须校验用户身份和访问权限。

### 敏感文件（MUST）
1. 敏感文件的 Bucket 设置为私有（Private），并启用服务端加密（SSE）。
2. 访问时通过服务端生成签名 URL，签名有效期更短（建议 ≤ 5 分钟）。
3. 每次访问必须记录审计日志（访问者、文件标识、时间、来源 IP）。
4. 敏感文件不经过 CDN，直接从对象存储签名访问。

### 通用下载约束（MUST）
1. 下载接口必须设置正确的 `Content-Type` 和 `Content-Disposition`，防止浏览器误执行。
2. 大文件下载必须支持断点续传（`Range` 请求）或使用 `StreamingResponse`，禁止一次性读取全文件到内存。

检查方式：Bucket 权限配置审查 + 代码审查
阻断级别：阻断合并

---

## 临时文件清理（MUST）

1. 应用运行中产生的临时文件（导出、转换、缩略图）必须在使用完成后立即清理。
2. Python 临时文件 MUST 使用 `tempfile` 模块创建，确保异常时也能自动清理。
3. 分片上传未完成的碎片必须配置自动清理策略（如 24 小时未完成则删除）。
4. 对象存储 Bucket 必须配置生命周期规则，自动清理过期临时文件。
5. 禁止在对象存储中无限累积无引用文件，定期（每月）扫描并清理孤立文件。

检查方式：对象存储配置审查
阻断级别：阻断合并

---

## 安全约束（MUST）

1. 对象存储凭据（AccessKey / SecretKey）禁止硬编码，必须通过配置文件或密钥管理服务注入。
2. Bucket 权限必须严格按文件访问分级设置，禁止将受限/敏感 Bucket 设为公开读，禁止将任何 Bucket 设为公开写。
3. 上传文件必须经过病毒扫描（如有条件），或至少限制可执行文件类型上传。
4. 受限和敏感文件上传后推荐经过处理服务（压缩/裁剪/去 EXIF），使用 `Pillow` 去除 EXIF 信息避免泄露用户位置等隐私。
5. 公开 Bucket 建议配置防盗链（Referer 校验），防止资源被第三方站点盗用。

检查方式：安全审查
阻断级别：阻断合并
