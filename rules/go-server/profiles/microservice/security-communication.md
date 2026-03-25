# rules/go-server/profiles/microservice/security-communication.md

## 文档目标
1. 定义微服务间安全通信约束。通用安全规范参见 `common/security.md`。

---

## 传输加密（MUST）

1. 服务间内部通信必须使用 **mTLS（双向 TLS）** 或等效加密方案，禁止明文传输。
2. 使用 Service Mesh（如 Istio）时，mTLS 由 Sidecar 自动处理，无需应用层实现。
3. 非 Service Mesh 环境下，gRPC 必须配置 TLS 证书；HTTP 内部调用必须使用 HTTPS。

检查方式：安全审查 + 网络扫描
阻断级别：阻断合并

---

## 服务间认证（MUST）

1. 推荐方案：
   - **mTLS 证书认证**：双方持有 CA 签发的证书。
   - **JWT Token 认证**：调用方携带内部签发的服务间 Token。
2. 服务间 Token 必须与用户 Token 分离，使用独立签发机制和校验逻辑。
3. 敏感数据在服务间传输时必须加密或脱敏，禁止明文透传。

检查方式：安全审查
阻断级别：阻断合并
