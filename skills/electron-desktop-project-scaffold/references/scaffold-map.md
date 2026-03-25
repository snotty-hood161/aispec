# 脚手架映射表（前端框架 → 规则与模板文件）

本文件定义每种前端框架初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认前端框架后，按下表加载对应文件。
2. "通用必读"对所有前端框架生效。
3. "前端规范引用"为渲染进程前端部分的基础约束。

---

## 一、通用必读（所有前端框架）

### Electron 主进程 / preload 规则
| 文件 | 用途 |
|------|------|
| `rules/electron-desktop/common/baseline.md` | 技术基线、Electron 版本、TypeScript 配置 |
| `rules/electron-desktop/common/code-style.md` | 主进程/preload 代码风格 |
| `rules/electron-desktop/common/architecture.md` | 主进程/渲染进程分层与模块架构 |
| `rules/electron-desktop/common/security.md` | contextIsolation、nodeIntegration、sandbox、CSP |
| `rules/electron-desktop/common/ipc-communication.md` | IPC 通信设计规范 |
| `rules/electron-desktop/common/error-handling.md` | 错误处理 |
| `rules/electron-desktop/common/configuration.md` | 配置文件组织 |
| `rules/electron-desktop/common/observability.md` | 日志与诊断 |
| `rules/electron-desktop/common/performance.md` | 性能优化 |
| `rules/electron-desktop/common/testing-and-release.md` | 测试要求与发布流程 |

### 前端基础规范引用
| 文件 | 用途 |
|------|------|
| `rules/frontend/common/baseline.md` | 前端基线规范 |
| `rules/frontend/common/naming.md` | 前端命名规范 |
| `rules/frontend/common/tooling.md` | 前端工具链 |
| `rules/frontend/common/testing.md` | 前端测试要求 |

### 模板文件
| 文件 | 产出物 |
|------|--------|
| `rules/templates/electron-desktop/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、Profile

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/electron-desktop/profiles/electron-v30/project-structure.md` | Electron v30+ 项目目录结构 |

---

## 三、前端框架差异

所有框架均使用 TypeScript + Vite 构建，差异仅在框架本身：

| 框架 | 入口文件 | 路由方案 | 状态管理 |
|------|---------|---------|---------|
| `react` | main.tsx + App.tsx | React Router | Zustand / Jotai |
| `vue` | main.ts + App.vue | Vue Router | Pinia |

### 技术栈（通用）
- 主进程：Node.js + TypeScript
- preload：TypeScript + contextBridge
- 渲染进程：用户选择的框架 + TypeScript + Vite
- 构建：electron-vite
- 打包：electron-builder
- 测试：Vitest（单元）+ Playwright（E2E）

---

## 四、生成产物清单（通用）

每种前端框架初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/electron-v30/project-structure.md` |
| `package.json` | `common/baseline.md` |
| `electron-builder.yml` | `common/configuration.md` + `common/security.md` |
| `tsconfig.json`（3 份） | 基础规范 |
| `src/main/index.ts` | `common/architecture.md` |
| `src/preload/index.ts` | `common/security.md` + `common/ipc-communication.md` |
| `src/shared/ipcChannels.ts` | `common/ipc-communication.md` |
| `.eslintrc.cjs` + `.prettierrc` | `common/code-style.md` |
| `.gitignore` | `common/security.md` |
