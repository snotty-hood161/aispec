# 设计阶段 → 工作内容映射表

用此表引导 UI/UX 设计的四个阶段和每个阶段的工作内容。

## 使用方式
1. 按阶段顺序逐步执行。
2. 每个阶段结束后确认产出，再进入下一阶段。
3. 已有部分输入时可跳过对应内容（如已有品牌色则跳过色彩定义）。

---

## 阶段路由表

| 阶段 | 名称 | 引导问题文件 | 核心产出 | MCP 依赖 |
|------|------|------------|---------|---------|
| Phase 1 | 设计调研 | `agents/design/phases/01-research.md` | 竞品设计分析、风格方向、品牌色 | 搜索 MCP（可选）+ Playwright（可选） |
| Phase 2 | 交互设计 | `agents/design/phases/02-ux.md` | 信息架构图、用户流程、页面清单、交互规则 | Pencil MCP（必需） |
| Phase 3 | 视觉设计 | `agents/design/phases/03-ui.md` | 设计 Token、组件库、页面设计（.pen） | Pencil MCP（必需） |
| Phase 4 | 设计验证 | `agents/design/phases/04-review.md` | 审查报告、还原度评分、交付文档 | Pencil MCP（必需） |

## 设计 Token 结构

```
Design Token 体系：

├── 色彩（Colors）
│   ├── 品牌色（Primary / Secondary）
│   ├── 功能色（Success / Warning / Error / Info）
│   ├── 中性色（Gray 等级 50~950）
│   └── 背景色（Surface / Background）
├── 字体（Typography）
│   ├── 字族（Font Family）
│   ├── 字号体系（12/14/16/20/24/32/40px）
│   ├── 行高（1.4 / 1.5 / 1.6）
│   └── 字重（Regular 400 / Medium 500 / Bold 700）
├── 间距（Spacing）
│   └── 4px 基准递增（4/8/12/16/20/24/32/40/48/64px）
├── 圆角（Border Radius）
│   └── none/sm/md/lg/xl/full（0/2/4/8/12/9999px）
├── 阴影（Shadow）
│   └── sm/md/lg/xl
└── 动效（Motion）
    └── duration-fast/normal/slow（100/200/300ms）
```

## CSS 变量导出格式

```css
:root {
  /* 品牌色 */
  --color-primary: #3B82F6;
  --color-primary-hover: #2563EB;
  --color-primary-active: #1D4ED8;

  /* 功能色 */
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-error: #EF4444;

  /* 字体 */
  --font-family-base: 'Inter', -apple-system, sans-serif;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.25rem;

  /* 间距 */
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-4: 1rem;

  /* 圆角 */
  --radius-sm: 0.125rem;
  --radius-md: 0.25rem;
  --radius-lg: 0.5rem;
}
```

## 设计还原度评分标准

| 等级 | 标准 | 结论 |
|------|------|------|
| A（优秀） | 所有页面设计完整，Token 使用一致，无障碍合规，响应式完整 | 可直接交付开发 |
| B（良好） | 核心页面设计完整，少量 Token 不一致，无障碍基本合规 | 修复后交付 |
| C（合格） | 核心页面存在遗漏，Token 不一致较多，无障碍有缺失 | 需要补充设计 |
| D（不合格） | 大量页面缺失，设计系统不完整 | 需要重新设计 |

## 加载的设计规范文件

| 阶段 | 加载规则 |
|------|---------|
| 始终加载 | `rules/design/index.md` |
| Phase 1 | `rules/design/aesthetics.md` |
| Phase 2 | `rules/design/ux-principles.md`、`rules/design/responsive.md` |
| Phase 3 | `rules/design/design-system.md`、`rules/design/accessibility.md` |
| Phase 4 | 全部设计规范（交叉检查） |
