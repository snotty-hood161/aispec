# Tailwind CSS + Element Plus 组合使用约束

## 文档目标
1. 定义后台管理项目中 Tailwind CSS 与 Element Plus 并存时的样式优先级、变量映射和使用边界。
2. 技术栈锁定参见 `applications/admin-console.md`。

---

## 样式优先级（MUST）

### 分层模型

```
层级（从低到高）：
1. Element Plus 默认主题样式（最低）
2. Element Plus CSS Variables 自定义覆盖
3. Tailwind CSS 原子类
4. 组件 scoped 样式（最高，仅用于兜底微调）
```

### 规则

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 布局（间距、对齐、flex/grid）优先使用 Tailwind 原子类，不写自定义 CSS |
| 2 | MUST | Element Plus 组件的主题色、圆角、字号通过 CSS Variables 统一覆盖，禁止逐组件 `:deep()` 修改 |
| 3 | MUST | 禁止使用 `!important` 覆盖 Element Plus 样式，如遇冲突应调整加载顺序或使用 CSS Variables |
| 4 | MUST | scoped 样式仅用于 Element Plus 未暴露 CSS Variable 的极少数场景，且必须附注释说明原因 |
| 5 | SHOULD | 同一元素上 Tailwind 类名不超过 8 个，超过时提取为语义化组件 |

---

## CSS Variables 映射（MUST）

### 主题变量对齐

Element Plus 使用 `--el-*` CSS Variables 控制主题。项目必须在全局入口统一覆盖，使 Element Plus 组件与 Tailwind 使用同一套设计 Token。

```css
/* styles/element-variables.css */

:root {
  /* ========== 主色 ========== */
  --el-color-primary: theme('colors.primary.DEFAULT');
  --el-color-primary-light-3: theme('colors.primary.300');
  --el-color-primary-light-5: theme('colors.primary.200');
  --el-color-primary-light-7: theme('colors.primary.100');
  --el-color-primary-light-9: theme('colors.primary.50');
  --el-color-primary-dark-2: theme('colors.primary.700');

  /* ========== 功能色 ========== */
  --el-color-success: theme('colors.success.DEFAULT');
  --el-color-warning: theme('colors.warning.DEFAULT');
  --el-color-danger: theme('colors.danger.DEFAULT');
  --el-color-info: theme('colors.info.DEFAULT');

  /* ========== 圆角 ========== */
  --el-border-radius-base: theme('borderRadius.md');
  --el-border-radius-small: theme('borderRadius.sm');
  --el-border-radius-round: theme('borderRadius.full');

  /* ========== 字号 ========== */
  --el-font-size-base: theme('fontSize.sm');
  --el-font-size-small: theme('fontSize.xs');
  --el-font-size-large: theme('fontSize.base');
}
```

### Tailwind 配置对齐

```ts
// tailwind.config.ts

import type { Config } from 'tailwindcss'

export default {
  content: ['./index.html', './src/**/*.{vue,ts,tsx}'],
  /** 禁止 Tailwind 的 preflight 重置 Element Plus 基础样式 */
  corePlugins: {
    preflight: false,
  },
  theme: {
    extend: {
      colors: {
        /** 与 Element Plus 主题色保持一致 */
        primary: {
          DEFAULT: '#409EFF',
          50: '#ECF5FF',
          100: '#D9ECFF',
          200: '#B3D8FF',
          300: '#8CC5FF',
          400: '#66B1FF',
          500: '#409EFF',
          600: '#337ECC',
          700: '#266099',
          800: '#1A4166',
          900: '#0D2333',
        },
        success: { DEFAULT: '#67C23A' },
        warning: { DEFAULT: '#E6A23C' },
        danger: { DEFAULT: '#F56C6C' },
        info: { DEFAULT: '#909399' },
      },
    },
  },
} satisfies Config
```

---

## 加载顺序（MUST）

样式文件必须按以下顺序引入，确保优先级正确：

```ts
// main.ts

// 1. Element Plus 基础样式（最先加载，优先级最低）
import 'element-plus/dist/index.css'

// 2. Element Plus CSS Variables 覆盖（覆盖默认主题）
import '@/styles/element-variables.css'

// 3. Tailwind CSS（原子类优先级高于组件库默认样式）
import '@/styles/tailwind.css'

// 4. 全局自定义样式（仅极少数兜底场景）
import '@/styles/global.css'
```

### Tailwind 入口文件

```css
/* styles/tailwind.css */

@tailwind base;
@tailwind components;
@tailwind utilities;
```

---

## 使用边界（MUST）

### Tailwind 负责的场景

| 场景 | 示例 |
|------|------|
| 布局排列 | `flex items-center justify-between gap-4` |
| 间距 | `mt-4 px-6 py-2` |
| 宽高 | `w-full h-screen min-w-[200px]` |
| 文字样式 | `text-sm text-gray-500 font-medium truncate` |
| 背景与边框 | `bg-white rounded-md border border-gray-200` |
| 响应式 | `lg:flex-row md:grid-cols-2` |
| 显示/隐藏 | `hidden lg:block` |

### Element Plus 负责的场景

| 场景 | 说明 |
|------|------|
| 表单控件 | `<el-input>`、`<el-select>`、`<el-date-picker>` 等，不要用 Tailwind 重写 |
| 表格 | `<el-table>` + `<el-table-column>`，列宽用 Element Plus 的 `width`/`min-width` 属性 |
| 弹窗/抽屉 | `<el-dialog>`、`<el-drawer>`，尺寸用 `width` prop |
| 消息/通知 | `ElMessage`、`ElNotification`、`ElMessageBox`，样式通过 CSS Variables 调整 |
| 分页/标签/步骤条 | Element Plus 组件自身样式，不用 Tailwind 覆盖 |

### 禁止事项

| 编号 | 级别 | 禁止行为 |
|------|------|----------|
| 1 | MUST | 禁止用 Tailwind 原子类覆盖 Element Plus 组件内部结构（如 `.el-input__inner`） |
| 2 | MUST | 禁止同时使用 Tailwind 的 `text-[#409EFF]` 和 Element Plus CSS Variable 定义两套主色 |
| 3 | MUST | 禁止在 `<el-table-column>` 的 `template` 插槽内嵌套大量 Tailwind 类做复杂布局，应提取为子组件 |
| 4 | MUST | 禁止关闭 `preflight: false` 配置（关闭后 Tailwind reset 会破坏 Element Plus 基础样式） |

---

## 常见问题处理

### 1. Tailwind 类名不生效

**原因**：Element Plus 组件内部 DOM 层级较深，Tailwind 类加在外层无法穿透。

**解决**：
```vue
<!-- 正确：用 Tailwind 控制外层布局，Element Plus 控制组件内部 -->
<div class="flex items-center gap-4">
  <el-input placeholder="搜索" />
  <el-button type="primary">查询</el-button>
</div>
```

### 2. 主题色不一致

**原因**：Tailwind `colors.primary` 和 Element Plus `--el-color-primary` 定义了不同值。

**解决**：在 `element-variables.css` 中使用 `theme()` 函数引用 Tailwind 配置值（参见上方 CSS Variables 映射章节）。

### 3. 表格行间距异常

**原因**：Tailwind `preflight` 重置了 `table` 相关默认样式。

**解决**：确保 `corePlugins.preflight: false`，如果需要部分 reset 在 `global.css` 中手动添加。

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 布局、间距、排版使用 Tailwind，组件交互样式使用 Element Plus |
| 2 | MUST | 主题色通过 Tailwind config 定义，Element Plus 通过 CSS Variables 引用同一套值 |
| 3 | MUST | Tailwind 配置必须设置 `preflight: false` |
| 4 | MUST | 样式加载顺序：Element Plus → Variables 覆盖 → Tailwind → 全局自定义 |
| 5 | MUST | 禁止 `!important` 覆盖组件库样式 |
| 6 | MUST | 颜色值统一从 Tailwind config 取用，禁止硬编码 hex 值 |
| 7 | SHOULD | 单元素 Tailwind 类名不超过 8 个，超过时提取为语义化组件 |
| 8 | SHOULD | Element Plus 组件微调优先通过 CSS Variables，其次通过 scoped + `:deep()` 并附注释 |

检查方式：代码审查 + PR Review Checklist
阻断级别：MUST 条款阻断合并
