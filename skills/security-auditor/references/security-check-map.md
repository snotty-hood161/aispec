# 安全检查项 → 检查规则映射表

用此表将审计范围和技术栈映射到具体的安全检查项和规则文件。

## 使用方式
1. 确定审计范围（全项目 / 模块 / PR 变更）。
2. 识别涉及的技术栈。
3. 按下表确定需要执行的检查项。
4. 始终检查：A（密钥泄露）+ B（依赖安全）。

---

## 检查项路由表

| 编号 | 检查场景 | 触发条件 | 加载规则 | 优先级 |
|------|---------|---------|---------|--------|
| A | 密钥与敏感信息泄露 | 始终执行 | `rules/security/security-baseline.md` §密钥管理 | P0 |
| B | 依赖安全扫描 | 始终执行 | `rules/security/security-baseline.md` §依赖安全 | P0 |
| C | 认证机制检查 | 涉及登录、注册、Token、Session | `rules/security/security-baseline.md` §认证 | P0 |
| D | 授权与访问控制 | 涉及权限、角色、资源隔离 | `rules/security/security-baseline.md` §授权 | P0 |
| E | 输入校验（注入防护） | 涉及用户输入、表单、搜索、文件上传 | `rules/security/security-baseline.md` §输入校验 | P0 |
| F | API 安全 | 涉及 API 端点、CORS、限流 | `rules/security/security-baseline.md` §API 安全 | P0 |
| G | 数据传输安全 | 涉及 HTTP/HTTPS、TLS 配置 | `rules/security/security-baseline.md` §传输安全 | P0 |
| H | 数据存储安全 | 涉及数据库存储、加密、脱敏 | `rules/security/security-baseline.md` §存储安全 + `rules/database/data-migration.md` §数据脱敏 | P0 |
| I | 安全审计日志 | 涉及操作日志、审计追踪 | `rules/security/security-baseline.md` §安全审计日志 + `rules/observability/observability.md` §日志管理 | P1 |
| J | 安全响应头 | Web 应用前端 | `rules/security/security-baseline.md` §API 安全 | P1 |
| K | CSRF 防护 | Web 表单提交、状态变更 API | 对应域的 `security.md` | P1 |
| L | XSS 防护 | HTML 渲染、富文本编辑器 | 对应域的 `security.md` | P0 |
| M | 文件上传安全 | 文件上传功能 | 对应域的 `security.md` | P0 |
| N | 移动端安全 | iOS/Android/Flutter 客户端 | 对应移动域的 `security.md` | P1 |
| O | 桌面端安全 | Tauri/.NET 桌面 | 对应桌面域的 `security.md` | P1 |

## 按技术栈的域安全规则文件

| 技术栈 | 域安全规则文件 | 重点关注 |
|--------|-------------|---------|
| Go 服务端 | `rules/go-server/common/security.md` | SQL 注入、认证中间件、密钥管理 |
| .NET 服务端 | `rules/dotnet-server/common/security.md` | CORS、认证授权中间件、数据保护 |
| Python 服务端 | `rules/python-server/common/security.md` | 注入防护、CORS、密钥管理、依赖审计 |
| Java 服务端 | `rules/java-server/common/security.md` | Spring Security、CSRF、依赖安全、SQL 注入 |
| Node.js 服务端 | `rules/node-server/common/security.md` | HTTP 安全头、CORS、输入校验、依赖审计 |
| 前端 | `rules/frontend/common/security.md` | XSS、CSP、Token 存储、依赖审计 |
| .NET 桌面 | `rules/dotnet-desktop/common/security.md` | 数据保护 API、代码签名 |
| Tauri 桌面 | `rules/tauri-desktop/common/security.md` | IPC 安全、CSP、文件系统访问 |
| Electron 桌面 | `rules/electron-desktop/common/security.md` | IPC 安全、远程内容加载、CSP、nodeIntegration |
| Android | `rules/android/common/security.md` | KeyStore、网络安全配置、ProGuard |
| iOS | `rules/ios/common/security.md` | Keychain、ATS、代码签名 |
| Flutter | `rules/flutter/common/security.md` | 安全存储、证书锁定、代码混淆 |
| React Native | `rules/react-native/common/security.md` | 安全存储、证书锁定、代码保护、Hermes |
| 数据库 | `rules/database/database.md` + `rules/database/data-migration.md` | 参数化查询、权限最小化、脱敏 |

## 审计报告 P0/P1 判定标准

| 级别 | 标准 | 示例 |
|------|------|------|
| P0 阻断 | 可被直接利用造成数据泄露或服务中断 | SQL 注入、硬编码密钥、未授权访问 |
| P1 改进 | 存在风险但利用条件苛刻或影响有限 | 缺少速率限制、日志未脱敏、HTTP 安全头缺失 |
| P2 建议 | 最佳实践建议，不构成直接风险 | 密钥轮换周期偏长、缺少安全演练计划 |
