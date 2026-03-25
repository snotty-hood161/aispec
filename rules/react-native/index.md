# rules/react-native/index.md

## 目的
1. 统一 React Native 跨平台移动应用开发与交付标准，降低架构漂移和协作成本。
2. 采用"共性规则 + 工作流 profile"模式，确保跨平台一致性的同时尊重 Expo 与 bare workflow 差异。
3. 所有规则优先强调"可执行、可检查、可追踪"。

## 适用范围
1. 适用于所有使用 React Native + TypeScript 开发的跨平台移动应用项目（iOS + Android）。
2. TypeScript strict 模式为强制要求，不支持纯 JavaScript 项目。
3. React Native ≥ 0.72（New Architecture 支持）为推荐基线。
4. 若需例外，必须在评审中记录原因、边界、回收时间，并绑定责任人。

## 规则组成
1. `common`：所有 React Native 项目必须遵守的通用规则。
2. `profiles/expo`：面向 Expo managed workflow 的额外规则与项目结构。
3. `profiles/bare`：面向 bare workflow 的额外规则与项目结构。

## 适用方式
1. Expo managed 项目：`common + profiles/expo`。
2. Bare workflow 项目：`common + profiles/bare`。
3. 涉及前后端 API 交互时，必须同时遵守 `rules/frontend-backend-collaboration.md`。

## Skill 协作（推荐）
1. 编写 React Native 应用代码时优先使用 `$react-native-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 规则新增、修改、重构、审计任务，优先使用 `$react-native-rules-maintainer`。
4. Skill 执行时必须按需加载规则文件，不得一次性通读全部规范。
5. 涉及前后端 API 契约、联调、发布回滚时，优先使用 `$frontend-backend-coding-guide`。

## 冲突优先级
1. 具体 profile 规则优先于 `common` 中同主题的描述。
2. 平台原生约束（Google Play 政策 / App Store 审核指南）优先于本规范。
3. 前后端协作相关条款以 `rules/frontend-backend-collaboration.md` 为准。
4. 数据库相关条款以 `rules/database/database.md` 为准。
5. 当规则冲突无法消解时，以"更严格、更可验证"的规则为准。

---

## 目录索引

### 通用规则（common）— 所有 React Native 项目必须遵守
1. `common/baseline.md` — 技术基线、React Native 版本、依赖管理、ESLint/Prettier
2. `common/code-style.md` — TypeScript 命名规范、格式化、文档注释
3. `common/architecture.md` — 分层架构、状态管理（Zustand/Redux）、依赖注入
4. `common/error-handling.md` — 异常建模、ErrorBoundary、用户提示
5. `common/security.md` — 安全存储、代码混淆、网络安全、证书固定
6. `common/data-access.md` — 网络请求、本地数据库、文件管理
7. `common/configuration.md` — 构建变体、环境配置、签名管理
8. `common/observability.md` — 日志、崩溃报告、性能监控
9. `common/performance.md` — 列表优化、桥通信、包体积、JS Bundle
10. `common/testing-and-release.md` — 测试策略、CI/CD、应用商店发布、OTA 更新
11. `common/ui-framework.md` — 设计系统、导航（React Navigation）、主题、无障碍
12. `common/device-adaptation.md` — 跨平台设备适配（手机/平板/折叠屏/横屏）
13. `common/forbidden.md` — 禁止事项汇总

### 框架专属规则（profiles）
14. `profiles/expo/project-structure.md` — Expo managed workflow 项目结构与最佳实践
15. `profiles/bare/project-structure.md` — Bare workflow 项目结构与原生模块桥接

### 跨域协作
16. `rules/frontend-backend-collaboration.md` — 前后端契约、联调、发布回滚

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/react-native/pr-review-checklist.md` — React Native 应用 PR 评审清单
- `templates/exception-request-template.md` — 规范例外申请模板（通用）
