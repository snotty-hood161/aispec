# 命名规范工具包模板

## 文档目标
1. 提供文件重命名迁移脚本和 Token 命名冲突检查脚本，支撑命名规范自动化治理。
2. 命名规则参见 `common/naming.md`。

## 使用方式
- **谁用**：前端开发者、技术负责人。
- **何时用**：项目命名治理、Token 新增审查、文件迁移重构时。
- **怎么用**：将脚本复制到 `scripts/` 目录，按需执行或集成到 CI。

---

## 一、文件重命名与迁移脚本

### 1.1 功能说明
- 扫描 `src/` 下所有文件和目录，检查是否符合 `kebab-case` 命名规范
- 检测中文、空格、驼峰命名的文件/目录
- 输出不合规列表及建议的规范名称
- 支持 `--fix` 模式自动重命名（需确认）

### 1.2 脚本（`scripts/check-file-naming.ts`）

```ts
// scripts/check-file-naming.ts
// 用法：npx ts-node scripts/check-file-naming.ts [--fix]
// 扫描文件和目录命名是否符合 kebab-case 规范

import { readdirSync, statSync, renameSync } from 'fs'
import { resolve, basename, dirname, extname, join } from 'path'

/** 是否自动修复 */
const FIX_MODE = process.argv.includes('--fix')

/** 跳过的目录 */
const SKIP_DIRS = new Set(['node_modules', 'dist', '.git', '.husky', '.vscode', '.idea'])

/** 允许的特殊文件名（不做检查） */
const ALLOWED_NAMES = new Set([
  'App.vue', 'main.ts', 'main.js', 'env.d.ts', 'shims-vue.d.ts',
  'vite-env.d.ts', 'README.md', 'CHANGELOG.md', 'LICENSE',
  '.env', '.env.local', '.env.development', '.env.production',
  '.gitignore', '.eslintrc.js', '.eslintrc.cjs', '.prettierrc',
  'tsconfig.json', 'package.json', 'vite.config.ts', 'uno.config.ts',
  'tailwind.config.ts', 'tailwind.config.js', 'postcss.config.js',
  'manifest.json', 'pages.json',
])

/** PascalCase 组件文件（.vue）允许 PascalCase */
const isVueComponent = (name: string): boolean => extname(name) === '.vue'

/** kebab-case 正则 */
const KEBAB_CASE_REGEX = /^[a-z][a-z0-9]*(-[a-z0-9]+)*$/

/** PascalCase 正则（组件文件允许） */
const PASCAL_CASE_REGEX = /^[A-Z][a-zA-Z0-9]*$/

/** 检测中文字符 */
const CHINESE_REGEX = /[\u4e00-\u9fff]/

/** 检测空格 */
const SPACE_REGEX = /\s/

interface NamingIssue {
  path: string
  name: string
  type: 'directory' | 'file'
  problem: string
  suggestion: string
}

const issues: NamingIssue[] = []

/** PascalCase → kebab-case */
function toKebabCase(str: string): string {
  return str
    .replace(/([A-Z])/g, '-$1')
    .toLowerCase()
    .replace(/^-/, '')
    .replace(/--+/g, '-')
}

/** 检查名称是否合规 */
function checkName(fullPath: string, name: string, isDir: boolean): void {
  const nameWithoutExt = isDir ? name : name.replace(extname(name), '')
  const ext = isDir ? '' : extname(name)

  /** 特殊文件跳过 */
  if (ALLOWED_NAMES.has(name)) return

  /** 以 . 开头的配置文件跳过 */
  if (name.startsWith('.')) return

  /** 组件文件允许 PascalCase */
  if (isVueComponent(name) && PASCAL_CASE_REGEX.test(nameWithoutExt)) return

  /** .d.ts 文件跳过 */
  if (name.endsWith('.d.ts')) return

  /** 检查中文 */
  if (CHINESE_REGEX.test(name)) {
    issues.push({
      path: fullPath,
      name,
      type: isDir ? 'directory' : 'file',
      problem: '包含中文字符',
      suggestion: '请手动重命名为英文 kebab-case',
    })
    return
  }

  /** 检查空格 */
  if (SPACE_REGEX.test(name)) {
    const suggestion = name.replace(/\s+/g, '-').toLowerCase()
    issues.push({
      path: fullPath,
      name,
      type: isDir ? 'directory' : 'file',
      problem: '包含空格',
      suggestion: isDir ? suggestion : suggestion.replace(extname(name), '') + ext,
    })
    return
  }

  /** 目录必须 kebab-case */
  if (isDir && !KEBAB_CASE_REGEX.test(name)) {
    issues.push({
      path: fullPath,
      name,
      type: 'directory',
      problem: '不符合 kebab-case',
      suggestion: toKebabCase(name),
    })
    return
  }

  /** 文件（非 .vue 组件）必须 kebab-case */
  if (!isDir && !isVueComponent(name) && !KEBAB_CASE_REGEX.test(nameWithoutExt)) {
    issues.push({
      path: fullPath,
      name,
      type: 'file',
      problem: '不符合 kebab-case',
      suggestion: toKebabCase(nameWithoutExt) + ext,
    })
  }
}

/** 递归扫描 */
function scanDir(dir: string): void {
  for (const entry of readdirSync(dir)) {
    if (SKIP_DIRS.has(entry)) continue

    const fullPath = resolve(dir, entry)
    const stat = statSync(fullPath)

    checkName(fullPath, entry, stat.isDirectory())

    if (stat.isDirectory()) {
      scanDir(fullPath)
    }
  }
}

function main(): void {
  console.log('检查文件/目录命名规范...\n')

  const srcDir = resolve(process.cwd(), 'src')
  try {
    statSync(srcDir)
    scanDir(srcDir)
  } catch {
    console.error('src 目录不存在')
    process.exit(1)
  }

  if (issues.length === 0) {
    console.log('✅ 所有文件和目录命名均符合规范')
    return
  }

  console.log(`发现 ${issues.length} 处命名不合规：\n`)

  issues.forEach((issue, index) => {
    console.log(`${index + 1}. [${issue.type}] ${issue.name}`)
    console.log(`   路径：${issue.path}`)
    console.log(`   问题：${issue.problem}`)
    console.log(`   建议：${issue.suggestion}`)
    console.log('')
  })

  if (FIX_MODE) {
    console.log('--- 自动修复模式 ---\n')
    let fixed = 0
    /** 从深层开始重命名，避免路径失效 */
    const sorted = [...issues]
      .filter((i) => i.suggestion !== '请手动重命名为英文 kebab-case')
      .sort((a, b) => b.path.length - a.path.length)

    for (const issue of sorted) {
      const dir = dirname(issue.path)
      const newPath = join(dir, issue.suggestion)
      try {
        renameSync(issue.path, newPath)
        console.log(`  ✓ ${issue.name} → ${issue.suggestion}`)
        fixed++
      } catch (err) {
        console.error(`  ✗ ${issue.name} → ${issue.suggestion}（失败：${err}）`)
      }
    }
    console.log(`\n修复完成：${fixed}/${sorted.length}`)
    console.log('⚠️  请手动更新相关 import 路径！')
  } else {
    console.log('提示：添加 --fix 参数可自动重命名（请先提交当前变更）')
  }
}

main()
```

### 1.3 重命名后的 import 路径更新建议

```
自动重命名后需要处理的引用：
1. import/require 语句中的路径
2. 路由配置中的组件路径
3. pages.json / app.json 中的页面路径
4. CSS 中的 @import 路径

建议流程：
1. 先 git commit 当前代码
2. 执行 --fix 自动重命名
3. 全局搜索替换旧文件名
4. 执行 lint + typecheck 确认无遗漏
5. 手动验证关键页面
```

---

## 二、Token 命名冲突检查脚本

### 2.1 功能说明
- 扫描项目中所有 Token 定义文件（CSS 变量文件、UnoCSS/Tailwind 主题配置）
- 检测重复定义的 Token
- 检测不符合语义命名规范的 Token（如包含业务名、页面名）
- 检测命名冲突（值相同但名不同 → 建议合并）
- 输出 Token 字典清单

### 2.2 脚本（`scripts/check-token-naming.ts`）

```ts
// scripts/check-token-naming.ts
// 用法：npx ts-node scripts/check-token-naming.ts
// 扫描项目 Token 定义，检查命名规范和冲突

import { readFileSync, readdirSync, statSync } from 'fs'
import { resolve, extname, relative } from 'path'

/** Token 定义来源 */
interface TokenEntry {
  name: string
  value: string
  file: string
  line: number
}

/** 检查结果 */
interface TokenIssue {
  type: 'duplicate' | 'bad_naming' | 'mergeable'
  detail: string
  entries: TokenEntry[]
}

const allTokens: TokenEntry[] = []
const issues: TokenIssue[] = []

/** CSS 变量定义正则 */
const CSS_VAR_REGEX = /--([a-zA-Z][\w-]*)\s*:\s*([^;]+);/g

/** 不合规命名模式（包含业务名、页面名） */
const BAD_NAMING_PATTERNS = [
  /^--(?:order|user|product|cart|pay|login|home|detail|list|setting|profile)-/,
  /^--page-/,
  /^--view-/,
  /\d{2,}/, // 包含多位数字
]

/** 合规的语义前缀 */
const VALID_PREFIXES = [
  'color', 'text', 'bg', 'border', 'space', 'spacing',
  'radius', 'font', 'shadow', 'z', 'opacity', 'size',
  'line', 'weight', 'width', 'height', 'gap', 'margin', 'padding',
]

/** 扫描文件 */
function scanFile(filePath: string): void {
  const content = readFileSync(filePath, 'utf-8')
  const lines = content.split('\n')
  const relPath = relative(process.cwd(), filePath)

  lines.forEach((line, index) => {
    const matches = line.matchAll(CSS_VAR_REGEX)
    for (const match of matches) {
      allTokens.push({
        name: `--${match[1]}`,
        value: match[2].trim(),
        file: relPath,
        line: index + 1,
      })
    }
  })
}

/** 递归扫描目录 */
function scanDir(dir: string): void {
  let entries: string[]
  try {
    entries = readdirSync(dir)
  } catch {
    return
  }

  for (const entry of entries) {
    if (['node_modules', 'dist', '.git'].includes(entry)) continue

    const fullPath = resolve(dir, entry)
    const stat = statSync(fullPath)

    if (stat.isDirectory()) {
      scanDir(fullPath)
    } else {
      const ext = extname(entry)
      /** 扫描 CSS、SCSS、变量文件 */
      if (['.css', '.scss', '.less'].includes(ext)) {
        scanFile(fullPath)
      }
      /** 扫描 Vue 文件中的 style 块 */
      if (ext === '.vue') {
        scanFile(fullPath)
      }
    }
  }
}

function analyze(): void {
  /** 1. 检查重复定义 */
  const nameMap = new Map<string, TokenEntry[]>()
  allTokens.forEach((token) => {
    const list = nameMap.get(token.name) || []
    list.push(token)
    nameMap.set(token.name, list)
  })

  for (const [name, entries] of nameMap) {
    if (entries.length > 1) {
      /** 检查值是否一致 */
      const values = new Set(entries.map((e) => e.value))
      if (values.size > 1) {
        issues.push({
          type: 'duplicate',
          detail: `Token "${name}" 在 ${entries.length} 处定义且值不一致`,
          entries,
        })
      }
    }
  }

  /** 2. 检查命名规范 */
  const uniqueNames = [...new Set(allTokens.map((t) => t.name))]
  for (const name of uniqueNames) {
    for (const pattern of BAD_NAMING_PATTERNS) {
      if (pattern.test(name)) {
        const entry = allTokens.find((t) => t.name === name)!
        issues.push({
          type: 'bad_naming',
          detail: `Token "${name}" 包含业务/页面命名，应使用语义命名`,
          entries: [entry],
        })
        break
      }
    }
  }

  /** 3. 检查可合并项（值相同名不同） */
  const valueMap = new Map<string, TokenEntry[]>()
  allTokens.forEach((token) => {
    const list = valueMap.get(token.value) || []
    list.push(token)
    valueMap.set(token.value, list)
  })

  for (const [value, entries] of valueMap) {
    const uniqueTokenNames = [...new Set(entries.map((e) => e.name))]
    if (uniqueTokenNames.length > 1) {
      issues.push({
        type: 'mergeable',
        detail: `值 "${value}" 被 ${uniqueTokenNames.length} 个不同 Token 使用，建议合并`,
        entries,
      })
    }
  }
}

function main(): void {
  console.log('检查 Token 命名规范...\n')

  scanDir(resolve(process.cwd(), 'src'))

  if (allTokens.length === 0) {
    console.log('未发现 CSS 变量定义')
    return
  }

  analyze()

  /** 输出 Token 字典 */
  const uniqueTokens = new Map<string, TokenEntry>()
  allTokens.forEach((t) => {
    if (!uniqueTokens.has(t.name)) {
      uniqueTokens.set(t.name, t)
    }
  })

  console.log(`Token 字典（共 ${uniqueTokens.size} 个）：`)
  const sorted = [...uniqueTokens.values()].sort((a, b) => a.name.localeCompare(b.name))
  sorted.forEach((t) => {
    console.log(`  ${t.name}: ${t.value}  (${t.file}:${t.line})`)
  })
  console.log('')

  if (issues.length === 0) {
    console.log('✅ Token 命名检查通过')
    return
  }

  /** 按类型输出 */
  const duplicates = issues.filter((i) => i.type === 'duplicate')
  const badNaming = issues.filter((i) => i.type === 'bad_naming')
  const mergeable = issues.filter((i) => i.type === 'mergeable')

  if (duplicates.length > 0) {
    console.error(`❌ 重复定义（值不一致）：${duplicates.length} 个`)
    duplicates.forEach((i) => {
      console.error(`   ${i.detail}`)
      i.entries.forEach((e) => {
        console.error(`     ${e.file}:${e.line} → ${e.value}`)
      })
    })
    console.error('')
  }

  if (badNaming.length > 0) {
    console.warn(`⚠️  命名不规范：${badNaming.length} 个`)
    badNaming.forEach((i) => {
      console.warn(`   ${i.detail}`)
    })
    console.warn('')
  }

  if (mergeable.length > 0) {
    console.warn(`⚠️  建议合并（值相同名不同）：${mergeable.length} 组`)
    mergeable.forEach((i) => {
      const names = [...new Set(i.entries.map((e) => e.name))].join(', ')
      console.warn(`   ${i.detail}：${names}`)
    })
    console.warn('')
  }

  console.log(`检查完成：${duplicates.length} 冲突，${badNaming.length} 命名不规范，${mergeable.length} 可合并`)

  if (duplicates.length > 0) {
    process.exit(1)
  }
}

main()
```

### 2.3 package.json 脚本

```json
{
  "scripts": {
    "check:file-naming": "ts-node scripts/check-file-naming.ts",
    "check:token-naming": "ts-node scripts/check-token-naming.ts"
  }
}
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 目录和普通文件使用 `kebab-case` 命名 |
| 2 | MUST | 文件名禁止中文、空格、无语义缩写 |
| 3 | MUST | Token 使用语义命名，禁止业务名/页面名 |
| 4 | MUST | 重复定义的 Token（值不一致）必须统一后再合并 |
| 5 | SHOULD | 重构前执行文件命名检查脚本，量化不合规文件 |
| 6 | SHOULD | Token 新增前执行冲突检查，避免重复定义 |

检查方式：脚本检查 + 人工审查
阻断级别：MUST 条款阻断合并
