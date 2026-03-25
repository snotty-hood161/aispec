# rules/design/design-system.md — 设计系统规范

## 目的
规范设计系统的结构、命名、Token 定义和组件设计标准，确保设计产出可被前端高效还原。

## 设计 Token 规范

### Token 命名规则
- 使用语义化命名，不使用具体颜色值作为名称。
  - 正确：`color-primary`、`color-text-secondary`、`color-background-elevated`
  - 错误：`color-blue`、`color-333`、`color-light-gray`
- 使用 kebab-case 命名法。
- 层级用 `-` 分隔：`{类型}-{语义}-{变体}`。

### Token 分类

| 类型 | 前缀 | 示例 |
|------|------|------|
| 颜色 | `color-` | `color-primary-500`, `color-text-primary` |
| 字体 | `font-` | `font-display`, `font-body` |
| 字号 | `text-` | `text-sm`, `text-base`, `text-xl` |
| 行高 | `leading-` | `leading-tight`, `leading-normal` |
| 字重 | `weight-` | `weight-regular`, `weight-bold` |
| 间距 | `space-` | `space-2`, `space-4`, `space-8` |
| 圆角 | `radius-` | `radius-sm`, `radius-md`, `radius-lg` |
| 阴影 | `shadow-` | `shadow-sm`, `shadow-md`, `shadow-lg` |
| 动效 | `duration-` / `ease-` | `duration-fast`, `ease-in-out` |
| 断点 | `breakpoint-` | `breakpoint-sm`, `breakpoint-md` |
| 层级 | `z-` | `z-dropdown`, `z-modal`, `z-toast` |

### Token 输出格式（CSS 变量）

设计完成后，必须导出 CSS 变量形式的 Token：

```css
:root {
  /* 颜色 */
  --color-primary-50: #eff6ff;
  --color-primary-500: #3b82f6;
  --color-primary-900: #1e3a5f;

  /* 语义色 */
  --color-text-primary: var(--color-gray-900);
  --color-text-secondary: var(--color-gray-600);
  --color-background-primary: var(--color-gray-50);

  /* 字体 */
  --font-display: 'Playfair Display', '思源宋体', serif;
  --font-body: 'DM Sans', '思源黑体', sans-serif;

  /* 间距 */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --space-8: 2rem;

  /* 圆角 */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;

  /* 阴影 */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);

  /* 动效 */
  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --ease-default: cubic-bezier(0.4, 0, 0.2, 1);
}
```

## 组件设计规范

### 组件设计原则
1. **原子化** — 从最小粒度开始：图标 → 按钮 → 输入框 → 卡片 → 区域 → 页面。
2. **状态完整** — 每个可交互组件必须设计所有状态（默认/悬停/按下/聚焦/禁用/加载）。
3. **尺寸变体** — 常用组件提供 2-3 个尺寸变体（小/中/大）。
4. **可复用标记** — 在 Pencil 中设为 `reusable: true`，便于跨页面复用。

### 必备组件清单

#### 基础组件
| 组件 | 变体 | 状态 |
|------|------|------|
| 按钮 Button | 主要/次要/文字/图标/危险 | 默认/悬停/按下/禁用/加载 |
| 输入框 Input | 文本/密码/搜索/数字 | 默认/聚焦/错误/禁用/只读 |
| 文本域 Textarea | 固定高度/自动增长 | 默认/聚焦/错误/禁用 |
| 选择器 Select | 单选/多选/搜索型 | 默认/展开/禁用 |
| 开关 Switch | 默认尺寸/小尺寸 | 开/关/禁用 |
| 复选框 Checkbox | 默认 | 选中/未选中/半选/禁用 |
| 单选框 Radio | 默认 | 选中/未选中/禁用 |

#### 数据展示
| 组件 | 变体 | 备注 |
|------|------|------|
| 表格 Table | 基础/可排序/可选择/固定列 | 含表头、行、分页 |
| 卡片 Card | 基础/可点击/带图片/带操作 | 含标题、内容、底部 |
| 列表 List | 基础/带头像/带操作 | 含分割线变体 |
| 标签 Tag | 颜色变体/可删除 | 多种颜色方案 |
| 徽章 Badge | 数字/圆点/文字 | 含定位方式 |
| 头像 Avatar | 图片/文字/图标 | 多尺寸 |
| 空状态 Empty | 无数据/无搜索结果/出错 | 含引导操作 |

#### 反馈
| 组件 | 变体 | 备注 |
|------|------|------|
| 消息提示 Toast | 成功/警告/错误/信息 | 含自动消失策略 |
| 对话框 Dialog | 确认/信息/表单 | 含遮罩层 |
| 抽屉 Drawer | 左/右/底部 | 含遮罩层 |
| 进度条 Progress | 线性/环形 | 含百分比显示 |
| 加载 Loading | 全局/局部/骨架屏 | 多种动画 |

#### 导航
| 组件 | 变体 | 备注 |
|------|------|------|
| 顶部导航 Header | 固定/非固定/透明 | 含 Logo、菜单、操作区 |
| 侧边菜单 Sidebar | 展开/折叠/迷你 | 含多级菜单 |
| 标签页 Tabs | 顶部/底部/卡片式 | 含图标变体 |
| 面包屑 Breadcrumb | 基础/带图标 | 含分隔符 |
| 分页 Pagination | 基础/简洁/迷你 | 含跳转 |

### 组件命名规范
- 组件名使用 PascalCase：`PrimaryButton`、`SearchInput`、`DataTable`。
- 变体使用属性标注：`PrimaryButton/Disabled`、`Input/Error`。
- 在 Pencil 中的节点名使用清晰的层级：`Components/Button/Primary/Default`。

## 文件组织规范

### Pencil 文件结构
```
{项目名}.pen
├── 📁 Design System（设计系统）
│   ├── 📁 Colors（色彩）
│   ├── 📁 Typography（字体排印）
│   ├── 📁 Icons（图标）
│   └── 📁 Components（组件库）
│       ├── 📁 Button
│       ├── 📁 Input
│       ├── 📁 Card
│       └── ...
├── 📁 Pages（页面设计）
│   ├── 📁 Auth（认证页面）
│   ├── 📁 Dashboard（仪表盘）
│   ├── 📁 {模块A}
│   └── 📁 {模块B}
└── 📁 Flows（交互流程）
    ├── 📁 User Flow A
    └── 📁 User Flow B
```

### 页面命名规范
- 使用"模块-页面类型"格式：`Order-List`、`Order-Detail`、`User-Edit`。
- 响应式变体标注断点：`Order-List/Desktop`、`Order-List/Mobile`。
- 状态变体标注状态：`Order-List/Loading`、`Order-List/Empty`。
