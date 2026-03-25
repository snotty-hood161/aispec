# 设计走查检查清单

用此清单逐项检查已实现界面的设计还原度。

## 使用方式
1. 按类别逐项检查。
2. 每项标注：通过（P）/ 不通过（F）/ 不适用（N/A）。
3. 不通过项必须附位置和修复建议。
4. 汇总计算通过率和还原度评分。

---

## 一、视觉一致性

| 编号 | 检查项 | 对照规范 | 优先级 |
|------|--------|---------|--------|
| V-01 | 品牌色使用正确（Primary / Secondary） | `rules/design/design-system.md` | P0 |
| V-02 | 功能色使用正确（Success / Warning / Error） | `rules/design/design-system.md` | P0 |
| V-03 | 字体族与设计 Token 一致 | 设计 Token 定义 | P0 |
| V-04 | 字号体系遵循设计 Token | 设计 Token 定义 | P0 |
| V-05 | 间距遵循设计 Token（4px 基准） | 设计 Token 定义 | P1 |
| V-06 | 圆角使用一致 | 设计 Token 定义 | P1 |
| V-07 | 阴影使用一致 | 设计 Token 定义 | P1 |
| V-08 | 图标风格统一（线性/填充/大小） | `rules/design/aesthetics.md` | P1 |
| V-09 | 按钮样式统一（主要/次要/文字/危险） | 设计 Token + 组件库 | P0 |
| V-10 | 表单组件样式统一（输入框/选择器/开关） | 设计 Token + 组件库 | P0 |

## 二、交互完整性

| 编号 | 检查项 | 对照规范 | 优先级 |
|------|--------|---------|--------|
| I-01 | 所有按钮有 hover / active / disabled 状态 | `rules/design/ux-principles.md` | P0 |
| I-02 | 表单字段有错误状态展示 | `rules/design/ux-principles.md` | P0 |
| I-03 | 加载状态有明确反馈（Skeleton/Spinner） | `rules/design/ux-principles.md` | P0 |
| I-04 | 空数据状态有展示（空列表/无搜索结果） | `rules/design/ux-principles.md` | P1 |
| I-05 | 操作成功有反馈（Toast/消息） | `rules/design/ux-principles.md` | P1 |
| I-06 | 危险操作有二次确认 | `rules/design/ux-principles.md` | P0 |
| I-07 | 页面跳转逻辑与设计流程一致 | 信息架构图 | P0 |
| I-08 | 导航高亮与当前页面匹配 | 用户流程图 | P1 |

## 三、响应式适配

| 编号 | 检查项 | 对照规范 | 优先级 |
|------|--------|---------|--------|
| R-01 | 桌面端（≥1280px）布局正确 | `rules/design/responsive.md` | P0 |
| R-02 | 平板端（768-1279px）布局合理 | `rules/design/responsive.md` | P1 |
| R-03 | 移动端（<768px）布局可用 | `rules/design/responsive.md` | P1 |
| R-04 | 文字不溢出容器 | — | P0 |
| R-05 | 图片在不同尺寸下不变形 | — | P1 |
| R-06 | 表格在小屏幕有适配方案（横滑/折叠） | `rules/design/responsive.md` | P1 |

## 四、无障碍合规

| 编号 | 检查项 | 对照规范 | 优先级 |
|------|--------|---------|--------|
| A-01 | 文字与背景对比度 ≥ 4.5:1（正文） | `rules/design/accessibility.md` | P0 |
| A-02 | 文字与背景对比度 ≥ 3:1（大字/标题） | `rules/design/accessibility.md` | P0 |
| A-03 | 可交互元素最小尺寸 ≥ 44×44px（移动端） | `rules/design/accessibility.md` | P1 |
| A-04 | 图片有 alt 文本 | `rules/design/accessibility.md` | P1 |
| A-05 | 表单字段有 label | `rules/design/accessibility.md` | P0 |
| A-06 | 颜色不是传达信息的唯一方式 | `rules/design/accessibility.md` | P1 |
| A-07 | 焦点顺序合理（Tab 键导航） | `rules/design/accessibility.md` | P1 |

## 走查报告格式

```
## 设计走查报告

### 走查概览
- 走查范围：{页面/模块清单}
- 检查项总数：{n}
- 通过：{n}（{%}）
- 不通过：{n}（{%}）
- 不适用：{n}

### 不通过项详情
| 编号 | 检查项 | 页面/位置 | 期望 | 实际 | 严重度 | 修复建议 |
|------|--------|---------|------|------|--------|---------|
| V-05 | 间距一致性 | 订单列表页 | 16px | 12px | P1 | 统一为 --spacing-4 |

### 设计还原度评分
- 评分：{A / B / C / D}
- 依据：{通过率和 P0 项通过情况}

### 修复建议摘要
1. {建议1}
2. {建议2}
```
