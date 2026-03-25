# 脚手架映射表（应用类型 → 规则与模板文件）

本文件定义每种应用类型初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认应用类型后，按下表加载对应文件。
2. "通用必读"对所有类型生效。
3. "专项文件"仅对特定类型生效。

---

## 一、通用必读（所有应用类型）

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/frontend/common/governance.md` | 规则分级与治理流程 |
| `rules/frontend/common/baseline.md` | TypeScript 基线与编码规范 |
| `rules/frontend/common/naming.md` | 命名规范 |
| `rules/frontend/common/git-workflow.md` | Git 工作流 |
| `rules/frontend/common/stack-baseline.md` | 技术栈基线 |
| `rules/frontend/common/tooling.md` | 工具链与 CI |
| `rules/frontend/common/project-structure.md` | 通用结构边界 |
| `rules/frontend/common/env-config.md` | 环境配置 |
| `rules/frontend/common/security.md` | 安全基线 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/frontend/eslint-prettier-baseline.md` | `.eslintrc.*` + `.prettierrc` |
| `rules/templates/frontend/git-workflow-config.md` | `commitlint.config.*` + `.husky/` |
| `rules/templates/frontend/testing-toolkit.md` | `vitest.config.*` + 测试目录结构 |
| `rules/templates/frontend/security-toolkit.md` | CSP 配置 + 依赖审计脚本 |
| `rules/templates/frontend/ci-pipeline.md` | `.github/workflows/ci.yml` |
| `rules/templates/frontend/dependency-management.md` | 依赖锁定与升级策略 |

---

## 二、admin-console 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/frontend/applications/admin-console.md` | 技术栈锁定与业务规则 |
| `rules/frontend/project-structure/admin-console.md` | 目录结构与分层边界 |
| `rules/frontend/frameworks/vue3-typescript.md` | Vue3 + TypeScript 约束 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/frontend/tailwind-element-plus.md` | `tailwind.config.*` + Element Plus 主题 |
| `rules/templates/frontend/permission-naming.md` | `permission/` 目录结构与命名 |
| `rules/templates/frontend/pro-table.md` | ProTable 组件骨架 |
| `rules/templates/frontend/tiptap-editor.md` | Tiptap 编辑器封装骨架 |

### 技术栈
- 框架：Vue3 + TypeScript + Vite
- UI：Element Plus
- CSS：Tailwind CSS
- 状态：Pinia + pinia-plugin-persistedstate
- 路由：Vue Router
- 请求：Axios
- 图表：ECharts

---

## 三、wechat-h5 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/frontend/applications/wechat-h5.md` | 技术栈与微信生态规则 |
| `rules/frontend/project-structure/wechat-h5.md` | 目录结构与平台分层 |
| `rules/frontend/frameworks/vue3-typescript.md` | Vue3 + TypeScript 约束 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/frontend/wechat-auth-share-flow.md` | 微信授权与分享封装 |
| `rules/templates/frontend/uni-request-wrapper.md` | `services/request.ts` |
| `rules/templates/frontend/wechat-h5-toolkit.md` | 兼容测试清单 + 活动归档规则 |

### 技术栈
- 框架：uni-app + Vue3 + TypeScript
- UI：uview-plus
- CSS：UnoCSS（Tailwind 风格语法）
- 状态：Pinia + pinia-plugin-persistedstate
- 请求：uni.request 统一封装
- 微信能力：weixin-js-sdk（封装在适配层）

---

## 四、miniprogram 专项

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/frontend/applications/miniprogram.md` | 技术栈与平台规则 |
| `rules/frontend/project-structure/miniprogram.md` | 目录结构与分包边界 |
| `rules/frontend/frameworks/vue3-typescript.md` | Vue3 + TypeScript 约束 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/frontend/miniprogram-review-checklist.md` | 提审自查清单 |
| `rules/templates/frontend/miniprogram-ci-checks.md` | 包体积 + 资源格式检查 |
| `rules/templates/frontend/uni-request-wrapper.md` | `services/request.ts` |

### 技术栈
- 框架：uni-app + Vue3 + TypeScript
- UI：uview-plus
- CSS：UnoCSS（Tailwind 风格语法）
- 状态：Pinia + pinia-plugin-persistedstate
- 请求：uni.request 统一封装
- 图表：uCharts

---

## 五、生成产物清单（通用）

每种应用类型初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `project-structure/<target>.md` |
| `tsconfig.json` + 路径别名 | `common/baseline.md` + 框架约束 |
| `.eslintrc.*` + `.prettierrc` | `eslint-prettier-baseline.md` |
| `commitlint.config.*` + `.husky/` | `git-workflow-config.md` |
| `vitest.config.*` | `testing-toolkit.md` |
| `.github/workflows/ci.yml` | `ci-pipeline.md` |
| `.env.example` + `env.d.ts` | `common/env-config.md` |
| `package.json`（含四脚本） | `common/tooling.md` |
| `.gitignore` | `common/security.md` + `common/env-config.md` |
