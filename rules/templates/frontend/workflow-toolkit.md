# 交付流程工具包模板

## 文档目标
1. 提供 PR 描述模板和页面拆分自动检测脚本，支撑交付流程标准化。
2. 交付流程规则参见 `common/workflow.md`。

---

## 一、PR 描述模板

### 1.1 使用方式
- **谁用**：所有前端开发者。
- **何时用**：每次提交 PR 时，将模板复制到 PR 描述中填写。
- **怎么用**：在仓库 `.github/PULL_REQUEST_TEMPLATE.md` 中配置，提交 PR 时自动填充。

### 1.2 模板内容

```markdown
## 变更类型
<!-- 勾选适用项 -->
- [ ] 新功能（Feature）
- [ ] 缺陷修复（Bugfix）
- [ ] 样式/规范化改造（Refactor）
- [ ] 性能优化（Performance）
- [ ] 依赖升级（Dependency）
- [ ] 配置变更（Config）

## 应用类型
<!-- 勾选适用项 -->
- [ ] admin-console（后台管理）
- [ ] wechat-h5（公众号 H5）
- [ ] miniprogram（小程序）

## 变更说明
<!-- 用 1-3 句话说明做了什么、为什么做 -->


## 影响范围
<!-- 列出涉及的页面/模块/组件 -->
- 页面：
- 组件：
- 接口：

## 本次读取的规则文件
<!-- 列出实际参考的规则文件（按需加载策略要求） -->
- [ ] `common/baseline.md`
- [ ] `common/workflow.md`
- [ ] （其他...）

## 测试验证
<!-- 说明如何验证变更正确性 -->
- [ ] lint 通过
- [ ] typecheck 通过
- [ ] test 通过
- [ ] 手动测试（附关键截图或录屏）

## 截图/录屏
<!-- 涉及 UI 变更时必须附前后对比截图 -->
| 变更前 | 变更后 |
|--------|--------|
|        |        |

## 回滚方案
<!-- 说明如果出问题如何回滚 -->


## 关联信息
<!-- 可选：关联的 Issue、需求文档、设计稿链接 -->
- Issue：
- 设计稿：

## 检查清单
<!-- PR 评审清单参见 templates/frontend/pr-review-checklist.md -->
- [ ] 已完成自查（参照 PR 评审清单）
- [ ] 无硬编码密钥/token/测试地址
- [ ] 无 console.log 残留
- [ ] 无调试代码残留
```

### 1.3 配置到仓库

```bash
# 在项目根目录创建 PR 模板
mkdir -p .github
# 将上方模板内容写入
# .github/PULL_REQUEST_TEMPLATE.md
```

---

## 二、页面拆分自动检测脚本

### 2.1 功能说明
- 扫描 `src/views/` 和 `src/pages/` 下所有 `.vue` 文件
- 超过 200 行输出 **警告**（建议评估拆分）
- 超过 300 行输出 **错误**（必须拆分后再合并）
- CI 中执行，有错误时非零退出阻断合并

### 2.2 脚本（`scripts/check-page-size.ts`）

```ts
// scripts/check-page-size.ts
// 用法：npx ts-node scripts/check-page-size.ts
// CI 中执行，超过 300 行的 .vue 文件阻断合并

import { readFileSync, readdirSync, statSync } from 'fs'
import { resolve, extname, relative } from 'path'

/** 行数阈值 */
const WARN_THRESHOLD = 200
const ERROR_THRESHOLD = 300

/** 扫描目录列表 */
const SCAN_DIRS = ['src/views', 'src/pages']

/** 结果类型 */
interface FileResult {
  file: string
  lines: number
  level: 'ok' | 'warn' | 'error'
}

const results: FileResult[] = []

/** 递归扫描 .vue 文件 */
function scanDir(dir: string, baseDir: string): void {
  if (!statSync(dir).isDirectory()) return

  for (const entry of readdirSync(dir)) {
    const fullPath = resolve(dir, entry)
    const stat = statSync(fullPath)

    if (stat.isDirectory()) {
      scanDir(fullPath, baseDir)
    } else if (extname(entry) === '.vue') {
      const content = readFileSync(fullPath, 'utf-8')
      const lineCount = content.split('\n').length
      const relPath = relative(process.cwd(), fullPath)

      let level: 'ok' | 'warn' | 'error' = 'ok'
      if (lineCount > ERROR_THRESHOLD) {
        level = 'error'
      } else if (lineCount > WARN_THRESHOLD) {
        level = 'warn'
      }

      results.push({ file: relPath, lines: lineCount, level })
    }
  }
}

function main(): void {
  console.log('检查页面/组件文件行数...\n')

  for (const dir of SCAN_DIRS) {
    const fullDir = resolve(process.cwd(), dir)
    try {
      scanDir(fullDir, fullDir)
    } catch {
      /** 目录不存在则跳过 */
    }
  }

  if (results.length === 0) {
    console.log('未找到 .vue 文件')
    return
  }

  /** 按行数降序排列 */
  results.sort((a, b) => b.lines - a.lines)

  const errors = results.filter((r) => r.level === 'error')
  const warns = results.filter((r) => r.level === 'warn')

  /** 输出错误（超过 300 行） */
  if (errors.length > 0) {
    console.error(`❌ 以下文件超过 ${ERROR_THRESHOLD} 行，必须拆分后再合并：`)
    errors.forEach((r) => {
      console.error(`   ${r.file} — ${r.lines} 行`)
    })
    console.error('')
  }

  /** 输出警告（超过 200 行） */
  if (warns.length > 0) {
    console.warn(`⚠️  以下文件超过 ${WARN_THRESHOLD} 行，建议评估拆分：`)
    warns.forEach((r) => {
      console.warn(`   ${r.file} — ${r.lines} 行`)
    })
    console.warn('')
  }

  /** 输出汇总 */
  console.log(`扫描完成：共 ${results.length} 个 .vue 文件`)
  console.log(`  正常：${results.length - errors.length - warns.length}`)
  console.log(`  警告（>${WARN_THRESHOLD} 行）：${warns.length}`)
  console.log(`  错误（>${ERROR_THRESHOLD} 行）：${errors.length}`)

  if (errors.length > 0) {
    console.error(`\n检查失败（${errors.length} 个文件超限）`)
    process.exit(1)
  }

  console.log('\n✅ 页面行数检查通过')
}

main()
```

### 2.3 package.json 脚本

```json
{
  "scripts": {
    "check:page-size": "ts-node scripts/check-page-size.ts"
  }
}
```

### 2.4 CI 集成

```yaml
# .github/workflows/ci.yml 片段
- name: 页面行数检查
  run: npx ts-node scripts/check-page-size.ts
```

### 2.5 拆分建议

当文件超过阈值时，按以下优先级拆分：

| 拆分方向 | 适用场景 | 做法 |
|----------|----------|------|
| **提取子组件** | 页面中有独立的区块（表单、表格、卡片列表） | 将区块提取为同目录下的私有组件 `components/XxxBlock.vue` |
| **提取 composable** | 页面中有复杂逻辑（数据加载、表单校验、状态计算） | 将逻辑提取为 `composables/useXxx.ts` |
| **提取常量/配置** | 页面中有大量配置（列定义、枚举映射、Schema） | 提取到同目录下 `config.ts` 或 `schema.ts` |
| **拆分路由** | 页面承担了多个独立功能 | 拆分为子路由页面 |

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 每个 PR 必须按模板填写描述，包含变更说明、影响范围、测试验证、回滚方案 |
| 2 | MUST | PR 描述必须列出本次实际读取的规则文件清单 |
| 3 | MUST | `.vue` 文件超过 300 行必须拆分后再合并 |
| 4 | MUST | CI 流水线必须执行页面行数检查脚本 |
| 5 | SHOULD | `.vue` 文件超过 200 行时评估拆分，记录不拆分的理由 |
| 6 | SHOULD | 仓库配置 `.github/PULL_REQUEST_TEMPLATE.md`，提交 PR 时自动填充模板 |

检查方式：CI 脚本 + 人工审查
阻断级别：MUST 条款阻断合并
