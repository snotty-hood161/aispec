# 规范化改造工具包模板

## 文档目标
1. 提供规范化改造的分批模板和 Token 补齐清单，支撑老项目逐步收敛到统一规范。
2. 改造原则参见 `common/normalization.md`。

---

## 一、规范化改造分批模板

### 1.1 改造范围评估表

每次改造启动前填写，明确本轮范围和验收标准：

```markdown
## 改造批次信息

| 项目 | 内容 |
|------|------|
| 批次编号 | N-{项目缩写}-{序号}（如 N-ADMIN-001） |
| 改造负责人 | |
| 改造周期 | 开始日期 ~ 结束日期（建议单批 ≤ 1 周） |
| 涉及页面/模块 | （列出具体页面路径或模块名） |
| 改造类型 | `Token 收敛` / `组件替换` / `样式迁移` / `适配层接入` |

## 改造范围

| 页面/模块 | 当前状态 | 改造目标 | 预估工时 |
|-----------|----------|----------|----------|
| /order/list | 硬编码颜色 12 处，无 token | 全部替换为 token | 2h |
| /order/detail | 使用旧版表单组件 | 替换为 Schema-Driven 表单 | 4h |
| /user/profile | 直接调用 wx.chooseImage | 收敛到 platform 适配层 | 1h |

## 验收标准

- [ ] 视觉回归：改造前后截图对比无差异
- [ ] 功能回归：涉及页面的核心流程手动走通
- [ ] lint 通过：无新增 lint 警告
- [ ] Token 检查：改造范围内无硬编码颜色/字号/间距
- [ ] 可回滚：改造以独立 PR 提交，可单独 revert
```

### 1.2 分批策略

| 策略 | 适用场景 | 说明 |
|------|----------|------|
| **按页面分批** | 页面间耦合低 | 每批 3-5 个页面，独立 PR |
| **按模块分批** | 模块内组件共享多 | 先改模块公共组件，再改页面 |
| **按改造类型分批** | 全局统一替换 | 如"第一批全部 Token 收敛，第二批组件替换" |

### 1.3 改造优先级排序

```
优先级从高到低：
1. 高频访问页面（首页、列表页、核心业务流程页）
2. 公共组件（改一次惠及多个页面）
3. 低频页面（设置页、关于页等）
4. 历史遗留页面（即将下线或极少访问的）
```

### 1.4 每批改造流程

```
1. 填写改造范围评估表
       │
       ▼
2. 创建改造分支（从 main 拉取）
       │
       ▼
3. 改造前截图（改造范围内每个页面）
       │
       ▼
4. 执行改造（Token 替换 / 组件替换 / 适配层接入）
       │
       ▼
5. 改造后截图（与改造前对比，确认无视觉差异）
       │
       ▼
6. 自测（涉及页面核心流程走通 + lint + typecheck）
       │
       ▼
7. 提交 PR（附改造范围表 + 前后截图对比）
       │
       ▼
8. 评审合并
       │
       ▼
9. 更新改造进度看板
```

---

## 二、Token 补齐清单

### 2.1 Token 审计脚本

用于扫描项目中的硬编码样式值，输出需要补齐的 Token 清单：

```ts
// scripts/audit-tokens.ts
// 用法：npx ts-node scripts/audit-tokens.ts
// 扫描 .vue 和 .css 文件中的硬编码颜色、字号、间距

import { readFileSync, readdirSync, statSync } from 'fs'
import { resolve, extname } from 'path'

/** 硬编码颜色正则（#hex、rgb、rgba） */
const COLOR_REGEX = /#[0-9a-fA-F]{3,8}\b|rgba?\([^)]+\)/g

/** 硬编码像素值正则（排除 0px） */
const PX_REGEX = /(?<![\w-])([1-9]\d*)px\b/g

/** 扫描结果 */
interface Finding {
  file: string
  line: number
  type: 'color' | 'size'
  value: string
  context: string
}

const findings: Finding[] = []

/** 已知 Token 值（不报告这些） */
const KNOWN_TOKENS = new Set([
  '#ffffff', '#fff', '#000000', '#000',
  'transparent', 'inherit', 'currentColor',
])

/** 递归扫描文件 */
function scanDir(dir: string): void {
  for (const entry of readdirSync(dir)) {
    const fullPath = resolve(dir, entry)
    const stat = statSync(fullPath)

    if (stat.isDirectory()) {
      /** 跳过 node_modules 和构建产物 */
      if (['node_modules', 'dist', '.git'].includes(entry)) continue
      scanDir(fullPath)
    } else if (['.vue', '.css', '.scss', '.less', '.ts', '.tsx'].includes(extname(entry))) {
      scanFile(fullPath)
    }
  }
}

/** 扫描单个文件 */
function scanFile(filePath: string): void {
  const content = readFileSync(filePath, 'utf-8')
  const lines = content.split('\n')

  lines.forEach((line, index) => {
    /** 跳过注释行 */
    if (line.trim().startsWith('//') || line.trim().startsWith('*')) return

    /** 检查硬编码颜色 */
    const colorMatches = line.matchAll(COLOR_REGEX)
    for (const match of colorMatches) {
      const val = match[0].toLowerCase()
      if (!KNOWN_TOKENS.has(val)) {
        findings.push({
          file: filePath,
          line: index + 1,
          type: 'color',
          value: match[0],
          context: line.trim(),
        })
      }
    }

    /** 检查硬编码像素值（仅在 style 相关上下文） */
    if (line.includes('style') || line.includes('class') || line.includes(':') || filePath.endsWith('.css')) {
      const pxMatches = line.matchAll(PX_REGEX)
      for (const match of pxMatches) {
        findings.push({
          file: filePath,
          line: index + 1,
          type: 'size',
          value: match[0],
          context: line.trim(),
        })
      }
    }
  })
}

function main(): void {
  console.log('扫描硬编码样式值...\n')
  scanDir(resolve(process.cwd(), 'src'))

  if (findings.length === 0) {
    console.log('✅ 未发现硬编码样式值')
    return
  }

  /** 按类型分组统计 */
  const colors = findings.filter((f) => f.type === 'color')
  const sizes = findings.filter((f) => f.type === 'size')

  console.log(`发现 ${findings.length} 处硬编码样式值：`)
  console.log(`  颜色值：${colors.length} 处`)
  console.log(`  尺寸值：${sizes.length} 处`)
  console.log('')

  /** 输出颜色值去重统计 */
  const colorCount = new Map<string, number>()
  colors.forEach((f) => {
    const key = f.value.toLowerCase()
    colorCount.set(key, (colorCount.get(key) ?? 0) + 1)
  })

  console.log('--- 颜色值统计（按出现次数降序）---')
  const sorted = [...colorCount.entries()].sort((a, b) => b[1] - a[1])
  sorted.forEach(([color, count]) => {
    console.log(`  ${color} — ${count} 处`)
  })

  console.log('')
  console.log('--- 详细位置（前 50 条）---')
  findings.slice(0, 50).forEach((f) => {
    console.log(`  ${f.file}:${f.line} [${f.type}] ${f.value}`)
    console.log(`    ${f.context}`)
  })

  if (findings.length > 50) {
    console.log(`  ... 还有 ${findings.length - 50} 条`)
  }
}

main()
```

### 2.2 Token 补齐清单模板

根据审计脚本输出，整理为补齐清单：

```markdown
## Token 补齐清单

| 序号 | 硬编码值 | 出现次数 | 建议 Token 名 | 语义说明 | 处理方式 |
|------|----------|----------|---------------|----------|----------|
| 1 | `#409EFF` | 23 | `--color-primary` | 主色 | 替换为已有 Token |
| 2 | `#F56C6C` | 8 | `--color-danger` | 危险色 | 替换为已有 Token |
| 3 | `#333333` | 15 | `--color-text-primary` | 主文字色 | 新增 Token |
| 4 | `#999999` | 12 | `--color-text-secondary` | 次要文字色 | 新增 Token |
| 5 | `14px` | 30 | `--font-size-sm` | 小号字体 | 替换为已有 Token |
| 6 | `20px` | 18 | `--spacing-md` | 中间距 | 替换为已有 Token |

### 处理方式说明
- **替换为已有 Token**：项目 Token 库中已有对应值，直接替换
- **新增 Token**：Token 库中无对应值，需先在全局 Token 文件中新增，再替换
- **保留**：属于一次性特殊值（如动画参数），不纳入 Token 体系
```

### 2.3 package.json 脚本

```json
{
  "scripts": {
    "audit:tokens": "ts-node scripts/audit-tokens.ts"
  }
}
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 每批改造必须填写改造范围评估表，明确范围、验收标准、回滚方案 |
| 2 | MUST | 改造以独立 PR 提交，不与业务需求混在同一 PR |
| 3 | MUST | 改造前后附截图对比，确认无视觉回归 |
| 4 | MUST | 新增 Token 使用语义命名，禁止使用页面/业务命名 |
| 5 | SHOULD | 改造启动前先执行 Token 审计脚本，量化改造工作量 |
| 6 | SHOULD | 每周更新改造进度看板，确保改造不拖延 |

检查方式：人工审查 + Token 审计脚本
阻断级别：MUST 条款阻断合并
