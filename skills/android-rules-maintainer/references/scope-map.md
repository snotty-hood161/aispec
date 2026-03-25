# 主题落点映射（需求 -> 规则文件）

用此表将用户需求映射到"主定义文件"，避免多文件重复修改。

## 通用主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| 技术基线/Kotlin 版本/AGP | `common/baseline.md` | `common/forbidden.md` |
| Kotlin 代码风格/ktlint/detekt | `common/code-style.md` | `profiles/*/project-structure.md` |
| 分层架构/Hilt/ViewModel | `common/architecture.md` | `common/code-style.md`, `common/performance.md` |
| 错误建模/Result/Coroutine 异常 | `common/error-handling.md` | `common/forbidden.md`, `common/observability.md` |
| R8 混淆/安全存储/网络安全 | `common/security.md` | `common/configuration.md`, `common/forbidden.md` |
| Room/Retrofit/DataStore | `common/data-access.md` | `common/code-style.md`, `profiles/*/project-structure.md` |
| BuildConfig/Flavor/签名 | `common/configuration.md` | `common/security.md`, `common/data-access.md` |
| Timber/Crashlytics/ANR | `common/observability.md` | `common/error-handling.md` |
| 启动/内存/电量优化 | `common/performance.md` | `common/architecture.md`, `common/code-style.md` |
| 测试/CI/CD/发布 | `common/testing-and-release.md` | `common/configuration.md` |
| Material Design/无障碍/适配 | `common/ui-framework.md` | `profiles/*/project-structure.md` |
| 禁止项（反模式） | `common/forbidden.md` | 各主题文件（反向校验） |

## Profile 主题

| 主题 | 主定义文件 | 常见关联文件 |
| --- | --- | --- |
| Compose 项目结构 | `profiles/compose/project-structure.md` | `common/code-style.md`, `common/architecture.md` |
| XML Views 项目结构 | `profiles/xml-views/project-structure.md` | `common/code-style.md`, `common/architecture.md` |

## 冲突决策
1. 同主题冲突：`profile` 规则优先于 `common`。
2. 无法消解：采用"更严格且可验证"的规则并在输出中标注。
