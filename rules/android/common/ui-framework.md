# rules/android/common/ui-framework.md

## 文档目标
1. 定义 Android 应用的 UI 框架通用规范，覆盖设计系统、无障碍、适配等。

---

## Material Design 3（MUST）

1. 新项目必须遵循 **Material Design 3** 设计规范。
2. 使用 Material 3 组件库（`androidx.compose.material3` 或 `com.google.android.material`）。
3. 颜色系统使用 Dynamic Color（Android 12+）+ 自定义 Color Scheme 兜底。
4. 排版使用 Material 3 Type Scale，禁止自定义字体大小不在 Scale 范围内。

---

## 深色模式（MUST）

1. 应用必须支持深色模式（Dark Theme）。
2. 颜色定义必须同时提供 Light 和 Dark 方案。
3. 禁止硬编码颜色值到布局中，必须通过 Theme 属性引用。
4. 图片资源需考虑深色模式适配（透明背景或提供 night 变体）。

---

## 无障碍（Accessibility）（MUST）

1. 所有可交互元素必须有 `contentDescription`（Compose）或 `android:contentDescription`（XML）。
2. 触摸目标最小尺寸 48dp x 48dp。
3. 文本对比度必须符合 WCAG 2.1 AA 标准（普通文本 4.5:1，大文本 3:1）。
4. 支持系统字体缩放（`sp` 单位），禁止使用 `dp` 定义文本大小。
5. 自定义 View 必须实现 `AccessibilityNodeInfo`。

---

## 屏幕适配（MUST）

1. 布局使用 `dp` 单位，文本使用 `sp` 单位。
2. 必须基于 `WindowSizeClass` 实现响应式布局，三个断点定义：
   - `Compact`（< 600dp）：手机竖屏，单列布局。
   - `Medium`（600dp ~ 839dp）：大屏手机横屏 / 小平板，可选双列。
   - `Expanded`（≥ 840dp）：平板 / 桌面，必须提供多窗格布局。
3. 禁止通过硬编码设备型号 / 分辨率判断布局，必须依赖 `WindowSizeClass` 或 `WindowMetrics`。
4. Compose 使用 `calculateWindowSizeClass()` 获取当前断点。
5. XML 使用 `ConstraintLayout` + `res/layout-w600dp/` 等限定符实现响应式布局。
6. 图片提供 `mdpi` ~ `xxxhdpi` 多密度资源（优先使用 Vector Drawable / WebP）。

```kotlin
// WindowSizeClass 响应式布局示例
val windowSizeClass = calculateWindowSizeClass(this)
when (windowSizeClass.widthSizeClass) {
    WindowWidthSizeClass.Compact -> PhoneLayout()
    WindowWidthSizeClass.Medium -> MediumLayout()
    WindowWidthSizeClass.Expanded -> TabletLayout() // 必须提供
}
```

---

## 平板适配（MUST — 面向应用商店分发的应用）

1. 在 Google Play 分发的应用必须适配平板（Large Screen），Google Play 已将平板适配列为质量审核要求。
2. `Expanded` 宽度下必须提供多窗格布局，禁止直接拉伸手机布局到平板。
3. Compose 推荐使用 `ListDetailPaneScaffold`（Material3 Adaptive）实现列表-详情模式。
4. 导航组件适配：
   - `Compact`：底部导航栏（`NavigationBar`）。
   - `Medium`：侧边导航栏（`NavigationRail`）。
   - `Expanded`：抽屉导航（`PermanentNavigationDrawer`）。
5. Compose 推荐使用 `NavigationSuiteScaffold` 自动适配导航组件。
6. 输入方式适配：平板支持键盘快捷键、鼠标悬停（`Modifier.hoverable`）、触控笔。
7. 拖放操作（Drag & Drop）：平板多窗口场景下推荐支持应用间拖放。

```kotlin
// NavigationSuiteScaffold 自动导航适配
NavigationSuiteScaffold(
    navigationSuiteItems = {
        items.forEach { item ->
            item(
                selected = currentRoute == item.route,
                onClick = { navigate(item.route) },
                icon = { Icon(item.icon, contentDescription = item.label) },
                label = { Text(item.label) }
            )
        }
    }
) {
    // 页面内容
}
```

---

## 折叠屏适配（SHOULD）

1. 推荐使用 Jetpack **WindowManager** 库检测折叠状态与铰链位置。
2. 展开态（Flat）：按 `Expanded` WindowSizeClass 处理，提供多窗格布局。
3. 半折叠态（Half-Folded / Table-Top Mode）：
   - 视频播放 / 相机场景必须支持桌面模式（上半屏内容、下半屏控制）。
   - 使用 `FoldingFeature.state == HALF_OPENED` 检测。
4. 禁止将关键交互元素（按钮、输入框）放置在铰链线上。
5. 使用 `WindowInfoTracker` 监听折叠状态变化。

```kotlin
val windowInfoTracker = WindowInfoTracker.getOrCreate(this)
lifecycleScope.launch {
    windowInfoTracker.windowLayoutInfo(this@Activity).collect { layoutInfo ->
        val foldingFeature = layoutInfo.displayFeatures
            .filterIsInstance<FoldingFeature>()
            .firstOrNull()
        if (foldingFeature?.state == FoldingFeature.State.HALF_OPENED) {
            // 切换到桌面模式布局
        }
    }
}
```

---

## 刘海屏与异形屏（MUST）

1. 必须采用 Edge-to-Edge 全屏显示策略（Android 15+ 强制要求）。
2. 使用 `WindowInsets` API 处理系统栏、刘海区域，禁止硬编码状态栏高度。
3. Compose 使用 `Modifier.windowInsetsPadding()` 或 `Modifier.safeDrawingPadding()`。
4. XML 使用 `android:fitsSystemWindows="true"` 或 `ViewCompat.setOnApplyWindowInsetsListener`。
5. 禁止在刘海 / 挖孔区域放置可交互元素（按钮、输入框）。
6. `AndroidManifest.xml` 中设置 `android:windowLayoutInDisplayCutoutMode="shortEdges"` 或更高。

```kotlin
// Edge-to-Edge 设置
enableEdgeToEdge()
setContent {
    Scaffold(
        modifier = Modifier.safeDrawingPadding()
    ) { innerPadding ->
        Content(modifier = Modifier.padding(innerPadding))
    }
}
```

---

## 多窗口与分屏（SHOULD）

1. 默认支持多窗口模式（Android 7.0+ 默认 `resizeableActivity=true`）。
2. 禁止设置 `resizeableActivity=false`（除非有充分理由并记录例外）。
3. 在多窗口模式下正确处理生命周期（`onMultiWindowModeChanged`）。
4. 禁止假定固定屏幕尺寸：使用 `WindowMetrics` 获取当前窗口大小，不使用 `DisplayMetrics`。
5. 画中画（Picture-in-Picture）：视频播放类应用推荐支持。

---

## 横屏模式（MUST — 分场景）

1. 媒体类应用（视频 / 相机 / 游戏）：必须支持横屏，且正确处理 Safe Area。
2. 工具类 / 业务类应用：推荐支持横屏；如锁定竖屏，必须在 `AndroidManifest.xml` 中声明 `screenOrientation`。
3. 横屏下导航与交互不得被系统栏遮挡。
4. 平板应用必须同时支持横屏和竖屏。

---

## 设备测试矩阵（MUST）

1. 发布前必须在以下最低设备覆盖上完成测试：

| 类别 | 最低要求 | 说明 |
|------|---------|------|
| 手机（小屏） | ≥ 1 款 | 屏宽 < 360dp（如 Galaxy A 系列低端） |
| 手机（标准） | ≥ 1 款 | 屏宽 360dp ~ 411dp（主流机型） |
| 手机（大屏） | ≥ 1 款 | 屏宽 > 411dp（Plus / Ultra 系列） |
| 平板 | ≥ 1 款（面向商店分发时） | 10 英寸以上 |
| 折叠屏 | ≥ 1 款（如已声明支持） | Samsung Fold / Pixel Fold |

2. 每个设备必须验证以下场景：
   - 竖屏 + 横屏（如支持）。
   - 系统字体缩放（默认、1.3x、最大）。
   - 深色模式。
   - 多窗口分屏（平板 / 折叠屏）。
3. 推荐使用 Firebase Test Lab 或 Android Emulator 覆盖更多设备。
4. CI 流水线中至少包含 1 款标准手机的 Instrumented Test。

---

## 导航与路由（MUST）

1. Compose 项目使用 **Navigation Compose**，XML 项目使用 **Navigation Component**。
2. 路由路径集中定义为常量或 sealed class。
3. Deep Link 配置必须在 `AndroidManifest.xml` 中声明。
4. Fragment（XML 项目）之间数据传递使用 Safe Args，禁止使用 `Bundle` 裸传递。

---

## 动画与过渡（SHOULD）

1. 页面转场使用 Material Motion 规范（共享元素、淡入淡出、容器变换）。
2. Compose 动画优先使用 `animate*AsState`、`AnimatedVisibility`、`AnimatedContent`。
3. 避免使用帧动画（`AnimationDrawable`），优先使用 Lottie 或属性动画。
4. 动画时长建议 150ms ~ 300ms，遵循 Material Motion 时长建议。
