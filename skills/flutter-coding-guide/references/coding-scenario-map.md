# Flutter 编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/flutter/common/baseline.md`
- `rules/flutter/common/forbidden.md`

---

## A. 新增页面 / Screen / Route
- 主文件：`rules/flutter/common/architecture.md`
- 关联文件：`rules/flutter/common/code-style.md`
- Profile：`profiles/mobile/project-structure.md`

## B. Widget 开发（Stateless / Stateful / Custom）
- 主文件：`rules/flutter/common/ui-framework.md`
- 关联文件：`rules/flutter/common/performance.md`、`rules/flutter/common/device-adaptation.md`

## C. 数据层（网络请求 / 本地数据库 / Repository）
- 主文件：`rules/flutter/common/data-access.md`
- 关联文件：`rules/flutter/common/error-handling.md`、`rules/flutter/common/security.md`
- 跨域：涉及服务端 API → 触发 `$frontend-backend-coding-guide`

## D. 状态管理（Riverpod / BLoC / Provider）
- 主文件：`rules/flutter/common/architecture.md`
- 关联文件：`rules/flutter/common/error-handling.md`

## E. 表单开发（含校验）
- 主文件：`rules/flutter/common/ui-framework.md`
- 关联文件：`rules/flutter/common/architecture.md`、`rules/flutter/common/security.md`

## F. 错误处理 / 用户提示
- 主文件：`rules/flutter/common/error-handling.md`
- 关联文件：`rules/flutter/common/observability.md`

## G. 安全（安全存储 / 混淆 / 网络安全）
- 主文件：`rules/flutter/common/security.md`
- 关联文件：`rules/flutter/common/data-access.md`

## H. 构建配置 / 环境管理 / 签名
- 主文件：`rules/flutter/common/configuration.md`
- 关联文件：`rules/flutter/common/testing-and-release.md`

## I. 日志 / 崩溃报告 / 性能监控
- 主文件：`rules/flutter/common/observability.md`
- 关联文件：`rules/flutter/common/error-handling.md`

## J. 性能优化（Widget 优化 / 渲染 / 包体积）
- 主文件：`rules/flutter/common/performance.md`
- 关联文件：`rules/flutter/common/ui-framework.md`

## K. 设备适配（手机 / 平板 / 折叠屏 / 横屏）
- 主文件：`rules/flutter/common/device-adaptation.md`
- 关联文件：`rules/flutter/common/ui-framework.md`

## L. 主题 / 导航 / Material & Cupertino
- 主文件：`rules/flutter/common/ui-framework.md`
- 关联文件：`rules/flutter/common/device-adaptation.md`

## M. 测试 / CI / 应用商店发布
- 主文件：`rules/flutter/common/testing-and-release.md`
- 关联文件：`rules/flutter/common/code-style.md`
- 模板：`rules/templates/flutter/pr-review-checklist.md`

## N. 初始化项目结构
- 主文件：`rules/flutter/profiles/mobile/project-structure.md`
- 关联文件：`rules/flutter/common/architecture.md`
- 建议：使用 `$flutter-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 平台原生约束优先于本规范。
3. 同时命中多个场景时，合并去重，总量不超过 8 个。
