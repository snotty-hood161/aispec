# rules/flutter/index.md

## 目的
1. 统一 Flutter 跨平台应用开发与交付标准，降低架构漂移和协作成本。
2. 采用"共性规则 + 目标平台规则"模式，确保跨平台一致性的同时尊重各平台特性。
3. 所有规则优先强调"可执行、可检查、可追踪"。

## 适用范围
1. 适用于所有使用 Flutter + Dart 开发的跨平台应用项目（移动端、桌面端、Web 端）。
2. Dart 3.0+ 与 Null Safety 为强制要求，不支持旧版 Dart。
3. 若需例外，必须在评审中记录原因、边界、回收时间，并绑定责任人。

## 规则组成
1. `common`：所有 Flutter 项目必须遵守的通用规则。
2. `profiles/mobile`：面向 Android + iOS 移动端的额外规则与项目结构。

## 适用方式
1. 移动端项目（Android + iOS）：`common + profiles/mobile`。
2. 多平台项目（移动 + Web / 桌面）：`common + profiles/mobile`，Web / 桌面部分按需补充。
3. 涉及前后端 API 交互时，必须同时遵守 `rules/frontend-backend-collaboration.md`。

## Skill 协作（推荐）
1. 编写 Flutter 应用代码时优先使用 `$flutter-coding-guide`，按编码场景自动加载规则。
2. 跨域业务任务（涉及多个技术栈）使用 `$task-router` 自动分析并路由。
3. 规则新增、修改、重构、审计任务，优先使用 `$flutter-rules-maintainer`。
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

### 通用规则（common）— 所有 Flutter 项目必须遵守
1. `common/baseline.md` — 技术基线、SDK 版本、依赖管理、静态分析
2. `common/code-style.md` — Dart 命名规范、格式化、文档注释
3. `common/architecture.md` — 分层架构、状态管理、依赖注入
4. `common/error-handling.md` — 异常建模、错误边界、用户提示
5. `common/security.md` — 安全存储、代码混淆、网络安全
6. `common/data-access.md` — 网络请求、本地数据库、文件管理
7. `common/configuration.md` — 构建变体、环境配置、签名管理
8. `common/observability.md` — 日志、崩溃报告、性能监控
9. `common/performance.md` — Widget 优化、渲染性能、包体积
10. `common/testing-and-release.md` — 测试策略、CI/CD、应用商店发布
11. `common/ui-framework.md` — Material/Cupertino 设计、主题、导航、无障碍
12. `common/device-adaptation.md` — 跨平台设备适配（手机/平板/折叠屏/横屏）
13. `common/forbidden.md` — 禁止事项汇总

### 框架专属规则（profiles）
14. `profiles/mobile/project-structure.md` — 移动端（Android + iOS）项目结构与最佳实践

### 跨域协作
15. `rules/frontend-backend-collaboration.md` — 前后端契约、联调、发布回滚

### 配套模板 — 参见 `rules/templates/index.md`
- `templates/flutter/pr-review-checklist.md` — Flutter 应用 PR 评审清单
- `templates/exception-request-template.md` — 规范例外申请模板（通用）
