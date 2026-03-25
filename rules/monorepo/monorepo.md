# Monorepo 工程规范

## Skill 协作
1. 涉及 Monorepo 工程管理时，各域 coding-guide 自动加载本规则。
2. DevOps 任务使用 `$devops-engineer`，关注 CI/CD 的 Monorepo 优化。
3. 跨域业务任务使用 `$task-router` 自动路由。

## 适用范围
1. 单仓库多项目/多服务/多包的工程组织模式。
2. 本规范不强制使用 Monorepo；当项目满足以下条件之一时推荐采用：
   - 多个服务/应用共享大量代码（> 30% 共用代码）。
   - 前后端同仓、需要原子提交保证契约一致性。
   - 团队规模 ≤ 20 人，单仓管理成本可控。

## 工具选型（MUST）

| 场景 | 推荐工具 | 备选 | 不推荐 |
|------|---------|------|--------|
| JavaScript/TypeScript 生态 | Turborepo | Nx、Lerna | 手动 npm workspace |
| Go 生态 | Go workspace（go.work） | — | vendor 拷贝 |
| .NET 生态 | Directory.Build.props + sln | — | 独立 sln 拼接 |
| Java 生态 | Gradle composite build / Maven multi-module | Bazel | 独立 pom 拼接 |
| Python 生态 | uv workspace / PDM workspace | Poetry workspace | 手动 pip 路径 |
| 通用多语言 | Nx（polyglot 支持） | Bazel | 纯 shell 脚本 |

## 目录结构（MUST）

### 标准 Monorepo 目录结构

```
monorepo-root/
├── apps/                         ← 可部署的应用
│   ├── api-server/               ← 后端服务
│   ├── web-admin/                ← 前端管理后台
│   ├── mobile-app/               ← 移动端应用
│   └── desktop-app/              ← 桌面端应用
├── packages/                     ← 共享包/库
│   ├── shared-types/             ← 跨端类型定义
│   ├── shared-utils/             ← 通用工具函数
│   ├── ui-components/            ← 共享 UI 组件
│   └── api-client/               ← API 客户端 SDK
├── tools/                        ← 工程工具和脚本
│   ├── scripts/                  ← CI/CD 脚本
│   └── generators/               ← 代码生成器
├── docs/                         ← 项目文档
├── .github/                      ← CI/CD 配置
├── turbo.json / nx.json          ← Monorepo 工具配置
├── package.json / go.work / sln  ← 工作区根配置
└── README.md
```

### 命名规范（MUST）
1. `apps/` 下的项目用途清晰命名：`api-server`、`web-admin`、`mobile-app`。
2. `packages/` 下的共享包用 `shared-` 前缀或用途命名：`shared-types`、`ui-components`。
3. 包名使用 scope：`@myproject/shared-types`、`@myproject/ui-components`。

## 依赖管理（MUST）

### 依赖提升策略
1. 共享依赖提升到工作区根目录（Turborepo/Nx 默认行为）。
2. 应用特有的依赖保留在应用目录。
3. 版本锁定文件（lockfile）必须提交到版本库。
4. 禁止应用间直接引用其他应用的代码，只能通过 `packages/` 中的共享包。

### 共享包规范
1. 每个共享包必须有独立的 `package.json`（或语言对应的包描述文件）。
2. 共享包必须定义清晰的公开 API（`exports` / `main`）。
3. 共享包的版本变更遵循 SemVer。
4. 共享包必须有独立的测试覆盖。

## 构建与缓存（MUST）

### 构建管道
1. 定义清晰的任务依赖图（`turbo.json` 的 `pipeline` 或 `nx.json` 的 `targetDefaults`）。
2. 构建顺序：共享包先于应用构建（`packages/*` → `apps/*`）。
3. 支持增量构建：只构建受变更影响的包。

### 缓存策略
1. 启用本地构建缓存（Turborepo/Nx 内置）。
2. CI 中启用远程缓存（Vercel Remote Cache / Nx Cloud）降低构建时间。
3. 缓存 key 包含：源文件 hash + 依赖版本 + 环境变量。

### 构建配置示例（Turborepo）

```json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["build"]
    },
    "lint": {},
    "type-check": {}
  }
}
```

## CI/CD 优化（MUST）

### 变更检测
1. CI 中必须使用变更检测，只运行受影响的任务。
2. Turborepo: `turbo run build --filter=...[HEAD~1]`
3. Nx: `nx affected --target=build`
4. 共享包变更时，所有依赖它的应用都必须重新构建和测试。

### 并行策略
1. 无依赖的任务并行执行（lint、type-check 可并行）。
2. 有依赖的任务串行执行（共享包 build → 应用 build）。
3. CI 超时时间根据 Monorepo 规模调整（单应用 ×1.5）。

### 发布策略
1. 各应用独立发布，独立版本号。
2. 共享包变更触发依赖应用的 CI 检查。
3. 使用 Changesets 或 Lerna 管理共享包版本发布。

## 代码所有权（SHOULD）

### CODEOWNERS
1. 使用 `.github/CODEOWNERS` 定义代码所有权。
2. 每个 `apps/` 和 `packages/` 目录指定负责团队。
3. 共享包变更需要对应负责人审查。

```
# .github/CODEOWNERS
apps/api-server/     @backend-team
apps/web-admin/      @frontend-team
apps/mobile-app/     @mobile-team
packages/shared-*/   @platform-team
packages/ui-*/       @frontend-team
```

## Git 规范（MUST）

### 提交消息
1. 提交消息必须标注受影响的范围：`feat(api-server): add user API`。
2. 范围使用 `apps/` 或 `packages/` 下的目录名。
3. 跨多个范围的提交使用 `*` 或列出主要范围。

### 分支策略
1. 与单仓项目一致（main + develop + feature/* + hotfix/*）。
2. PR 标题标注受影响的应用/包。
3. PR 描述中列出受变更影响的依赖链。

## 常见反模式（禁止）

| 反模式 | 问题 | 正确做法 |
|--------|------|---------|
| 应用间直接 import | 耦合严重，构建依赖不可控 | 通过 `packages/` 共享 |
| 全量构建 | CI 时间失控 | 增量构建 + 变更检测 |
| 共享包无测试 | 变更影响面不可控 | 共享包独立测试 |
| 根目录堆积配置 | 职责不清 | 配置就近原则 + 继承 |
| 忽略 lockfile | 依赖版本不确定 | lockfile 必须提交 |
| 手动同步版本 | 人工易出错 | 使用 Changesets 自动管理 |
