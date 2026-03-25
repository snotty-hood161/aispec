# rules/frontend/common/env-config.md

## 文档目标
1. 统一前端项目的环境配置管理策略。
2. 覆盖 .env 文件规范、多环境隔离、运行时配置、Feature Flag 四个层面。

## .env 文件规范（MUST）
1. 文件命名遵循框架约定：

| 文件 | 用途 | 是否提交仓库 |
|------|------|-------------|
| `.env` | 所有环境共用的默认值 | ✅ 提交 |
| `.env.local` | 本地覆盖（开发者个人配置） | ❌ gitignore |
| `.env.development` | 开发环境 | ✅ 提交 |
| `.env.staging` | 预发布环境 | ✅ 提交 |
| `.env.production` | 生产环境（非敏感配置） | ✅ 提交 |
| `.env.*.local` | 各环境的本地覆盖 | ❌ gitignore |

2. 加载优先级（Vite 项目）：`.env.{mode}.local` > `.env.{mode}` > `.env.local` > `.env`。
3. `.env.local` 和 `.env.*.local` 必须加入 `.gitignore`。
4. 仓库中必须维护 `.env.example`，列出所有变量名及用途说明（值留空或填示例值）。
检查方式：.gitignore 审查 + .env.example 存在性检查
阻断级别：阻断合并

## 变量前缀（MUST）
1. Vite 项目：客户端可见变量必须以 `VITE_` 前缀。
2. Webpack/Vue CLI 项目：客户端可见变量必须以 `VUE_APP_` 前缀。
3. 非前缀变量仅在构建脚本中可用，不会注入到客户端代码。
4. 禁止将服务端密钥以客户端前缀暴露。
检查方式：人工审查
阻断级别：阻断合并

## 敏感配置隔离（MUST）
1. 生产环境密钥（API Secret、数据库连接串、第三方 Secret Key）禁止写入任何 `.env` 文件。
2. 生产密钥必须通过以下方式注入：
   - CI/CD Secrets（GitHub Actions Secrets、GitLab CI Variables）。
   - 运行时密钥管理服务（如 Vault、AWS Secrets Manager）。
3. CI/CD 日志中禁止打印环境变量值（使用 `***` 遮蔽）。
4. 前端代码中禁止 `console.log(import.meta.env)` 或 `console.log(process.env)` 输出全部环境变量。
检查方式：人工审查 + secretlint 扫描
阻断级别：阻断合并

## 多环境隔离（MUST）
1. 每个环境必须使用独立的 API 地址，禁止硬编码：

```ts
// ✅ 正确：从环境变量读取
const API_BASE = import.meta.env.VITE_API_BASE_URL

// ❌ 错误：硬编码地址
const API_BASE = 'https://api.example.com'
```

2. 环境标识变量 `VITE_APP_ENV` 必须在每个 `.env.{mode}` 中明确设置。
3. 各环境差异项（API 地址、CDN 域名、第三方 AppID）必须全部通过 `.env.{mode}` 管理。
4. 禁止在代码中通过 `if (location.hostname === 'xxx')` 判断环境。
检查方式：静态扫描 + 人工审查
阻断级别：阻断合并

## 构建时配置 vs 运行时配置（SHOULD）
1. **构建时配置**（通过 `.env` 注入，构建后不可变）：
   - 环境标识（`VITE_APP_ENV`）。
   - API Base URL。
   - Feature Flag 初始值。
   - 第三方 SDK AppID。
2. **运行时配置**（构建后仍可变，适用于需要动态切换的场景）：
   - 通过 `/config.json` 静态文件加载（放在 `public/` 目录，不参与构建 hash）。
   - 或通过接口动态下发。
3. 运行时配置文件不参与构建产物 hash，部署时可独立替换。

```ts
// src/config/runtime.ts
// 运行时配置加载（构建后可独立修改）

interface RuntimeConfig {
  /** API 地址（可被运维动态替换） */
  apiBaseUrl: string
  /** 功能开关 */
  features: Record<string, boolean>
}

let config: RuntimeConfig | null = null

/** 加载运行时配置（应用初始化时调用一次） */
export async function loadRuntimeConfig(): Promise<RuntimeConfig> {
  if (config) return config
  const res = await fetch('/config.json')
  config = await res.json()
  return config!
}

export function getRuntimeConfig(): RuntimeConfig {
  if (!config) throw new Error('运行时配置未加载，请先调用 loadRuntimeConfig()')
  return config
}
```

检查方式：人工审查
阻断级别：告警记录

## Feature Flag 管理（SHOULD）
1. 统一使用环境变量或远程配置中心管理 Feature Flag。
2. 命名格式：`VITE_FEATURE_{MODULE}_{CAPABILITY}`（全大写，下划线分隔）。

```bash
# .env.development
VITE_FEATURE_ORDER_EXPORT=true
VITE_FEATURE_USER_DARK_MODE=false
```

3. 代码中统一通过封装函数读取，禁止散落的 `import.meta.env.VITE_FEATURE_XXX` 判断：

```ts
// src/config/features.ts
// Feature Flag 统一入口

export const Features = {
  /** 订单导出功能 */
  ORDER_EXPORT: import.meta.env.VITE_FEATURE_ORDER_EXPORT === 'true',
  /** 暗色模式 */
  USER_DARK_MODE: import.meta.env.VITE_FEATURE_USER_DARK_MODE === 'true',
} as const
```

4. 每个新增 Feature Flag 必须附**回收计划**：功能上线稳定后删除 Flag，直接启用。
5. 超过 **3 个月**未回收的 Flag 在季度审查中强制清理。
检查方式：人工审查
阻断级别：告警记录

## TypeScript 类型安全（MUST）
1. Vite 项目必须在 `env.d.ts` 中声明环境变量类型：

```ts
// env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** API 基础地址 */
  readonly VITE_API_BASE_URL: string
  /** 微信公众号 AppID */
  readonly VITE_WECHAT_APP_ID: string
  /** 环境标识 */
  readonly VITE_APP_ENV: 'development' | 'staging' | 'production'
  /** Sentry DSN */
  readonly VITE_SENTRY_DSN: string
  /** Feature Flag：订单导出 */
  readonly VITE_FEATURE_ORDER_EXPORT: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

2. 新增环境变量时必须同步更新 `env.d.ts` 和 `.env.example`。
检查方式：typecheck
阻断级别：阻断合并

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | `.env.local` 和 `.env.*.local` 必须 gitignore |
| 2 | MUST | 仓库中必须维护 `.env.example` |
| 3 | MUST | 客户端变量必须使用框架指定前缀（`VITE_` / `VUE_APP_`） |
| 4 | MUST | 生产密钥禁止写入 `.env` 文件，必须通过 CI Secrets 注入 |
| 5 | MUST | 各环境 API 地址通过 `.env.{mode}` 管理，禁止硬编码 |
| 6 | MUST | 新增环境变量必须同步更新 `env.d.ts` 和 `.env.example` |
| 7 | SHOULD | 需要动态切换的配置使用运行时配置（`/config.json`） |
| 8 | SHOULD | Feature Flag 统一封装，附回收计划，超 3 个月未回收需清理 |

检查方式：typecheck + .gitignore 审查 + 人工审查
阻断级别：MUST 条款阻断合并
