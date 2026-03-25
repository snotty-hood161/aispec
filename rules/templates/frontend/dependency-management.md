# 前端依赖管理模板

## 文档目标
1. 提供基于 `package.json` 的自动依赖检查脚本，用于 CI 流水线和本地校验。
2. 提供各应用类型的初始化脚手架依赖清单，用于新项目创建。
3. 依赖基线规则参见 `common/stack-baseline.md`。

---

## 一、自动依赖检查脚本

### 配置文件（`dependency-rules.json`）

放在项目根目录，定义允许和禁止的依赖规则：

```json
{
  "$schema": "依赖检查规则",
  "appType": "admin-console",
  "required": {
    "dependencies": {
      "vue": "^3",
      "element-plus": "*",
      "pinia": "*",
      "vue-router": "*",
      "axios": "*"
    },
    "devDependencies": {
      "typescript": "^5",
      "vite": "^5",
      "tailwindcss": "^3",
      "eslint": "*",
      "prettier": "*"
    }
  },
  "banned": [
    { "pattern": "@tarojs/*", "reason": "禁止引入 Taro 生态依赖" },
    { "pattern": "ant-design-vue", "reason": "UI 库已锁定为 Element Plus，禁止并存" },
    { "pattern": "vuex", "reason": "状态管理已锁定为 Pinia，禁止并存" },
    { "pattern": "moment", "reason": "已废弃，使用 dayjs 替代" },
    { "pattern": "lodash", "reason": "按需引入 lodash-es，禁止全量引入 lodash" }
  ],
  "sizeLimit": {
    "maxDependencies": 80,
    "warnDependencies": 60
  }
}
```

### uni-app 项目配置示例

```json
{
  "$schema": "依赖检查规则",
  "appType": "uni-app",
  "required": {
    "dependencies": {
      "vue": "^3",
      "pinia": "*",
      "uview-plus": "*"
    },
    "devDependencies": {
      "typescript": "^5",
      "unocss": "*"
    }
  },
  "banned": [
    { "pattern": "@tarojs/*", "reason": "禁止引入 Taro 生态依赖" },
    { "pattern": "axios", "reason": "uni-app 项目禁止使用 Axios，统一使用 uni.request 封装" },
    { "pattern": "element-plus", "reason": "uni-app 项目 UI 库为 uview-plus" },
    { "pattern": "moment", "reason": "已废弃，使用 dayjs 替代" },
    { "pattern": "lodash", "reason": "按需引入 lodash-es，禁止全量引入 lodash" }
  ],
  "sizeLimit": {
    "maxDependencies": 60,
    "warnDependencies": 40
  }
}
```

### 检查脚本（`scripts/check-dependencies.ts`）

```ts
// scripts/check-dependencies.ts
// 用法：npx ts-node scripts/check-dependencies.ts
// CI 中：在 lint 阶段执行，非零退出码阻断合并

import { readFileSync, existsSync } from 'fs'
import { resolve } from 'path'

/** 依赖规则类型 */
interface DependencyRules {
  appType: string
  required: {
    dependencies: Record<string, string>
    devDependencies: Record<string, string>
  }
  banned: Array<{ pattern: string; reason: string }>
  sizeLimit: {
    maxDependencies: number
    warnDependencies: number
  }
}

/** 错误收集 */
const errors: string[] = []
const warnings: string[] = []

/** 读取文件 */
function loadJson<T>(filePath: string): T {
  const fullPath = resolve(process.cwd(), filePath)
  if (!existsSync(fullPath)) {
    console.error(`文件不存在：${fullPath}`)
    process.exit(1)
  }
  return JSON.parse(readFileSync(fullPath, 'utf-8')) as T
}

/** 匹配禁止依赖（支持通配符） */
function matchBanned(depName: string, pattern: string): boolean {
  if (pattern.endsWith('/*')) {
    const prefix = pattern.slice(0, -2)
    return depName.startsWith(prefix)
  }
  return depName === pattern
}

function main(): void {
  const rules = loadJson<DependencyRules>('dependency-rules.json')
  const pkg = loadJson<{
    dependencies?: Record<string, string>
    devDependencies?: Record<string, string>
  }>('package.json')

  const allDeps = { ...pkg.dependencies, ...pkg.devDependencies }

  console.log(`\n检查项目依赖（应用类型：${rules.appType}）\n`)

  /** 1. 检查必需依赖 */
  console.log('--- 必需依赖检查 ---')
  for (const [dep, version] of Object.entries(rules.required.dependencies)) {
    if (!pkg.dependencies?.[dep]) {
      errors.push(`缺少必需依赖：${dep}（要求：${version}）`)
    }
  }
  for (const [dep, version] of Object.entries(rules.required.devDependencies)) {
    if (!pkg.devDependencies?.[dep]) {
      errors.push(`缺少必需开发依赖：${dep}（要求：${version}）`)
    }
  }

  /** 2. 检查禁止依赖 */
  console.log('--- 禁止依赖检查 ---')
  for (const depName of Object.keys(allDeps)) {
    for (const banned of rules.banned) {
      if (matchBanned(depName, banned.pattern)) {
        errors.push(`发现禁止依赖：${depName} — ${banned.reason}`)
      }
    }
  }

  /** 3. 检查依赖数量 */
  const totalDeps = Object.keys(allDeps).length
  console.log(`--- 依赖数量检查（当前：${totalDeps}）---`)
  if (totalDeps > rules.sizeLimit.maxDependencies) {
    errors.push(`依赖数量超限：${totalDeps} > ${rules.sizeLimit.maxDependencies}，请清理无用依赖`)
  } else if (totalDeps > rules.sizeLimit.warnDependencies) {
    warnings.push(`依赖数量偏多：${totalDeps} > ${rules.sizeLimit.warnDependencies}，建议清理`)
  }

  /** 4. 检查重复类库（同类并存） */
  console.log('--- 同类库并存检查 ---')
  const uiLibs = ['element-plus', 'ant-design-vue', 'naive-ui', 'uview-plus', 'vant'].filter((lib) => allDeps[lib])
  if (uiLibs.length > 1) {
    errors.push(`发现多套 UI 库并存：${uiLibs.join(', ')}`)
  }

  const stateLibs = ['pinia', 'vuex'].filter((lib) => allDeps[lib])
  if (stateLibs.length > 1) {
    errors.push(`发现多套状态管理库并存：${stateLibs.join(', ')}`)
  }

  /** 输出结果 */
  console.log('')
  if (warnings.length > 0) {
    console.warn('⚠️  告警：')
    warnings.forEach((w) => console.warn(`   ${w}`))
  }
  if (errors.length > 0) {
    console.error('❌ 错误：')
    errors.forEach((e) => console.error(`   ${e}`))
    console.error(`\n检查失败（${errors.length} 个错误）`)
    process.exit(1)
  }

  console.log('✅ 依赖检查通过')
}

main()
```

### CI 集成

```yaml
# .github/workflows/ci.yml 片段
- name: 依赖合规检查
  run: npx ts-node scripts/check-dependencies.ts
```

### package.json 脚本

```json
{
  "scripts": {
    "check:deps": "ts-node scripts/check-dependencies.ts"
  }
}
```

---

## 二、各应用初始化脚手架依赖清单

### 后台管理（admin-console）

```json
{
  "dependencies": {
    "vue": "^3.4",
    "vue-router": "^4",
    "pinia": "^2",
    "pinia-plugin-persistedstate": "^3",
    "element-plus": "^2",
    "axios": "^1",
    "@tiptap/vue-3": "^2",
    "@tiptap/starter-kit": "^2",
    "@tiptap/extension-underline": "^2",
    "@tiptap/extension-link": "^2",
    "@tiptap/extension-image": "^2",
    "@tiptap/extension-table": "^2",
    "@tiptap/extension-table-row": "^2",
    "@tiptap/extension-table-cell": "^2",
    "@tiptap/extension-table-header": "^2",
    "@tiptap/extension-placeholder": "^2",
    "@tiptap/extension-character-count": "^2",
    "echarts": "^5",
    "dayjs": "^1",
    "sanitize-html": "^2"
  },
  "devDependencies": {
    "typescript": "^5",
    "vite": "^5",
    "tailwindcss": "^3",
    "postcss": "^8",
    "autoprefixer": "^10",
    "eslint": "^9",
    "prettier": "^3",
    "typescript-eslint": "^7",
    "eslint-plugin-vue": "^9",
    "eslint-plugin-import": "^2",
    "@types/sanitize-html": "^2",
    "vitest": "^1",
    "@vue/test-utils": "^2"
  }
}
```

### uni-app 应用（H5 + 小程序通用）

```json
{
  "dependencies": {
    "vue": "^3.4",
    "pinia": "^2",
    "pinia-plugin-persistedstate": "^3",
    "uview-plus": "^3",
    "dayjs": "^1"
  },
  "devDependencies": {
    "typescript": "^5",
    "unocss": "^0.58",
    "@dcloudio/uni-app": "latest",
    "@dcloudio/uni-h5": "latest",
    "@dcloudio/uni-mp-weixin": "latest",
    "@dcloudio/vite-plugin-uni": "latest",
    "eslint": "^9",
    "prettier": "^3",
    "typescript-eslint": "^7",
    "eslint-plugin-vue": "^9",
    "vitest": "^1"
  }
}
```

### uni-app 应用（仅 H5，额外依赖）

```json
{
  "dependencies_extra": {
    "weixin-js-sdk": "^1.6"
  }
}
```

### uni-app 应用（仅小程序，额外依赖）

```json
{
  "dependencies_extra": {
    "ucharts": "^2"
  }
}
```

---

## 三、新项目初始化步骤

### 后台管理

```bash
# 1. 创建 Vite 项目
npm create vite@latest my-admin -- --template vue-ts

# 2. 安装基线依赖（复制上方 admin-console 清单）
cd my-admin
npm install vue-router pinia pinia-plugin-persistedstate element-plus axios echarts dayjs sanitize-html
npm install -D tailwindcss postcss autoprefixer eslint prettier typescript-eslint eslint-plugin-vue vitest @vue/test-utils

# 3. 复制配置文件
# - .prettierrc          ← 从 eslint-prettier-baseline.md 复制
# - eslint.config.js     ← 从 eslint-prettier-baseline.md 复制 Vue 版本
# - tailwind.config.ts   ← 从 tailwind-element-plus.md 复制
# - dependency-rules.json ← 从本模板复制 admin-console 版本

# 4. 初始化目录结构
# 参见 project-structure/admin-console.md
```

### uni-app

```bash
# 1. 通过 HBuilderX 或 CLI 创建 uni-app 项目（Vue3 + TypeScript）
npx degit dcloudio/uni-preset-vue#vite-ts my-uniapp

# 2. 安装基线依赖（复制上方 uni-app 清单）
cd my-uniapp
npm install pinia pinia-plugin-persistedstate uview-plus dayjs
npm install -D unocss eslint prettier typescript-eslint eslint-plugin-vue vitest

# 3. 复制配置文件
# - .prettierrc          ← 从 eslint-prettier-baseline.md 复制
# - eslint.config.js     ← 从 eslint-prettier-baseline.md 复制 Vue 版本
# - dependency-rules.json ← 从本模板复制 uni-app 版本

# 4. 复制请求封装
# - services/request/    ← 从 uni-request-wrapper.md 复制

# 5. 初始化目录结构
# 参见 project-structure/wechat-h5.md 或 project-structure/miniprogram.md
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 每个项目根目录必须包含 `dependency-rules.json`，声明应用类型和依赖规则 |
| 2 | MUST | CI 流水线必须执行依赖检查脚本，检查不通过阻断合并 |
| 3 | MUST | 新项目初始化必须按本清单安装依赖，禁止自行选型替代 |
| 4 | MUST | 新增依赖必须在 PR 中说明必要性，禁止无说明引入 |
| 5 | SHOULD | 定期（每月）执行 `npm outdated` 检查过期依赖，安全补丁及时升级 |
| 6 | SHOULD | 使用 `npm audit` 检查已知漏洞，高危漏洞 48 小时内修复 |

检查方式：CI 脚本自动检查 + 人工审查
阻断级别：MUST 条款阻断合并
