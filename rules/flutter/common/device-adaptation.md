# rules/flutter/common/device-adaptation.md

## 文档目标
1. 定义 Flutter 跨平台应用的设备适配规范，覆盖手机、平板、折叠屏、横屏等多形态设备。
2. 本文件为 Flutter 规范体系中最核心的跨平台差异化文件，确保同一代码库在不同设备上提供最佳体验。

---

## 响应式布局策略（MUST）

1. 必须使用 `LayoutBuilder` 或 `MediaQuery` 实现响应式布局，禁止硬编码设备尺寸。
2. 统一屏幕断点定义（与 Material 3 WindowSizeClass 对齐）：

| 断点 | 宽度范围 | 典型设备 | 布局策略 |
|------|---------|---------|---------|
| Compact | < 600dp | 手机竖屏 | 单列、底部导航 |
| Medium | 600dp ~ 839dp | 大屏手机横屏、小平板 | 可选双列、NavigationRail |
| Expanded | ≥ 840dp | 平板、桌面 | 多窗格、侧边栏导航 |

3. 推荐封装统一的断点工具：

```dart
enum ScreenSize { compact, medium, expanded }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return ScreenSize.compact;
  if (width < 840) return ScreenSize.medium;
  return ScreenSize.expanded;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget expanded;

  const ResponsiveLayout({
    required this.compact,
    this.medium,
    required this.expanded,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) return expanded;
        if (constraints.maxWidth >= 600) return medium ?? compact;
        return compact;
      },
    );
  }
}
```

4. 禁止使用 `Platform.isAndroid` / `Platform.isIOS` 判断屏幕布局（平台不等于屏幕尺寸）。
5. 必须使用 `MediaQuery.sizeOf(context)` 替代 `MediaQuery.of(context).size`（性能优化，减少不必要的重建）。

---

## Android 手机适配（MUST）

1. 必须适配 Android 主流手机屏幕宽度（320dp ~ 480dp）。
2. 处理异形屏（刘海 / 挖孔 / 水滴屏）：
   - 使用 `SafeArea` Widget 包裹页面内容，自动避让系统 UI 区域。
   - 禁止在 SafeArea 外区域放置可交互元素。
3. Edge-to-Edge 显示（Android 15+ 强制）：
   - 使用 `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` 启用。
   - 系统栏设置为透明：`SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent))`。
4. 系统导航栏（手势导航 vs 三键导航）：
   - 使用 `MediaQuery.viewPaddingOf(context).bottom` 获取底部安全区域。
   - 底部固定元素（FAB、底部操作栏）必须避让手势导航条。

---

## Android 平板适配（MUST — 面向 Play Store 分发的应用）

1. Google Play 已将大屏适配列为应用质量审核要求，面向 Play Store 分发的应用必须适配平板。
2. Expanded 断点下（≥ 840dp）必须提供多窗格布局：
   - 列表-详情模式（Master-Detail）。
   - 侧边栏 + 内容区。
3. 导航适配：
   - Compact：`BottomNavigationBar`。
   - Medium：`NavigationRail`。
   - Expanded：`NavigationDrawer`（常驻侧边栏）。
4. 对话框 / 底部弹窗在平板上使用合适的最大宽度约束，禁止全屏拉伸：

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: DialogContent(),
    ),
  ),
);
```

---

## Android 折叠屏适配（SHOULD）

1. 推荐使用 `dual_screen` 或 `window_manager` 包检测折叠状态。
2. 展开态：按 Expanded 断点处理，提供多窗格布局。
3. 半折叠态（Table-Top Mode）：
   - 视频 / 相机场景：上半屏显示内容，下半屏显示控制。
   - 使用 `MediaQuery` 检测窗口尺寸变化并动态调整布局。
4. 禁止将关键交互元素放置在折叠线附近（铰链区域两侧各 24dp 范围内）。
5. 多窗口 / 分屏模式下必须正确响应窗口尺寸变化。

---

## iOS iPhone 适配（MUST）

1. 必须适配所有当前在售 iPhone 屏幕尺寸：

| 机型类别 | 逻辑宽度 | 特征 |
|---------|---------|------|
| iPhone SE (3rd) | 375pt | 无刘海、Home Button、4.7" |
| iPhone 15/16 | 393pt | Dynamic Island、6.1" |
| iPhone 15/16 Plus/Max | 430pt | Dynamic Island、6.7"+ |

2. 使用 `SafeArea` 自动适配刘海 / Dynamic Island / Home Indicator。
3. 禁止通过 `Platform.isIOS` + 硬编码尺寸判断机型，必须使用 `MediaQuery` + `SafeArea`。
4. 支持 Dynamic Type（系统字体缩放）：
   - 使用 `MediaQuery.textScalerOf(context)` 获取字体缩放因子。
   - 布局必须适应大字体模式，禁止固定高度截断文本。
5. 底部固定元素必须避让 Home Indicator（`SafeArea` 自动处理）。

---

## iOS iPad 适配（MUST — Universal 应用）

1. 以 Universal 应用在 App Store 分发时，必须提供 iPad 优化布局。
2. iPad 布局要求：
   - 必须提供多列 / 侧边栏布局（NavigationSplitView 模式）。
   - 禁止直接拉伸 iPhone 布局到 iPad（用户体验极差）。
   - 弹窗使用合理的最大宽度约束。
3. iPad 多任务适配（MUST）：

| 多任务模式 | 窗口宽度 | 适配策略 |
|-----------|---------|---------|
| 全屏 | ≥ 840dp | Expanded 布局 |
| Split View 1/2 | ~507dp | Medium 布局 |
| Split View 1/3 | ~320dp | Compact 布局 |
| Slide Over | ~320dp | Compact 布局 |

4. 必须正确响应窗口尺寸动态变化（用户拖动分屏边界时实时调整布局）。
5. Stage Manager（iPadOS 16+）：窗口尺寸可自由调整，布局必须对任意尺寸响应。
6. 指针输入适配：
   - 支持鼠标悬停效果（`MouseRegion` + `InkWell` hover 状态）。
   - 支持右键菜单（使用 `SecondaryTapGestureRecognizer` 或 `contextMenuBuilder`）。
   - 推荐支持键盘快捷键（`Shortcuts` + `Actions`）。

---

## 横屏模式（MUST — 分场景）

### 通用规则
1. 横屏切换时禁止丢失用户状态（表单数据、滚动位置、播放进度）。
2. 横屏下必须正确处理 SafeArea 的左右 Inset（刘海 / Dynamic Island 区域）。
3. 使用 `OrientationBuilder` 或 `MediaQuery.orientationOf(context)` 检测方向。

### 场景化规则

| 应用类型 | 横屏支持要求 | 说明 |
|---------|-------------|------|
| 视频 / 相机 | MUST | 必须支持横屏全屏播放 |
| 游戏 | MUST | 必须支持主操作方向 |
| 生产力工具 | SHOULD | 推荐支持，特别是平板用户 |
| 业务 / 电商 | SHOULD | 推荐支持或优雅降级 |
| 纯手机应用 | MAY | 可锁定竖屏，但平板设备不推荐锁定 |

4. 锁定方向使用 `SystemChrome.setPreferredOrientations()`：

```dart
// 仅在手机上锁定竖屏，平板不锁定
final screenSize = getScreenSize(context);
if (screenSize == ScreenSize.compact) {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
} else {
  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}
```

---

## 屏幕密度适配（MUST）

1. 使用 `MediaQuery.devicePixelRatioOf(context)` 获取设备像素比。
2. 图片资源按密度提供：
   - 使用 Flutter Asset 的 `1.0x` / `2.0x` / `3.0x` 目录结构。
   - 优先使用矢量图（SVG）减少多密度资源维护成本。
3. 自定义绘制（`CustomPaint`）中使用逻辑像素（`dp`），Flutter 自动处理像素比。
4. 禁止硬编码物理像素值。

---

## 平台差异化 UI（SHOULD）

1. 推荐在关键交互组件上使用平台自适应行为：

| 组件 | Android 行为 | iOS 行为 | Flutter 实现 |
|------|-------------|---------|-------------|
| 对话框 | Material AlertDialog | CupertinoAlertDialog | `showAdaptiveDialog` |
| 开关 | Material Switch | CupertinoSwitch | `Switch.adaptive` |
| 滑块 | Material Slider | CupertinoSlider | `Slider.adaptive` |
| 下拉刷新 | Material RefreshIndicator | Cupertino 弹性滚动 | `RefreshIndicator.adaptive` |
| 导航过渡 | 淡入 / 共享元素 | 从右滑入 | 路由库平台自适应 |

2. 使用 `ThemeData.platform` 或 `defaultTargetPlatform` 判断平台风格（非设备检测）。
3. 滚动物理特性自动适配（Android 过度滚动辉光 vs iOS 弹性回弹），无需手动处理。

---

## 设备测试矩阵（MUST）

1. 发布前必须在以下最低设备覆盖上完成测试：

### Android 测试矩阵

| 类别 | 最低要求 | 说明 |
|------|---------|------|
| 手机（小屏） | ≥ 1 款 | 屏宽 < 360dp |
| 手机（标准） | ≥ 1 款 | 屏宽 360dp ~ 411dp |
| 手机（大屏） | ≥ 1 款 | 屏宽 > 411dp |
| 平板 | ≥ 1 款（Play Store 分发时） | 10 英寸以上 |

### iOS 测试矩阵

| 类别 | 最低要求 | 说明 |
|------|---------|------|
| iPhone（小屏） | ≥ 1 款 | iPhone SE 系列 |
| iPhone（标准） | ≥ 1 款 | iPhone 15/16 |
| iPhone（大屏） | ≥ 1 款 | iPhone Plus/Max |
| iPad | ≥ 1 款（Universal 应用） | iPad Air / iPad Pro |

### 必须验证场景

| 验证项 | 说明 |
|-------|------|
| 竖屏 + 横屏 | 如应用支持横屏 |
| 系统字体缩放 | 默认 / 1.3x / 最大 |
| 深色模式 | Light + Dark |
| 平板多任务 | 全屏 / 1/2 分屏 / 1/3 分屏（iPad） |
| 多窗口 | Android 分屏模式 |
| 无障碍 | TalkBack (Android) / VoiceOver (iOS) 基础验证 |
| 弱网 | 3G 速度下核心流程可完成 |
| 离线 | 无网络时不崩溃，展示合理的离线提示 |

2. 推荐使用 CI 自动化测试覆盖部分矩阵：
   - Firebase Test Lab（Android 多设备）。
   - Xcode Simulator（iOS 多设备尺寸）。
3. 测试报告必须记录测试设备列表、OS 版本、测试结果。
