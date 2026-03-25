# 脚手架映射表（UI 框架 → 规则与模板文件）

本文件定义每种 UI 框架初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认 UI 框架后，按下表加载对应文件。
2. "通用必读"对所有 UI 框架生效。

---

## 一、通用必读（所有 UI 框架）

### Android 规则
| 文件 | 用途 |
|------|------|
| `rules/android/common/baseline.md` | Kotlin 版本、AGP、依赖管理 |
| `rules/android/common/code-style.md` | Kotlin 命名、静态分析 |
| `rules/android/common/architecture.md` | 分层架构、Hilt、ViewModel |
| `rules/android/common/security.md` | R8 混淆、安全存储、网络安全 |
| `rules/android/common/error-handling.md` | 错误建模与异常处理 |
| `rules/android/common/configuration.md` | 构建变体、签名管理 |
| `rules/android/common/data-access.md` | Room、Retrofit、DataStore |
| `rules/android/common/observability.md` | Timber、Crashlytics |
| `rules/android/common/performance.md` | 启动/内存/电量优化 |
| `rules/android/common/testing-and-release.md` | 测试策略与发布流程 |
| `rules/android/common/ui-framework.md` | Material Design、无障碍 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/android/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、UI 框架差异

| 框架 | Profile 规则 | 入口组件 | 导航方案 | 状态管理 |
|------|-------------|---------|---------|---------|
| `compose` | `profiles/compose/project-structure.md` | MainActivity + NavHost | Navigation Compose | StateFlow + ViewModel |
| `xml-views` | `profiles/xml-views/project-structure.md` | Activity + Fragment | Navigation Component | StateFlow + ViewModel |

### 技术栈（通用）
- 语言：Kotlin
- 构建：Gradle Kotlin DSL + Version Catalog
- DI：Hilt
- 网络：Retrofit + OkHttp
- 数据库：Room
- 测试：JUnit 5 + MockK + Turbine
- CI：GitHub Actions / GitLab CI

---

## 三、生成产物清单（通用）

每种 UI 框架初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/*/project-structure.md` |
| `build.gradle.kts`（project + app） | `common/baseline.md` |
| `gradle/libs.versions.toml` | `common/baseline.md` |
| `proguard-rules.pro` | `common/security.md` |
| `network_security_config.xml` | `common/security.md` |
| `.editorconfig` | `common/code-style.md` |
| `detekt.yml` | `common/code-style.md` |
| `.gitignore` | `common/security.md` |
