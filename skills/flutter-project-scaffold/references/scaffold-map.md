# 脚手架映射表（目标平台 → 规则与模板文件）

本文件定义每种目标平台初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认目标平台后，按下表加载对应文件。
2. "通用必读"对所有平台生效。
3. "专项文件"仅对特定平台生效。

---

## 一、通用必读（所有目标平台）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/flutter/common/baseline.md` | Flutter/Dart 版本、依赖管理、格式化要求 |
| `rules/flutter/common/code-style.md` | 命名、注释、分层编码 |
| `rules/flutter/common/architecture.md` | 状态管理、依赖注入、分层架构 |
| `rules/flutter/common/configuration.md` | 多环境配置、签名管理 |
| `rules/flutter/common/error-handling.md` | 异常分类与处理 |
| `rules/flutter/common/security.md` | 安全存储、HTTPS 强制 |
| `rules/flutter/common/observability.md` | 日志、崩溃报告、监控 |
| `rules/flutter/common/testing-and-release.md` | 测试要求与质量门禁 |
| `rules/flutter/common/data-access.md` | 网络请求与本地数据库封装 |
| `rules/flutter/common/performance.md` | Widget 优化与内存管理 |
| `rules/flutter/common/ui-framework.md` | 主题、导航、无障碍 |
| `rules/flutter/common/device-adaptation.md` | 响应式布局与设备适配 |
| `rules/flutter/common/forbidden.md` | 禁止事项 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/flutter/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、mobile 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/flutter/profiles/mobile/project-structure.md` | 移动端目录结构与模块组织 |

### 技术栈
- 语言：Dart ≥ 3.0
- 框架：Flutter ≥ 3.10
- 状态管理：Riverpod / Bloc / Provider（按项目选型）
- 网络：Dio / http
- 本地存储：sqflite / Hive / shared_preferences
- 路由：go_router / auto_route
- DI：get_it / riverpod

---

## 三、生成产物清单（通用）

每种目标平台初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/<mode>/project-structure.md` |
| `pubspec.yaml` | `common/baseline.md` |
| `analysis_options.yaml` | `common/code-style.md` |
| 多环境配置 | `common/configuration.md` |
| `lib/main.dart` 入口 | `common/architecture.md` |
| `.gitignore` | `common/security.md` |
| 路由配置 | `common/ui-framework.md` |
| 主题配置 | `common/ui-framework.md` |
| 错误处理基础结构 | `common/error-handling.md` |
