# rules/frontend/common/security.md

## 文档目标
1. 定义三端前端项目的安全基线约束。
2. 服务端安全规则参见 `go-server/common/security.md`。
3. 前后端鉴权联动参见 `rules/frontend-backend-collaboration.md`。

## XSS 防御（MUST）
1. 禁止使用 `v-html` / `dangerouslySetInnerHTML` 直接渲染用户输入。
2. 必须使用 `v-html` 的场景（如富文本展示），内容必须先经过 `DOMPurify` 等白名单库净化。
3. 禁止在代码中使用 `eval()`、`new Function()`、`document.write()`。
4. 禁止使用内联 `<script>` 标签和 `javascript:` 伪协议。
5. 模板中禁止拼接 HTML 字符串后插入 DOM（如 `innerHTML = '<div>' + userInput + '</div>'`）。
6. 后台管理项目必须配置 `Content-Security-Policy`（CSP）响应头。
检查方式：ESLint 规则（vue/no-v-html 告警）+ CSP 配置审查 + 人工审查
阻断级别：阻断合并

## 敏感数据处理（MUST）
1. Token/Session 存储优先级：
   - **首选**：`httpOnly Cookie`（服务端 Set-Cookie，前端不可读取，天然防 XSS）。
   - **次选**：内存变量（页面刷新后需重新获取）。
   - **禁止**：`localStorage` / `sessionStorage` 存储 Token。
2. 禁止在 URL query 参数中传递 Token、密码、身份证等敏感信息。
3. 用户敏感信息显示时必须脱敏：
   - 手机号：`138****1234`
   - 身份证：`310***********1234`
   - 银行卡：`**** **** **** 5678`
4. 敏感表单字段设置 `autocomplete="off"`（或具体的 autocomplete 值）。
5. 密码输入框必须使用 `type="password"`，禁止明文展示开关外的其他方式。
检查方式：人工审查
阻断级别：阻断合并

## CORS 配置（MUST）
1. 生产环境禁止使用 `Access-Control-Allow-Origin: *`。
2. 允许的 Origin 必须使用精确域名白名单，禁止正则通配。
3. `Access-Control-Allow-Credentials: true` 时，Origin 不得为 `*`。
4. 预检请求（OPTIONS）缓存时间建议 `Access-Control-Max-Age: 86400`（1 天）。
5. CORS 配置变更必须经过安全审查。
检查方式：配置审查 + 人工审查
阻断级别：阻断合并

## 依赖安全（MUST）
1. CI 中必须执行 `npm audit` / `pnpm audit` 依赖漏洞扫描。
2. 漏洞处理时限：

| 严重程度 | 处理时限 | CI 行为 |
|----------|----------|---------|
| Critical | **3 天**内修复 | 阻断合并 |
| High | **7 天**内修复 | 阻断合并 |
| Moderate | **30 天**内修复或记录豁免 | 告警记录 |
| Low | 下次依赖升级时一并处理 | 不阻断 |

3. 禁止使用已知 EOL（End of Life）的依赖大版本。
4. `package-lock.json` / `pnpm-lock.yaml` 必须提交到仓库，禁止 `.gitignore` 排除。
检查方式：CI 依赖扫描（npm audit / pnpm audit）
阻断级别：Critical/High 阻断合并

## 密钥与环境变量（MUST）
1. 代码中禁止硬编码任何密钥、API Key、Token、数据库连接串。
2. `.env` / `.env.local` / `.env.*.local` 必须加入 `.gitignore`。
3. 生产环境密钥必须通过 CI Secrets 或密钥管理服务（如 Vault）注入。
4. 仓库中维护 `.env.example` 列出所有变量名（值留空或填示例值）。
5. CI/CD 中禁止在日志中打印环境变量值。
检查方式：git-secrets / secretlint 静态扫描 + .gitignore 审查
阻断级别：阻断合并

## 前端日志安全（MUST）
1. 生产环境构建产物中禁止残留 `console.log`（已在 `tooling.md` 构建清理中要求）。
2. 错误上报内容禁止包含用户敏感信息（密码、Token、身份证原文）。
3. 上报前必须对敏感字段做脱敏处理。
检查方式：构建产物扫描 + 人工审查
阻断级别：阻断合并

## 第三方脚本（MUST）
1. 引入第三方 JS/SDK（统计、客服、支付等）必须经过安全评估。
2. 第三方脚本必须通过 CDN 加载并配置 `integrity`（SRI）校验。
3. 禁止从不可信来源加载脚本。
4. 第三方脚本加载失败不得影响核心业务功能。
检查方式：人工审查
阻断级别：阻断合并

## 建议规则（SHOULD）
1. 接入 GitHub Dependabot 或 Snyk 自动化依赖告警。
2. 定期（每月）执行一次全量依赖漏洞扫描。
3. 敏感操作（删除、支付、权限变更）增加二次确认。
4. 前端表单提交增加 CSRF Token 校验（与服务端配合）。
5. 文件上传限制类型和大小，服务端二次校验。
检查方式：人工审查
阻断级别：告警记录

## 配套模板
1. CSP 配置 + DOMPurify 封装 + 依赖审计脚本 + secretlint 配置 → `rules/templates/frontend/security-toolkit.md`
