# rules/templates/index.md — 规范模板总索引

## 文档目标
1. 索引所有可复用的规范模板，说明每个模板的使用者、使用时机和使用方式。
2. 模板与规则的区别：**规则**定义"必须做什么"，**模板**提供"具体怎么做"的可复制样板。
3. 模板按需加载，根据当前任务选取对应模板即可。

---

## 模板与规则的关系

```
rules/（约束规则）          templates/（执行模板）
定义 MUST/SHOULD/MAY   →   提供落地样板
"禁止无边界 any"        →   ESLint 配置模板
"权限点统一定义"        →   权限命名模板
"PR 必须通过评审"       →   PR 评审清单模板
```

---

## 通用模板

### 1. `exception-request-template.md` — 规范例外申请模板
- **谁用**：任何开发者
- **何时用**：需要临时豁免某条 MUST 规则时（技术限制、第三方依赖约束、紧急修复等）
- **怎么用**：复制模板填写基本信息、例外原因、影响范围、风险评估、回收计划，提交给技术负责人审批
- **关联规则**：`frontend/common/governance.md` 第五章例外申请流程

---

## Go 服务端模板（`go-server/`）

### 2. `go-server/pr-review-checklist.md` — Go 服务端 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Go 服务端 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`go-server/common/testing-and-release.md`、`go-server/common/code-style.md`

---

## .NET 服务端模板（`dotnet-server/`）

### 3. `dotnet-server/pr-review-checklist.md` — .NET 服务端 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 C#/.NET 服务端 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`dotnet-server/common/testing-and-release.md`、`dotnet-server/common/code-style.md`

---

## .NET 桌面模板（`dotnet-desktop/`）

### 4. `dotnet-desktop/pr-review-checklist.md` — .NET 桌面应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 C#/.NET 桌面应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`dotnet-desktop/common/testing-and-release.md`、`dotnet-desktop/common/architecture.md`

---

## Tauri 桌面模板（`tauri-desktop/`）

### 5. `tauri-desktop/pr-review-checklist.md` — Tauri 桌面应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Tauri 桌面应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`tauri-desktop/common/testing-and-release.md`、`tauri-desktop/common/security.md`

---

## Android 移动端模板（`android/`）

### 6. `android/pr-review-checklist.md` — Android 应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Android 应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`android/common/testing-and-release.md`、`android/common/code-style.md`、`android/common/security.md`

---

## iOS 移动端模板（`ios/`）

### 7. `ios/pr-review-checklist.md` — iOS 应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 iOS 应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`ios/common/testing-and-release.md`、`ios/common/code-style.md`、`ios/common/security.md`

---

## 前端模板（`frontend/`）

### 8. `frontend/pr-review-checklist.md` — 前端 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次前端 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`frontend/common/governance.md`、`frontend/common/baseline.md`

### 9. `frontend/eslint-prettier-baseline.md` — ESLint / Prettier 配置基线
- **谁用**：项目初始化者
- **何时用**：新建前端项目时，或统一升级团队 lint 配置时
- **怎么用**：复制 `.prettierrc` 和 `eslint.config.js` 配置到项目根目录，按 Vue/React 选择对应模板
- **关联规则**：`frontend/common/tooling.md`、`frontend/frameworks/*.md`

### 10. `frontend/permission-naming.md` — 权限点命名规范模板
- **谁用**：后台管理（admin-console）开发者
- **何时用**：新建权限模块、新增权限点、重构权限体系时
- **怎么用**：按三段式命名格式（`{模块}:{资源}:{操作}`）在 `permission/modules/` 下创建权限常量文件
- **关联规则**：`frontend/applications/admin-console.md` 第 4 章业务规则

### 11. `frontend/uni-request-wrapper.md` — uni.request 标准封装模板
- **谁用**：H5 / 小程序（uni-app）开发者
- **何时用**：新建 uni-app 项目时，初始化请求层
- **怎么用**：复制封装代码到 `services/request/` 目录，配置 baseURL 和错误码映射
- **关联规则**：`frontend/applications/wechat-h5.md`、`frontend/applications/miniprogram.md`

### 12. `frontend/miniprogram-review-checklist.md` — 小程序审核清单
- **谁用**：小程序开发者
- **何时用**：每次向微信提审前
- **怎么用**：逐项自查（包体积、内容合规、权限隐私、支付等），记录在提审 PR 或发版记录中
- **关联规则**：`frontend/applications/miniprogram.md` 第 6 章发布与审核

### 13. `frontend/tailwind-element-plus.md` — Tailwind CSS + Element Plus 组合约束
- **谁用**：后台管理（admin-console）开发者
- **何时用**：项目初始化配置样式体系时，或排查样式优先级冲突时
- **怎么用**：按加载顺序配置样式文件，按使用边界划分 Tailwind 与 Element Plus 职责
- **关联规则**：`frontend/applications/admin-console.md`、`frontend/common/componentization-and-adaptation.md`

### 14. `frontend/wechat-auth-share-flow.md` — 微信授权与分享流程规范
- **谁用**：公众号 H5 开发者
- **何时用**：接入微信授权登录、JSSDK 签名、分享配置时
- **怎么用**：按时序图和代码模板实现 `platform/h5/wechat/` 适配层，覆盖三类核心异常
- **关联规则**：`frontend/applications/wechat-h5.md` 第 5 章微信生态规则

### 15. `frontend/pro-table.md` — Schema-Driven 表格（ProTable）模板
- **谁用**：后台管理（admin-console）开发者
- **何时用**：开发列表页/管理页面中的数据表格时
- **怎么用**：复制 ProTable 组件和 useProTable composable 到项目中，按列定义 Schema 配置表格
- **关联规则**：`frontend/applications/admin-console.md` 业务规则

### 16. `frontend/tiptap-editor.md` — Tiptap 富文本编辑器封装模板
- **谁用**：后台管理（admin-console）开发者
- **何时用**：需要富文本编辑功能时（公告、文章、描述字段等）
- **怎么用**：复制 RichEditor 组件到项目中，配置 toolbar 和图片上传接口，展示时使用 sanitizeContent() 过滤 XSS
- **关联规则**：`frontend/applications/admin-console.md` 业务规则

### 17. `frontend/dependency-management.md` — 依赖管理与脚手架依赖清单
- **谁用**：项目初始化者、技术负责人
- **何时用**：新建项目选型依赖时、CI 中自动检查依赖合规性时
- **怎么用**：复制 `dependency-rules.json` 配置和 `check-dependencies.ts` 脚本到项目，CI 中执行检查
- **关联规则**：`frontend/common/stack-baseline.md`、`frontend/common/tooling.md`

### 18. `frontend/component-patterns.md` — 三端组件示例与适配层模板
- **谁用**：前端开发者（三端通用）
- **何时用**：开发公共组件、接入适配层、生成组件文档时
- **怎么用**：参照分层示例组织组件，复制适配层接口定义到 `platform/`，配置 vue-docgen-cli 生成文档
- **关联规则**：`frontend/common/componentization-and-adaptation.md`

### 19. `frontend/normalization-toolkit.md` — 规范化改造工具包
- **谁用**：技术负责人、执行改造的开发者
- **何时用**：老项目规范化改造（Token 收敛、组件替换、样式迁移）时
- **怎么用**：填写改造范围评估表、执行 Token 审计脚本、按补齐清单逐项替换
- **关联规则**：`frontend/common/normalization.md`

### 20. `frontend/workflow-toolkit.md` — 交付流程工具包
- **谁用**：所有前端开发者
- **何时用**：提交 PR 时填写描述模板、CI 中执行页面行数检查
- **怎么用**：配置 `.github/PULL_REQUEST_TEMPLATE.md` 自动填充，CI 中执行 `check-page-size.ts`
- **关联规则**：`frontend/common/workflow.md`

### 21. `frontend/miniprogram-ci-checks.md` — 小程序 CI 检查脚本
- **谁用**：小程序开发者、CI 流水线
- **何时用**：小程序构建后自动执行，阻断不合规产物
- **怎么用**：复制 `check-mp-size.ts` 和 `check-mp-resources.ts` 到 `scripts/`，CI 中构建后执行
- **关联规则**：`frontend/applications/miniprogram.md`、`frontend/common/tooling.md`

### 22. `frontend/naming-toolkit.md` — 命名规范工具包
- **谁用**：前端开发者、技术负责人
- **何时用**：项目命名治理、Token 新增审查、文件迁移重构时
- **怎么用**：执行文件命名检查脚本扫描不合规文件，执行 Token 冲突检查脚本审查命名
- **关联规则**：`frontend/common/naming.md`

### 23. `frontend/wechat-h5-toolkit.md` — 微信 H5 工具包
- **谁用**：微信 H5 开发者、测试人员
- **何时用**：H5 提测前进行兼容测试、活动 H5 开发时组织目录
- **怎么用**：按兼容测试清单逐项验证、按活动目录规则归档活动代码
- **关联规则**：`frontend/applications/wechat-h5.md`

### 24. `frontend/git-workflow-config.md` — Git 工作流配置模板
- **谁用**：项目初始化者
- **何时用**：新建项目配置 commitlint / husky / lint-staged 时
- **怎么用**：安装依赖，复制 commitlint.config.js 和 husky hooks 配置，配置分支名校验脚本
- **关联规则**：`frontend/common/git-workflow.md`

### 25. `frontend/testing-toolkit.md` — 测试工具包
- **谁用**：项目初始化者、前端开发者
- **何时用**：配置测试框架时、编写组件/composable/工具函数测试时
- **怎么用**：复制 vitest.config.ts 和 setup 文件，参照示例编写各类测试
- **关联规则**：`frontend/common/testing.md`

### 26. `frontend/security-toolkit.md` — 安全工具包
- **谁用**：项目初始化者、前端开发者
- **何时用**：配置 CSP、富文本净化、依赖审计、密钥泄露检测时
- **怎么用**：复制 CSP 配置和 DOMPurify 封装到项目，CI 中集成 audit 和 secretlint 脚本
- **关联规则**：`frontend/common/security.md`

### 27. `frontend/ci-pipeline.md` — CI 完整流水线模板
- **谁用**：项目初始化者、DevOps
- **何时用**：新建项目配置 CI 时、老项目补齐 CI 检查时
- **怎么用**：按应用类型选择对应模板，复制到 `.github/workflows/ci.yml`，按注释调整
- **关联规则**：`frontend/common/tooling.md`、`frontend/common/workflow.md`

---

## Python 服务端模板（`python-server/`）

### 28. `python-server/pr-review-checklist.md` — Python 服务端 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Python 服务端 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`python-server/common/testing-and-release.md`、`python-server/common/code-style.md`

---

## Java 服务端模板（`java-server/`）

### 29. `java-server/pr-review-checklist.md` — Java 服务端 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Java 服务端 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`java-server/common/testing-and-release.md`、`java-server/common/code-style.md`

---

## Node.js 服务端模板（`node-server/`）

### 30. `node-server/pr-review-checklist.md` — Node.js 服务端 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Node.js 服务端 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`node-server/common/testing-and-release.md`、`node-server/common/code-style.md`

---

## Electron 桌面模板（`electron-desktop/`）

### 31. `electron-desktop/pr-review-checklist.md` — Electron 桌面应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Electron 桌面应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`electron-desktop/common/testing-and-release.md`、`electron-desktop/common/security.md`

---

## React Native 模板（`react-native/`）

### 32. `react-native/pr-review-checklist.md` — React Native 应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 React Native 应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`react-native/common/testing-and-release.md`、`react-native/common/code-style.md`、`react-native/common/device-adaptation.md`

---

## Flutter 跨平台模板（`flutter/`）

### 33. `flutter/pr-review-checklist.md` — Flutter 应用 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：每次 Flutter 应用 PR 提交评审时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`flutter/common/testing-and-release.md`、`flutter/common/code-style.md`、`flutter/common/device-adaptation.md`

---

## 数据库模板（`database/`）

### 34. `database/pr-review-checklist.md` — 数据库 PR 评审清单
- **谁用**：PR 评审人（Reviewer）
- **何时用**：PR 包含数据库 Schema 变更、新增迁移脚本、种子数据变更时
- **怎么用**：复制清单到 PR 评审评论中，逐项勾选（P0 全部通过才可合并）
- **关联规则**：`database/database.md`、`database/data-migration.md`

---

## 前后端协作模板（`frontend-backend/`）

### 35. `frontend-backend/api-contract-template.md` — API 接口契约模板
- **谁用**：前端 + 后端开发者
- **何时用**：新接口设计阶段，前后端对齐接口契约时
- **怎么用**：复制模板填写接口路径、请求/响应结构、错误码、幂等性等字段，双方确认后作为开发依据
- **关联规则**：`frontend-backend-collaboration.md`

### 36. `frontend-backend/integration-checklist-template.md` — 联调检查清单模板
- **谁用**：前端 + 后端开发者
- **何时用**：联调阶段，逐项验证接口对接是否完整
- **怎么用**：复制清单逐项勾选（成功路径、鉴权失败、参数错误、幂等重试等），联调完成后归档
- **关联规则**：`frontend-backend-collaboration.md`

### 37. `frontend-backend/release-rollback-record-template.md` — 发布回滚记录模板
- **谁用**：发布负责人
- **何时用**：每次前后端联合发布或回滚时
- **怎么用**：复制模板记录发布版本、变更内容、发布顺序、回滚方案、验证结果
- **关联规则**：`frontend-backend-collaboration.md`

---

## 按角色速查

| 角色 | 常用模板 |
|------|----------|
| **新人** | `../frontend/quickstart.md`（阅读路径 + MUST 速查卡） |
| **项目初始化者** | `frontend/eslint-prettier-baseline.md`、`frontend/git-workflow-config.md`、`frontend/testing-toolkit.md`、`frontend/security-toolkit.md`、`frontend/ci-pipeline.md`、`frontend/dependency-management.md` |
| **PR 评审人** | `<域>/pr-review-checklist.md`（各域均有对应清单）、`frontend/workflow-toolkit.md` |
| **Python 服务端开发者** | `python-server/pr-review-checklist.md` |
| **Java 服务端开发者** | `java-server/pr-review-checklist.md` |
| **Node.js 服务端开发者** | `node-server/pr-review-checklist.md` |
| **Electron 桌面开发者** | `electron-desktop/pr-review-checklist.md` |
| **React Native 开发者** | `react-native/pr-review-checklist.md` |
| **Android 开发者** | `android/pr-review-checklist.md` |
| **iOS 开发者** | `ios/pr-review-checklist.md` |
| **Flutter 开发者** | `flutter/pr-review-checklist.md` |
| **数据库开发者** | `database/pr-review-checklist.md` |
| **小程序开发者** | `frontend/miniprogram-review-checklist.md`、`frontend/miniprogram-ci-checks.md`、`frontend/uni-request-wrapper.md` |
| **H5 开发者** | `frontend/wechat-auth-share-flow.md`、`frontend/wechat-h5-toolkit.md`、`frontend/uni-request-wrapper.md` |
| **后台管理开发者** | `frontend/permission-naming.md`、`frontend/tailwind-element-plus.md`、`frontend/pro-table.md`、`frontend/tiptap-editor.md` |
| **组件开发者** | `frontend/component-patterns.md`、`frontend/naming-toolkit.md` |
| **规范化改造** | `frontend/normalization-toolkit.md`、`frontend/naming-toolkit.md` |
| **前后端联调** | `frontend-backend/api-contract-template.md`、`frontend-backend/integration-checklist-template.md` |
| **发布负责人** | `frontend-backend/release-rollback-record-template.md` |
| **申请规则豁免** | `exception-request-template.md` |
