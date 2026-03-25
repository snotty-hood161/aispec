# React Native 编码场景 → 规则文件映射

## 始终加载（所有场景）
- `rules/react-native/common/baseline.md`
- `rules/react-native/common/forbidden.md`

---

## A. 新增页面 / Screen / Route
- 主文件：`rules/react-native/common/architecture.md`
- 关联文件：`rules/react-native/common/code-style.md`
- Profile（Expo）：`profiles/expo/project-structure.md`
- Profile（Bare）：`profiles/bare/project-structure.md`

## B. 组件开发（函数组件 / HOC / 自定义 Hook）
- 主文件：`rules/react-native/common/ui-framework.md`
- 关联文件：`rules/react-native/common/performance.md`、`rules/react-native/common/device-adaptation.md`

## C. 数据层（网络请求 / 本地数据库 / Repository）
- 主文件：`rules/react-native/common/data-access.md`
- 关联文件：`rules/react-native/common/error-handling.md`、`rules/react-native/common/security.md`
- 跨域：涉及服务端 API → 触发 `$frontend-backend-coding-guide`

## D. 状态管理（Zustand / Redux / React Query）
- 主文件：`rules/react-native/common/architecture.md`
- 关联文件：`rules/react-native/common/error-handling.md`

## E. 表单开发（含校验）
- 主文件：`rules/react-native/common/ui-framework.md`
- 关联文件：`rules/react-native/common/architecture.md`、`rules/react-native/common/security.md`

## F. 错误处理 / 用户提示
- 主文件：`rules/react-native/common/error-handling.md`
- 关联文件：`rules/react-native/common/observability.md`

## G. 安全（安全存储 / 混淆 / 网络安全）
- 主文件：`rules/react-native/common/security.md`
- 关联文件：`rules/react-native/common/data-access.md`

## H. 构建配置 / 环境管理 / 签名
- 主文件：`rules/react-native/common/configuration.md`
- 关联文件：`rules/react-native/common/testing-and-release.md`

## I. 日志 / 崩溃报告 / 性能监控
- 主文件：`rules/react-native/common/observability.md`
- 关联文件：`rules/react-native/common/error-handling.md`

## J. 性能优化（列表 / 桥通信 / Bundle 体积）
- 主文件：`rules/react-native/common/performance.md`
- 关联文件：`rules/react-native/common/ui-framework.md`

## K. 设备适配（手机 / 平板 / 折叠屏 / 横屏）
- 主文件：`rules/react-native/common/device-adaptation.md`
- 关联文件：`rules/react-native/common/ui-framework.md`

## L. 导航 / React Navigation / 主题
- 主文件：`rules/react-native/common/ui-framework.md`
- 关联文件：`rules/react-native/common/device-adaptation.md`

## M. 原生模块桥接（Native Module / Turbo Module）
- 主文件：`rules/react-native/common/architecture.md`
- 关联文件：`rules/react-native/common/performance.md`
- Profile（Bare）：`profiles/bare/project-structure.md`

## N. 测试 / CI / 应用商店发布 / OTA 更新
- 主文件：`rules/react-native/common/testing-and-release.md`
- 关联文件：`rules/react-native/common/code-style.md`
- 模板：`rules/templates/react-native/pr-review-checklist.md`

## O. 初始化项目结构
- 主文件（Expo）：`rules/react-native/profiles/expo/project-structure.md`
- 主文件（Bare）：`rules/react-native/profiles/bare/project-structure.md`
- 关联文件：`rules/react-native/common/architecture.md`
- 建议：使用 `$react-native-project-scaffold` 完成

---

## 场景冲突决策
1. `profile` 规则优先于 `common`。
2. 平台原生约束优先于本规范。
3. 同时命中多个场景时，合并去重，总量不超过 8 个。
