# 小程序 CI 检查脚本模板

## 文档目标
1. 提供小程序主包体积校验和资源格式检查脚本，用于 CI 阻断不合规构建。
2. 工具链规则参见 `common/tooling.md`。

## 使用方式
- **谁用**：uni-app 小程序项目开发者、CI 流水线。
- **何时用**：每次构建小程序后在 CI 中执行，阻断不合规产物。
- **怎么用**：将脚本复制到 `scripts/` 目录，在 `package.json` 中配置脚本命令，CI 中调用。

---

## 一、主包体积校验脚本

### 1.1 功能说明
- 扫描小程序构建产物目录，计算主包体积
- 主包超过 **2MB** 输出 **错误** 并阻断 CI
- 主包超过 **1.5MB** 输出 **警告**（提前预警）
- 输出各分包体积汇总

### 1.2 脚本（`scripts/check-mp-size.ts`）

```ts
// scripts/check-mp-size.ts
// 用法：npx ts-node scripts/check-mp-size.ts [构建产物目录]
// 默认扫描 dist/build/mp-weixin

import { readdirSync, statSync } from 'fs'
import { resolve, relative } from 'path'

/** 体积阈值（字节） */
const WARN_THRESHOLD = 1.5 * 1024 * 1024 // 1.5MB
const ERROR_THRESHOLD = 2 * 1024 * 1024 // 2MB

/** 构建产物目录 */
const OUTPUT_DIR = process.argv[2] || 'dist/build/mp-weixin'

/** 递归计算目录体积 */
function getDirSize(dir: string): number {
  let total = 0

  for (const entry of readdirSync(dir)) {
    const fullPath = resolve(dir, entry)
    const stat = statSync(fullPath)

    if (stat.isDirectory()) {
      total += getDirSize(fullPath)
    } else {
      total += stat.size
    }
  }

  return total
}

/** 格式化体积 */
function formatSize(bytes: number): string {
  if (bytes >= 1024 * 1024) {
    return `${(bytes / 1024 / 1024).toFixed(2)} MB`
  }
  return `${(bytes / 1024).toFixed(1)} KB`
}

interface PackageInfo {
  name: string
  path: string
  size: number
}

function main(): void {
  const rootDir = resolve(process.cwd(), OUTPUT_DIR)

  try {
    statSync(rootDir)
  } catch {
    console.error(`构建产物目录不存在：${rootDir}`)
    console.error('请先执行构建命令')
    process.exit(1)
  }

  console.log(`检查小程序包体积...（${rootDir}）\n`)

  const packages: PackageInfo[] = []

  /** 识别分包：含 app.json 的为主包，其他顶层目录为分包 */
  const entries = readdirSync(rootDir)
  let mainPackageSize = 0
  const mainPackageFiles: string[] = []

  for (const entry of entries) {
    const fullPath = resolve(rootDir, entry)
    const stat = statSync(fullPath)

    if (stat.isDirectory()) {
      /** 检查是否为分包目录（通常在 app.json 的 subPackages 中配置） */
      const size = getDirSize(fullPath)
      packages.push({
        name: entry,
        path: relative(process.cwd(), fullPath),
        size,
      })
    } else {
      /** 顶层文件归入主包 */
      mainPackageSize += stat.size
      mainPackageFiles.push(entry)
    }
  }

  /** 主包 = 顶层文件 + 非分包目录 */
  /** 简化处理：将所有内容视为主包，由开发者根据 app.json 配置判断分包 */
  const totalSize = getDirSize(rootDir)

  /** 输出各目录体积 */
  console.log('目录体积明细：')
  console.log(`  主包文件：${formatSize(mainPackageSize)}`)
  packages
    .sort((a, b) => b.size - a.size)
    .forEach((pkg) => {
      console.log(`  ${pkg.name}/：${formatSize(pkg.size)}`)
    })
  console.log(`  总计：${formatSize(totalSize)}`)
  console.log('')

  /** 主包体积 = 总体积 - 已声明分包体积 */
  /** 注意：实际主包体积需根据 app.json 的 subPackages 配置计算 */
  /** 此处用总体积做保守估算，项目可根据实际情况调整 */

  if (totalSize > ERROR_THRESHOLD) {
    console.error(`❌ 构建产物总体积 ${formatSize(totalSize)} 超过 ${formatSize(ERROR_THRESHOLD)}`)
    console.error('   必须配置分包后再发版')
    console.error('   参考：https://uniapp.dcloud.net.cn/collocation/pages.html#subpackages')
    process.exit(1)
  }

  if (totalSize > WARN_THRESHOLD) {
    console.warn(`⚠️  构建产物总体积 ${formatSize(totalSize)} 接近 ${formatSize(ERROR_THRESHOLD)} 上限`)
    console.warn('   建议尽早规划分包')
  }

  console.log('✅ 小程序包体积检查通过')
}

main()
```

---

## 二、资源格式检查脚本

### 2.1 功能说明
- 扫描构建产物和源码中的图片资源
- **禁止** `.svg` 文件出现在小程序产物中
- **禁止** 使用 emoji 字符作为图标替代
- **警告** 单张图片超过 200KB（建议压缩或使用 CDN）
- CI 中执行，有错误时非零退出阻断合并

### 2.2 脚本（`scripts/check-mp-resources.ts`）

```ts
// scripts/check-mp-resources.ts
// 用法：npx ts-node scripts/check-mp-resources.ts
// 扫描小程序项目中的资源格式合规性

import { readFileSync, readdirSync, statSync } from 'fs'
import { resolve, extname, relative } from 'path'

/** 图片大小警告阈值 */
const IMAGE_WARN_SIZE = 200 * 1024 // 200KB

/** 禁止的图片格式 */
const BANNED_EXTENSIONS = new Set(['.svg'])

/** 允许的图片格式 */
const ALLOWED_IMAGE_EXTENSIONS = new Set(['.png', '.jpg', '.jpeg', '.webp', '.gif'])

/** 扫描目录 */
const SCAN_DIRS = ['src', 'dist/build/mp-weixin']

interface ResourceIssue {
  file: string
  type: 'banned_format' | 'oversized' | 'emoji_icon'
  detail: string
}

const issues: ResourceIssue[] = []

/** emoji 图标正则（常见图标类 emoji 范围） */
const EMOJI_ICON_REGEX = /[\u{1F300}-\u{1F9FF}]/u

/** 递归扫描 */
function scanDir(dir: string): void {
  let entries: string[]
  try {
    entries = readdirSync(dir)
  } catch {
    return
  }

  for (const entry of entries) {
    if (['node_modules', '.git', 'dist'].includes(entry) && dir.endsWith('src') === false) {
      /** 仅在非 dist 扫描时跳过 dist */
    }
    if (entry === 'node_modules' || entry === '.git') continue

    const fullPath = resolve(dir, entry)
    const stat = statSync(fullPath)
    const relPath = relative(process.cwd(), fullPath)

    if (stat.isDirectory()) {
      scanDir(fullPath)
      continue
    }

    const ext = extname(entry).toLowerCase()

    /** 检查禁止的图片格式 */
    if (BANNED_EXTENSIONS.has(ext)) {
      issues.push({
        file: relPath,
        type: 'banned_format',
        detail: `禁止格式 ${ext}，小程序仅允许 png/jpg/jpeg/webp`,
      })
    }

    /** 检查图片大小 */
    if (ALLOWED_IMAGE_EXTENSIONS.has(ext) && stat.size > IMAGE_WARN_SIZE) {
      issues.push({
        file: relPath,
        type: 'oversized',
        detail: `${(stat.size / 1024).toFixed(1)} KB，建议压缩或使用 CDN`,
      })
    }

    /** 检查 .vue 文件中的 emoji 图标用法 */
    if (ext === '.vue' || ext === '.ts') {
      const content = readFileSync(fullPath, 'utf-8')
      const lines = content.split('\n')
      lines.forEach((line, index) => {
        if (EMOJI_ICON_REGEX.test(line)) {
          /** 排除注释行 */
          const trimmed = line.trim()
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('<!--')) return
          issues.push({
            file: `${relPath}:${index + 1}`,
            type: 'emoji_icon',
            detail: '检测到 emoji 字符，小程序禁止使用 emoji 作为图标',
          })
        }
      })
    }
  }
}

function main(): void {
  console.log('检查小程序资源合规性...\n')

  for (const dir of SCAN_DIRS) {
    scanDir(resolve(process.cwd(), dir))
  }

  if (issues.length === 0) {
    console.log('✅ 资源格式检查通过')
    return
  }

  /** 按类型分组 */
  const banned = issues.filter((i) => i.type === 'banned_format')
  const oversized = issues.filter((i) => i.type === 'oversized')
  const emoji = issues.filter((i) => i.type === 'emoji_icon')

  let hasError = false

  /** 禁止格式 = 错误 */
  if (banned.length > 0) {
    hasError = true
    console.error(`❌ 发现 ${banned.length} 个禁止格式的资源文件：`)
    banned.forEach((i) => {
      console.error(`   ${i.file} — ${i.detail}`)
    })
    console.error('')
  }

  /** emoji 图标 = 错误 */
  if (emoji.length > 0) {
    hasError = true
    console.error(`❌ 发现 ${emoji.length} 处 emoji 图标用法：`)
    emoji.forEach((i) => {
      console.error(`   ${i.file} — ${i.detail}`)
    })
    console.error('')
  }

  /** 超大图片 = 警告 */
  if (oversized.length > 0) {
    console.warn(`⚠️  发现 ${oversized.length} 个超大图片（>${IMAGE_WARN_SIZE / 1024} KB）：`)
    oversized.forEach((i) => {
      console.warn(`   ${i.file} — ${i.detail}`)
    })
    console.warn('')
  }

  console.log(`扫描完成：${banned.length} 错误，${emoji.length} emoji，${oversized.length} 警告`)

  if (hasError) {
    console.error(`\n检查失败，请修复后再提交`)
    process.exit(1)
  }

  console.log('\n✅ 资源格式检查通过（有警告，请关注）')
}

main()
```

---

## 三、package.json 脚本配置

```json
{
  "scripts": {
    "check:mp-size": "ts-node scripts/check-mp-size.ts",
    "check:mp-resources": "ts-node scripts/check-mp-resources.ts"
  }
}
```

---

## 四、CI 集成

```yaml
# .github/workflows/ci.yml 片段（小程序构建后执行）
- name: 构建小程序
  run: npm run build:mp-weixin

- name: 小程序包体积检查
  run: npx ts-node scripts/check-mp-size.ts

- name: 小程序资源格式检查
  run: npx ts-node scripts/check-mp-resources.ts
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 小程序主包体积超过 2MB 必须配置分包后再发版 |
| 2 | MUST | 小程序禁止使用 `.svg` 格式图片，仅允许 `png/jpg/jpeg/webp` |
| 3 | MUST | 小程序禁止使用 emoji 字符作为图标替代 |
| 4 | MUST | CI 流水线必须执行包体积和资源格式检查脚本 |
| 5 | SHOULD | 单张图片超过 200KB 时评估压缩或使用 CDN |

检查方式：CI 脚本自动检查
阻断级别：MUST 条款阻断合并
