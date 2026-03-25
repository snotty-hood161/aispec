# rules/react-native/common/ui-framework.md

## 文档目标
1. 定义 React Native 应用的 UI 组件封装、主题系统、响应式布局与手势处理规范。

---

## 组件封装（MUST）

1. 项目必须建立基础 UI 组件库，封装常用原子组件，禁止在业务代码中直接使用原生组件的裸调用：

| 基础组件 | 封装目标 | 示例 |
|---------|---------|------|
| `AppText` | 统一字体、字号、颜色 | 替代 `<Text>` |
| `AppButton` | 统一按钮样式、Loading 状态、防重复点击 | 替代 `<TouchableOpacity>` |
| `AppImage` | 统一图片加载、占位图、错误兜底 | 封装 FastImage |
| `AppInput` | 统一输入框样式、校验、错误提示 | 替代 `<TextInput>` |
| `AppModal` | 统一弹窗动画、遮罩、关闭行为 | 封装 `<Modal>` |
| `Spacer` | 统一间距控制 | 替代硬编码 margin/padding |

2. 基础组件必须支持主题切换（通过 Theme Context 读取样式变量）。
3. 基础组件必须提供 TypeScript 类型完善的 Props 定义。
4. 按钮组件必须内置防重复点击（默认 300ms 节流），防止用户快速多次点击。
5. 组件必须支持 `testID` 属性透传，供测试使用。

```tsx
interface AppButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'small' | 'medium' | 'large';
  loading?: boolean;
  disabled?: boolean;
  testID?: string;
}

export const AppButton: React.FC<AppButtonProps> = React.memo(({ ... }) => {
  // 内置防重复点击 + Loading 状态 + 主题样式
});
```

---

## 主题系统（MUST）

1. 必须建立统一的主题系统，所有样式值通过主题变量引用，禁止硬编码颜色值 / 字号 / 间距。
2. 主题必须支持亮色 / 暗色模式切换。
3. 主题定义结构：

```typescript
interface Theme {
  colors: {
    primary: string;
    secondary: string;
    background: string;
    surface: string;
    text: string;
    textSecondary: string;
    border: string;
    error: string;
    success: string;
    warning: string;
  };
  spacing: {
    xs: number;  // 4
    sm: number;  // 8
    md: number;  // 16
    lg: number;  // 24
    xl: number;  // 32
  };
  typography: {
    h1: TextStyle;
    h2: TextStyle;
    h3: TextStyle;
    body: TextStyle;
    caption: TextStyle;
  };
  borderRadius: {
    sm: number;
    md: number;
    lg: number;
    full: number;
  };
}
```

4. 主题通过 React Context 提供，组件通过 `useTheme()` Hook 读取。
5. 推荐使用 `react-native-unistyles` 或自定义 `useTheme` + `StyleSheet.create` 方案。
6. 禁止在 `StyleSheet.create()` 中硬编码颜色值（如 `color: '#333333'`），必须引用主题变量。

---

## 样式规范（MUST）

1. 样式必须使用 `StyleSheet.create()` 定义，禁止使用内联样式对象（性能差且不可复用）：

```tsx
// 正确
const styles = StyleSheet.create({
  container: { flex: 1, padding: theme.spacing.md },
});
<View style={styles.container} />

// 错误
<View style={{ flex: 1, padding: 16 }} />  // 禁止内联样式
```

2. 样式文件与组件同目录，命名为 `ComponentName.styles.ts`。
3. 动态样式推荐使用函数返回 StyleSheet 或 `useMemo` 缓存。
4. 禁止使用 `!important` 或 CSS-in-JS 库的 override 机制覆盖基础组件样式。
5. 间距值必须使用主题中的 spacing 常量，禁止使用任意像素值。

---

## 响应式布局（MUST）

1. 布局必须适配不同屏幕尺寸（手机 / 平板），禁止假设固定屏幕宽度。
2. 推荐使用 **react-native-responsive-screen** 或 `useWindowDimensions` 实现响应式布局。
3. 关键断点定义：

| 设备类型 | 宽度范围 | 布局策略 |
|---------|---------|---------|
| 小屏手机 | < 375 | 单列，紧凑间距 |
| 标准手机 | 375-428 | 单列，标准间距 |
| 大屏手机/小平板 | 428-768 | 单列或双列 |
| 平板 | ≥ 768 | 多列，Master-Detail |

4. 推荐使用 Flexbox 布局，避免绝对定位和固定宽高。
5. 文字大小推荐支持系统辅助功能的字体缩放（`allowFontScaling`），但设置最大缩放倍数（`maxFontSizeMultiplier`）防止布局溢出。

---

## 手势处理（MUST）

1. 手势交互必须使用 **react-native-gesture-handler**，禁止使用原生 `PanResponder`（JS 线程处理，易卡顿）。
2. 手势驱动的动画必须使用 **react-native-reanimated** 的 `useAnimatedGestureHandler` / `useAnimatedStyle`。
3. 常见手势封装必须复用项目组件库，禁止各页面重复实现：
   - 下拉刷新（Pull to Refresh）。
   - 左滑删除（Swipe to Delete）。
   - 底部弹出面板（Bottom Sheet）：推荐 `@gorhom/bottom-sheet`。
   - 图片缩放（Pinch to Zoom）。
4. 手势区域必须设置合理的 hitSlop（至少 44×44pt），确保可触达。

---

## 图标与资源（MUST）

1. 图标推荐使用 SVG 方案（**react-native-svg** + **react-native-svg-transformer**），或字体图标（**react-native-vector-icons**）。
2. 图标必须支持主题颜色切换（通过 props 注入颜色值）。
3. 禁止使用大量 PNG 位图图标（增加包体积且不支持缩放）。
4. 图标组件封装统一的 `AppIcon`，支持 `name` / `size` / `color` 属性。

---

## 无障碍（Accessibility）（MUST）

1. 所有可交互元素必须设置 `accessibilityLabel` 和 `accessibilityRole`。
2. 图片必须设置 `accessibilityLabel` 描述内容。
3. 表单输入必须关联 `accessibilityHint` 提示操作。
4. 自定义组件必须正确设置 `accessible` / `accessibilityState` 属性。
5. 推荐使用 Accessibility Inspector（iOS）/ TalkBack（Android）定期验证。

---

## 禁止事项

1. 禁止使用内联样式对象（`style={{ ... }}`），必须使用 `StyleSheet.create()`。
2. 禁止在样式中硬编码颜色值、字号、间距（必须引用主题变量）。
3. 禁止使用 `PanResponder` 处理手势（必须使用 react-native-gesture-handler）。
4. 禁止可交互元素缺少 `accessibilityLabel`。
5. 禁止假设固定屏幕宽度进行布局。
