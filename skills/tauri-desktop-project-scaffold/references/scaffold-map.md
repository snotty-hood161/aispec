# 脚手架映射表（前端框架 → 规则与模板文件）

本文件定义每种前端框架初始化时需要读取的规则文件与模板文件。

## 使用方式
1. 确认前端框架后，按下表加载对应文件。
2. "通用必读"对所有前端框架生效。
3. "前端规范引用"为前端部分的基础约束。

---

## 一、通用必读（所有前端框架）

### Tauri / Rust 后端规则
| 文件 | 用途 |
|------|------|
| `rules/tauri-desktop/common/baseline.md` | Rust 版本、Tauri 版本、项目结构 |
| `rules/tauri-desktop/common/code-style.md` | Rust 命名、注释、模块组织 |
| `rules/tauri-desktop/common/architecture.md` | 应用架构与前后端分层 |
| `rules/tauri-desktop/common/security.md` | 权限策略、IPC 安全 |
| `rules/tauri-desktop/common/error-handling.md` | 错误分类与传播 |
| `rules/tauri-desktop/common/configuration.md` | 配置文件组织 |
| `rules/tauri-desktop/common/data-access.md` | 数据持久化与存储 |
| `rules/tauri-desktop/common/observability.md` | 日志与诊断 |
| `rules/tauri-desktop/common/performance.md` | 性能优化 |
| `rules/tauri-desktop/common/testing-and-release.md` | 测试要求与发布流程 |

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
| `rules/templates/tauri-desktop/pr-review-checklist.md` | PR 评审清单 |
| `rules/templates/exception-request-template.md` | 规范例外申请模板 |

---

## 二、Profile

### 规则文件
| 文件 | 用途 |
|------|------|
| `rules/tauri-desktop/profiles/tauri-v2/project-structure.md` | Tauri v2 项目目录结构 |

---

## 三、前端框架差异

所有框架均使用 TypeScript + Vite 构建，差异仅在框架本身：

| 框架 | 入口文件 | 路由方案 | 状态管理 |
|------|---------|---------|---------|
| `vue` | main.ts + App.vue | Vue Router | Pinia |
| `react` | main.tsx + App.tsx | React Router | Zustand / Jotai |
| `svelte` | main.ts + App.svelte | SvelteKit Router | Svelte Stores |
| `solid` | index.tsx + App.tsx | @solidjs/router | Solid Signals |

### 技术栈（通用）
- 后端：Rust + Tauri v2
- 前端：用户选择的框架 + TypeScript + Vite
- 测试：Rust — cargo test；前端 — Vitest
- 构建：tauri build

---

## 四、生成产物清单（通用）

每种前端框架初始化后应包含以下产物：

| 产出物 | 来源 |
|--------|------|
| 标准目录结构 | `profiles/tauri-v2/project-structure.md` |
| `src-tauri/Cargo.toml` | `common/baseline.md` |
| `src-tauri/tauri.conf.json` | `common/configuration.md` + `common/security.md` |
| `src-tauri/src/main.rs` | `common/architecture.md` |
| `package.json` | 前端基础规范 |
| `tsconfig.json` | 前端基础规范 |
| `.gitignore` | `common/security.md` |
