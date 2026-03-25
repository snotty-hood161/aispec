# 脚手架映射表（工作流模式 → 规则与模板文件）

本文件定义每种工作流模式初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认工作流模式后，按下表加载对应文件。
2. "通用必读"对所有模式生效。
3. "专项文件"仅对特定模式生效。

---

## 一、通用必读（所有工作流模式）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/react-native/common/baseline.md` | React Native/TypeScript 版本、依赖管理、Lint/格式化要求 |
| `rules/react-native/common/code-style.md` | 命名、注释、分层编码 |
| `rules/react-native/common/architecture.md` | 状态管理、依赖注入、分层架构、原生桥接 |
| `rules/react-native/common/configuration.md` | 多环境配置、签名管理 |
| `rules/react-native/common/error-handling.md` | 异常分类与 ErrorBoundary |
| `rules/react-native/common/security.md` | 安全存储、HTTPS 强制 |
| `rules/react-native/common/observability.md` | 日志、崩溃报告、监控 |
| `rules/react-native/common/testing-and-release.md` | 测试要求与质量门禁 |
| `rules/react-native/common/data-access.md` | 网络请求与本地数据库封装 |
| `rules/react-native/common/performance.md` | 列表优化、桥通信与内存管理 |
| `rules/react-native/common/ui-framework.md` | 导航、主题、无障碍 |
| `rules/react-native/common/device-adaptation.md` | 响应式布局与设备适配 |
| `rules/react-native/common/forbidden.md` | 禁止事项 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/react-native/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、expo 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/react-native/profiles/expo/project-structure.md` | Expo managed workflow 目录结构与模块组织 |

### 技术栈
- 语言：TypeScript ≥ 5.0（strict 模式）
- 框架：Expo SDK ≥ 49 / React Native ≥ 0.72
- 状态管理：Zustand / Redux Toolkit / React Query（按项目选型）
- 网络：axios / ky / React Query
- 本地存储：expo-sqlite / MMKV / AsyncStorage
- 路由：expo-router / React Navigation
- 构建：EAS Build
- OTA 更新：EAS Update

---

## 三、bare 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/react-native/profiles/bare/project-structure.md` | Bare workflow 目录结构与原生模块桥接 |

### 技术栈
- 语言：TypeScript ≥ 5.0（strict 模式）
- 框架：React Native ≥ 0.72（New Architecture）
- 状态管理：Zustand / Redux Toolkit / React Query（按项目选型）
- 网络：axios / ky / React Query
- 本地存储：react-native-mmkv / WatermelonDB / AsyncStorage
- 路由：React Navigation
- 构建：Fastlane / Gradle + Xcode
- OTA 更新：CodePush / 自建 OTA
- 原生桥接：Turbo Module / Fabric / JSI

---

## 四、生成产物清单（通用）

每种工作流模式初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<mode>/project-structure.md` |
| `package.json` | `common/baseline.md` |
| `tsconfig.json` | `common/code-style.md` |
| `.eslintrc.js` / `eslint.config.js` | `common/code-style.md` |
| `.prettierrc` | `common/code-style.md` |
| 多环境配置 | `common/configuration.md` |
| `App.tsx` / `app/_layout.tsx` 入口 | `common/architecture.md` |
| `.gitignore` | `common/security.md` |
| 导航配置 | `common/ui-framework.md` |
| 主题配置 | `common/ui-framework.md` |
| ErrorBoundary 基础结构 | `common/error-handling.md` |
