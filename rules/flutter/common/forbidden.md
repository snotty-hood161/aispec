# rules/flutter/common/forbidden.md

## 文档目标
1. 汇总所有 Flutter 项目的禁止事项，作为快速查阅的红线清单。
2. 各条目均关联到对应的详细规则文件。

---

## 代码质量

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-01 | 禁止在生产代码中使用 `print()` 输出日志 | `observability.md` |
| FB-02 | 禁止使用 `dynamic` 类型绕过类型检查（确需时必须注释原因） | `code-style.md` |
| FB-03 | 禁止空 `catch` 块（吞掉异常无任何处理） | `error-handling.md` |
| FB-04 | 禁止使用 `// ignore:` 注释绕过 lint 规则（确需时附原因并经评审） | `code-style.md` |
| FB-05 | 禁止滥用 `!`（强制解包）处理可空类型 | `code-style.md` |

## 架构

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-06 | 禁止在 Widget 层直接调用 HTTP Client / Database | `architecture.md` |
| FB-07 | 禁止使用 `setState` 管理跨 Widget 共享状态 | `architecture.md` |
| FB-08 | 禁止同项目混用多种状态管理方案 | `architecture.md` |
| FB-09 | 禁止 Widget 之间通过超过 2 层的回调链传递复杂状态 | `architecture.md` |

## 性能

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-10 | 禁止在 `build()` 方法中执行网络请求或数据库操作 | `performance.md` |
| FB-11 | 禁止使用 `ListView(children: [...])` 渲染长列表 | `performance.md` |
| FB-12 | 禁止在 `itemBuilder` 中创建 Controller / Stream 实例 | `performance.md` |
| FB-13 | 禁止在主 Isolate 中执行 > 16ms 的同步计算 | `performance.md` |
| FB-14 | 禁止全局持有 `BuildContext` 引用 | `performance.md` |

## 安全

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-15 | 禁止将密钥 / Token / 密码硬编码在 Dart 源码中 | `security.md` |
| FB-16 | 禁止在生产环境禁用 SSL 证书验证 | `security.md` |
| FB-17 | 禁止使用 `SharedPreferences` 存储 Token 或密码 | `security.md` |
| FB-18 | 禁止在日志 / 崩溃报告中输出敏感信息 | `security.md` |
| FB-19 | 禁止将 keystore / .p12 / 私钥文件提交到代码仓库 | `configuration.md` |

## 数据访问

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-20 | 禁止使用 `Map<String, dynamic>` 作为业务数据结构在层间传递 | `data-access.md` |
| FB-21 | 禁止在主 Isolate 中执行复杂数据库查询 | `data-access.md` |
| FB-22 | 禁止在 `SharedPreferences` 中存储 > 1MB 数据 | `data-access.md` |

## 设备适配

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-23 | 禁止通过硬编码设备型号 / 分辨率判断布局 | `device-adaptation.md` |
| FB-24 | 禁止使用 `Platform.isAndroid` / `Platform.isIOS` 判断屏幕尺寸 | `device-adaptation.md` |
| FB-25 | 禁止直接拉伸手机布局到平板（Expanded 断点必须提供多窗格布局） | `device-adaptation.md` |
| FB-26 | 禁止在 SafeArea 外区域放置可交互元素 | `device-adaptation.md` |

## 发布

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-27 | 禁止从本地开发机直接构建并上传应用商店 | `testing-and-release.md` |
| FB-28 | 禁止生产构建使用 debug 签名 | `testing-and-release.md` |
| FB-29 | 禁止跳过 CI 检查直接合并 | `testing-and-release.md` |

## 依赖

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-30 | 禁止使用 `any` 版本约束声明依赖 | `baseline.md` |
| FB-31 | 禁止使用已废弃或长期未维护的包 | `baseline.md` |
| FB-32 | 禁止使用 beta / dev / master channel 构建生产版本 | `baseline.md` |
