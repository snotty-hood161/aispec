# rules/frontend/quickstart.md — 新人快速上手指南

## 文档目标
1. 为新加入团队的前端开发者提供最短阅读路径。
2. 按应用类型给出"先读什么、再读什么"的清晰指引。
3. 本文件不是规则文件，是导航文件。具体约束以各规则文件为准。

---

## 你好，新同事！

本仓库是团队的**前端工程规范体系**，包含规则文件（rules/）和可复用模板（templates/）。

**使用原则**：按需加载，不要通读。每次任务只读与你相关的规则文件即可。

---

## 第一步：通用必读（约 30 分钟）

无论你负责哪个项目，以下 4 个文件必须先读：

| 顺序 | 文件 | 内容 | 阅读时间 |
|------|------|------|----------|
| 1 | `common/governance.md` | 规则分级（MUST/SHOULD/MAY）、例外申请流程 | 10 分钟 |
| 2 | `common/baseline.md` | TypeScript strict、注释规范、API 约束、调试代码清理 | 10 分钟 |
| 3 | `common/naming.md` | 命名规范（变量/组件/Token/文件） | 5 分钟 |
| 4 | `common/git-workflow.md` | 分支命名、Conventional Commits、合并策略 | 5 分钟 |

---

## 第二步：按你的项目类型选读

### 后台管理（admin-console）

```
applications/admin-console.md          ← 技术栈锁定与业务规则
project-structure/admin-console.md     ← 目录结构与分层边界
frameworks/vue3-typescript.md          ← Vue3 + TypeScript 专项约束
```

常用模板：
- `templates/frontend/tailwind-element-plus.md` — 样式体系配置
- `templates/frontend/permission-naming.md` — 权限点命名
- `templates/frontend/pro-table.md` — 数据表格模式
- `templates/frontend/eslint-prettier-baseline.md` — Lint 配置

### 公众号 H5（wechat-h5）

```
applications/wechat-h5.md             ← 技术栈与微信生态规则
project-structure/wechat-h5.md        ← 目录结构与平台分层
```

常用模板：
- `templates/frontend/wechat-auth-share-flow.md` — 微信授权与分享
- `templates/frontend/uni-request-wrapper.md` — uni.request 封装
- `templates/frontend/wechat-h5-toolkit.md` — 兼容测试清单

### 小程序（miniprogram）

```
applications/miniprogram.md           ← 技术栈、平台规则、发布审核
project-structure/miniprogram.md      ← 目录结构与分包边界
```

常用模板：
- `templates/frontend/miniprogram-review-checklist.md` — 提审自查清单
- `templates/frontend/miniprogram-ci-checks.md` — 包体积与资源检查
- `templates/frontend/uni-request-wrapper.md` — uni.request 封装

---

## 第三步：提交你的第一个 PR

```
1. 创建分支
   └─ git checkout -b feature/{issue-id}-简要描述
       │
2. 编写代码
   └─ 参照对应规则文件，注意 MUST 级约束
       │
3. 本地验证
   └─ pnpm lint && pnpm typecheck && pnpm test
       │
4. 提交代码
   └─ git commit -m "feat(order): 新增订单导出功能"
   └─ 格式：type(scope): description（commitlint 自动校验）
       │
5. 推送并创建 PR
   └─ PR 描述使用模板（templates/frontend/workflow-toolkit.md）
   └─ 必须填写：变更说明、影响范围、测试验证、回滚方案
       │
6. 等待评审
   └─ 评审人使用 PR 评审清单（templates/frontend/pr-review-checklist.md）
   └─ CI 全部通过 + 至少 1 人 Approve 后合并
```

---

## 第四步：进阶阅读（按需）

| 场景 | 阅读文件 |
|------|----------|
| 需要了解性能要求 | `common/performance.md` |
| 需要接入错误监控 | `common/error-monitoring.md` |
| 需要做规范化改造 | `common/normalization.md` + `templates/frontend/normalization-toolkit.md` |
| 需要写公共组件 | `common/componentization-and-adaptation.md` |
| 需要配置 CI | `templates/frontend/ci-pipeline.md` |
| 需要写测试 | `common/testing.md` + `templates/frontend/testing-toolkit.md` |
| 需要了解安全要求 | `common/security.md` |
| 需要管理环境配置 | `common/env-config.md` |
| 需要申请规则豁免 | `templates/exception-request-template.md` |

---

## MUST 规则速查卡

> 以下是所有 `common/*.md` 中 MUST 级规则的分类摘要。完整条款以各规则文件为准。

### 编码基线

| 规则摘要 | 来源 |
|----------|------|
| TypeScript 开启 `strict` 模式 | baseline |
| 禁止无边界 `any`，确需使用必须注释原因 | baseline |
| 导出的函数/类/hook 必须显式声明输入输出类型 | baseline |
| 统一通过 `services` 层访问接口，组件内禁止直接写请求 | baseline |
| 全局状态只放跨页面共享数据，页面私有状态禁止提升 | baseline |
| 副作用逻辑（事件/定时器/订阅）必须可清理 | baseline |
| 所有函数/组件/Hook 必须添加中文注释 | baseline |
| 文件头部必须包含模块用途说明注释 | baseline |

### 命名规范

| 规则摘要 | 来源 |
|----------|------|
| 变量/函数 `camelCase`，类型/组件 `PascalCase`，常量 `UPPER_SNAKE_CASE` | naming |
| 目录与普通文件 `kebab-case` | naming |
| 禁止 `temp`、`data2`、`newList` 等弱语义命名 | naming |
| 组合函数 `useXxx`，事件处理 `onXxx` | naming |
| Token 语义命名，禁止业务名/页面名 | naming |

### Git 工作流

| 规则摘要 | 来源 |
|----------|------|
| 分支名：`feature/` `fix/` `release/` `hotfix/` + kebab-case | git-workflow |
| 提交消息：Conventional Commits `type(scope): description` | git-workflow |
| feature/fix → main 用 Squash Merge，release → main 用 Merge Commit | git-workflow |
| 版本号遵循 SemVer，仅从 main 打 Tag | git-workflow |
| main 分支必须开启保护：CI 通过 + 1 人 Approve + 禁 Force Push | git-workflow |

### 工具链与 CI

| 规则摘要 | 来源 |
|----------|------|
| 必须提供 `lint`、`typecheck`、`test`、`build` 四个脚本 | tooling |
| lint/typecheck/test 任一失败阻断合并 | tooling |
| 构建产物必须自动移除 console.log/debugger/注释 | tooling |
| 核心依赖必须符合 stack-baseline，禁止引入禁用依赖 | tooling |

### 测试

| 规则摘要 | 来源 |
|----------|------|
| 工具函数/composable/service 层必须有单元测试 | testing |
| 核心逻辑覆盖率 ≥ 80%，整体 ≥ 60%，增量 ≥ 80% | testing |
| 公共组件必须有 testing-library 测试，覆盖四态 | testing |
| 测试必须确定性，禁止依赖外部服务/系统时间/随机数 | testing |
| 外部 API 必须 Mock，被测模块自身禁止 Mock | testing |

### 安全

| 规则摘要 | 来源 |
|----------|------|
| 禁止 v-html 直接渲染用户输入，必须 DOMPurify 净化 | security |
| 禁止 eval / new Function / document.write | security |
| Token 存储：httpOnly Cookie > 内存，禁止 localStorage | security |
| 敏感信息显示必须脱敏（手机号/身份证/银行卡） | security |
| 代码禁止硬编码密钥，.env.local 必须 gitignore | security |
| CI 执行依赖漏洞扫描，Critical/High 阻断合并 | security |

### 环境配置

| 规则摘要 | 来源 |
|----------|------|
| .env.local 和 .env.*.local 必须 gitignore | env-config |
| 客户端变量必须使用 VITE_ 前缀（Vite）/ VUE_APP_ 前缀（Webpack） | env-config |
| 生产密钥禁止写入 .env，必须通过 CI Secrets 注入 | env-config |
| 各环境 API 地址通过 .env.{mode} 管理，禁止硬编码 | env-config |
| 新增环境变量必须同步更新 env.d.ts 和 .env.example | env-config |

### 性能

| 规则摘要 | 来源 |
|----------|------|
| LCP ≤ 2.5s, FID ≤ 100ms, CLS ≤ 0.1 | performance |
| 单个路由 chunk ≤ 200KB (gzip)，超出必须拆分 | performance |
| 路由级组件必须懒加载，图片必须懒加载 | performance |
| 大列表（100+ 项）必须虚拟滚动或分页 | performance |
| 高频事件必须防抖/节流 | performance |
| 组件卸载必须清理所有副作用 | performance |
| 接口请求必须设超时，页面切换取消未完成请求 | performance |

### 组件化

| 规则摘要 | 来源 |
|----------|------|
| 基础组件不含业务请求，页面组件不被跨页面复用 | componentization |
| 组件输入通过 props，输出通过事件，禁止隐式依赖全局变量 | componentization |
| 公共组件必须覆盖空态/加载态/异常态 | componentization |
| 端特有能力必须通过适配层封装，禁止页面直调平台 API | componentization |

### 错误监控

| 规则摘要 | 来源 |
|----------|------|
| 必须注册全局错误捕获（Vue errorHandler / React ErrorBoundary / window.onerror） | error-monitoring |
| 必须接入统一错误监控平台，上报含 Source Map 映射 | error-monitoring |
| Source Map 禁止部署到生产 CDN | error-monitoring |
| 错误上报必须限流 + 聚合，避免告警风暴 | error-monitoring |

### 交付流程

| 规则摘要 | 来源 |
|----------|------|
| 标准流程：需求澄清 → 规则映射 → 实施 → 验证 → 归档 | workflow |
| .vue 文件超过 300 行必须拆分后再合并 | workflow |
| 删除文件/不可逆操作/生产配置变更前必须确认 | workflow |
| PR 必须包含变更说明、影响范围、回滚方案 | workflow |

---

## 常见问题

**Q：规则太多记不住怎么办？**
A：日常开发只需关注上面的速查卡。CI 会自动检查大部分 MUST 规则，不需要人工记忆。

**Q：CI 挂了怎么办？**
A：看报错信息对应哪条规则，修复后重新提交。如果确实无法满足，走例外申请流程。

**Q：规则和我的场景冲突怎么办？**
A：使用 `templates/exception-request-template.md` 提交例外申请，技术负责人审批。例外最长有效 3 个月。

**Q：我想参与规则维护怎么办？**
A：使用 `$frontend-rules-maintainer` Skill 提交规则变更 PR，MUST 规则变更需技术负责人审批。

**Q：模板在哪里找？**
A：所有模板索引在 `rules/templates/index.md`，按角色和场景分类。
