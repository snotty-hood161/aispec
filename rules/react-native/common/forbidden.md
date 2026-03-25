# rules/react-native/common/forbidden.md

## 文档目标
1. 汇总所有 React Native 项目的禁止事项，作为快速查阅的红线清单。
2. 各条目均关联到对应的详细规则文件。

---

## 代码质量

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-01 | 禁止在生产代码中使用 `console.log` / `console.warn` / `console.error` | `observability.md` |
| FB-02 | 禁止使用 `any` 类型绕过类型检查（确需时必须注释原因） | `code-style.md` |
| FB-03 | 禁止空 `catch` 块（吞掉异常无任何处理） | `error-handling.md` |
| FB-04 | 禁止使用 `eslint-disable` 注释绕过 lint 规则（确需时附原因并经评审） | `baseline.md` |
| FB-05 | 禁止使用 `@ts-ignore` 跳过类型检查（使用 `@ts-expect-error` 并附原因） | `baseline.md` |
| FB-06 | 禁止使用 `var` 声明变量 | `code-style.md` |
| FB-07 | 禁止使用 `as any` 或 `as unknown as T` 绕过类型检查 | `code-style.md` |

## 架构

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-08 | 禁止在组件中直接调用 `fetch` / `axios` 发起网络请求 | `architecture.md` |
| FB-09 | 禁止同项目混用多种全局状态管理方案 | `architecture.md` |
| FB-10 | 禁止组件之间通过超过 2 层的 Props 传递复杂状态 | `architecture.md` |
| FB-11 | 禁止在组件渲染函数中直接 `try-catch` 网络请求 | `error-handling.md` |
| FB-12 | 禁止在 Store 中存储函数、类实例或 React 组件 | `architecture.md` |

## 性能

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-13 | 禁止使用 `ScrollView` + `map()` 渲染长列表 | `performance.md` |
| FB-14 | 禁止使用 `index` 作为 FlatList 的 `key` | `performance.md` |
| FB-15 | 禁止在 `renderItem` / 渲染函数中执行网络请求或存储操作 | `performance.md` |
| FB-16 | 禁止在循环中高频调用原生桥方法 | `performance.md` |
| FB-17 | 禁止在启动路径中执行同步阻塞操作 | `performance.md` |
| FB-18 | 禁止在列表项中加载未裁剪的原始大图（> 1MB） | `performance.md` |
| FB-19 | 禁止使用 `Animated` API 实现高频动画（手势跟随等须用 Reanimated） | `performance.md` |
| FB-20 | 禁止在组件外部全局持有组件引用或状态对象 | `performance.md` |

## 安全

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-21 | 禁止将密钥 / Token / 密码硬编码在源码中 | `security.md` |
| FB-22 | 禁止在生产环境禁用 SSL 证书验证 | `security.md` |
| FB-23 | 禁止使用 `AsyncStorage` 存储 Token 或密码 | `security.md` |
| FB-24 | 禁止在日志 / 崩溃报告中输出敏感信息 | `security.md` |
| FB-25 | 禁止以明文 JS Bundle 分发生产构建（必须使用 Hermes bytecode） | `security.md` |
| FB-26 | 禁止在 WebView 中启用 JavaScript 而不限制加载域名 | `security.md` |
| FB-27 | 禁止深链接参数未经校验直接使用 | `device-adaptation.md` |

## 数据访问

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-28 | 禁止使用 `Record<string, any>` 作为 API 响应类型 | `data-access.md` |
| FB-29 | 禁止在 JS 线程中执行耗时的数据库查询 | `data-access.md` |
| FB-30 | 禁止在 `AsyncStorage` 中存储 > 6MB 数据 | `data-access.md` |
| FB-31 | 禁止 API 响应数据未经类型校验直接渲染到 UI | `data-access.md` |

## UI 与样式

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-32 | 禁止使用内联样式对象（`style={{ ... }}`） | `ui-framework.md` |
| FB-33 | 禁止在样式中硬编码颜色值、字号、间距（必须引用主题变量） | `ui-framework.md` |
| FB-34 | 禁止使用 `PanResponder` 处理手势（须用 react-native-gesture-handler） | `ui-framework.md` |
| FB-35 | 禁止可交互元素缺少 `accessibilityLabel` | `ui-framework.md` |

## 设备适配

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-36 | 禁止通过硬编码设备型号 / 分辨率判断布局 | `device-adaptation.md` |
| FB-37 | 禁止使用 `Platform.OS` 判断屏幕尺寸 | `device-adaptation.md` |
| FB-38 | 禁止在安全区域外放置可交互元素 | `device-adaptation.md` |
| FB-39 | 禁止应用启动时批量请求所有权限 | `device-adaptation.md` |
| FB-40 | 禁止申请未使用的权限 | `device-adaptation.md` |
| FB-41 | 禁止忽略键盘弹出对布局的影响 | `device-adaptation.md` |

## 配置与环境

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-42 | 禁止将 `.env` 文件提交到代码仓库 | `configuration.md` |
| FB-43 | 禁止将 keystore / .p12 / 私钥文件提交到代码仓库 | `configuration.md` |
| FB-44 | 禁止在源码中硬编码 API 地址或密钥 | `configuration.md` |
| FB-45 | 禁止使用同一 applicationId / Bundle ID 部署不同环境 | `configuration.md` |

## 发布

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-46 | 禁止从本地开发机直接构建并上传应用商店 | `testing-and-release.md` |
| FB-47 | 禁止生产构建使用 debug 签名 | `testing-and-release.md` |
| FB-48 | 禁止跳过 CI 检查直接合并 | `testing-and-release.md` |
| FB-49 | 禁止 OTA 更新包含原生代码变更 | `testing-and-release.md` |
| FB-50 | 禁止发版时不上传 Source Map 到崩溃收集平台 | `testing-and-release.md` |

## 依赖

| ID | 禁止事项 | 关联规则 |
|----|---------|---------|
| FB-51 | 禁止使用 nightly / canary 版本构建生产版本 | `baseline.md` |
| FB-52 | 禁止使用已废弃或长期未维护的包 | `baseline.md` |
| FB-53 | 禁止在生产构建中开启 Remote JS Debugging | `baseline.md` |
| FB-54 | 禁止在生产环境输出 debug 级别日志 | `observability.md` |
| FB-55 | 禁止在无崩溃收集平台的情况下发布生产版本 | `observability.md` |
