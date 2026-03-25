# rules/ios/common/ui-framework.md

## 文档目标
1. 定义 iOS 应用的 UI 框架通用规范，覆盖 HIG、无障碍、适配等。

---

## Human Interface Guidelines（MUST）

1. 新项目必须遵循 Apple **Human Interface Guidelines**（HIG）。
2. 使用系统标准控件和交互模式，避免自定义不符合平台惯例的 UI。
3. 导航模式遵循 HIG 推荐：Tab Bar（主导航）+ Navigation Stack（层级导航）。
4. 系统图标优先使用 **SF Symbols**。

---

## 深色模式（MUST）

1. 应用必须支持深色模式（Dark Mode）。
2. 颜色定义必须同时提供 Light 和 Dark 变体（使用 Asset Catalog Color Set）。
3. 代码中引用颜色使用 `Color("colorName")`（SwiftUI）或 `UIColor(named:)`（UIKit）。
4. 禁止硬编码颜色值。
5. 图片资源需考虑深色模式适配（提供 dark 变体或使用 template 模式）。

---

## 无障碍（Accessibility）（MUST）

### VoiceOver
1. 所有可交互元素必须提供 `accessibilityLabel`。
2. 图片类元素提供 `accessibilityLabel` 描述内容，装饰性图片设置 `accessibilityHidden(true)`。
3. 自定义控件必须设置正确的 `accessibilityTraits`。

### Dynamic Type
1. 文本必须支持 Dynamic Type（系统字体缩放）。
2. SwiftUI 默认支持，UIKit 使用 `UIFontMetrics` 适配。
3. 布局必须适应大字体模式，禁止固定行高截断文本。
4. 推荐支持最大到 `xxxLarge` Accessibility 字体。

```swift
// SwiftUI - 自动支持 Dynamic Type
Text("Hello")
    .font(.body)

// UIKit - 使用 UIFontMetrics
let font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 16))
label.font = font
label.adjustsFontForContentSizeCategory = true
```

### 其他
1. 颜色不作为唯一信息传达方式（色盲友好）。
2. 触摸目标最小尺寸 44pt x 44pt。
3. 动画提供 Reduce Motion 替代方案。

---

## Safe Area 与布局（MUST）

1. 所有 UI 内容必须在 Safe Area 内展示，尊重刘海、Dynamic Island 和 Home Indicator 区域。
2. SwiftUI 使用 `.safeAreaInset` / `.ignoresSafeArea` 精确控制安全区域行为。
3. UIKit 使用 `safeAreaLayoutGuide` 约束布局，禁止手动计算状态栏高度。
4. 禁止在 Safe Area 外的区域放置可交互元素（按钮、输入框、链接）。
5. 背景色 / 背景图可以延伸到 Safe Area 外（Edge-to-Edge），但交互内容不可以。

---

## iPhone 机型适配（MUST）

1. 必须支持所有当前在售 iPhone 屏幕尺寸，禁止通过机型名称硬编码判断布局：

| 机型类别 | 屏幕特征 | 注意事项 |
|---------|---------|---------|
| iPhone SE (3rd) | 4.7" / Home Button / 无刘海 | 屏幕最小，注意内容不被截断 |
| iPhone 15/16 | 6.1" / Dynamic Island | 主流尺寸，基准适配目标 |
| iPhone 15/16 Plus/Max | 6.7" ~ 6.9" / Dynamic Island | 大屏需充分利用空间，避免过度留白 |

2. 使用 `Size Classes` 区分布局，不使用设备型号检测：
   - iPhone 竖屏：`Compact Width` + `Regular Height`。
   - iPhone 横屏：`Compact Width`（标准）或 `Regular Width`（Max 系列）+ `Compact Height`。
3. Dynamic Island 适配：
   - 不得在 Dynamic Island 区域放置关键 UI 内容。
   - 推荐使用 Live Activities 与 Dynamic Island 交互（ActivityKit）。
   - 使用 Safe Area 自动避让，无需特殊处理。
4. 支持系统字体缩放（Dynamic Type），布局不得在大字体下截断或重叠。
5. 横屏模式下需正确处理左右 Safe Area Inset（特别是有刘海 / Dynamic Island 的机型）。

```swift
// 正确做法：使用 Size Classes 而非机型判断
struct AdaptiveLayout: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass

    var body: some View {
        if hSizeClass == .compact {
            PhoneLayout()
        } else {
            TabletLayout()
        }
    }
}
```

---

## iPad 适配（MUST — 面向 App Store 分发的 Universal 应用）

1. 在 App Store 以 Universal 应用分发时，必须提供 iPad 优化布局，禁止直接拉伸 iPhone 布局。
2. iPad 布局必须使用 `Regular Width` Size Class 提供多列 / 侧边栏布局。
3. SwiftUI 使用 `NavigationSplitView` 实现侧边栏 + 内容 + 详情三栏结构。
4. UIKit 使用 `UISplitViewController`（主推 column-style API）。
5. iPad 导航模式：
   - 侧边栏导航（`NavigationSplitView`），禁止在 iPad 上使用底部 Tab Bar 作为唯一导航。
   - 推荐 Tab Bar + 侧边栏联合导航（iPadOS 18+ `TabView` 自动适配）。
6. 弹出框（Popover）：iPad 上使用 `.popover` 而非全屏 `.sheet`，保持空间感。

```swift
// iPad 三栏布局示例
NavigationSplitView {
    SidebarView()
} content: {
    ContentListView()
} detail: {
    DetailView()
}
```

---

## iPad 多任务（MUST — Universal 应用）

1. 必须支持 iPadOS 多任务场景，应用不得在窗口尺寸变化时崩溃或布局异常：

| 多任务模式 | 窗口比例 | Size Class |
|-----------|---------|------------|
| 全屏 | 100% | Regular Width |
| Split View（1/2） | 50% | Compact Width（部分设备 Regular） |
| Split View（1/3） | 33% | Compact Width |
| Split View（2/3） | 67% | Regular Width |
| Slide Over | 窄浮窗 | Compact Width |

2. 必须正确处理 Scene 生命周期（`UISceneDelegate` / SwiftUI `WindowGroup`）。
3. 推荐支持应用间拖放（Drag & Drop）：
   - 使用 `onDrag` / `onDrop`（SwiftUI）或 `UIDragInteraction` / `UIDropInteraction`（UIKit）。
   - 至少支持文本和图片的拖入。
4. Stage Manager（iPadOS 16+）：应用窗口可自由调整大小，布局必须响应任意窗口尺寸。
5. 必须支持指针（鼠标 / 触控板）输入：
   - 使用 `.hoverEffect`（SwiftUI）或 `UIPointerInteraction`（UIKit）提供悬停反馈。
   - 支持右键菜单（`contextMenu`）。
   - 推荐支持键盘快捷键（`keyboardShortcut`）。

---

## 横屏模式（MUST — 分场景）

1. 媒体类应用（视频播放器 / 相机 / 游戏）：必须支持横屏。
2. 生产力类应用：推荐支持横屏（iPad 用户经常横屏使用）。
3. 纯手机端应用如锁定竖屏，必须在 `Info.plist` 中明确声明 `UISupportedInterfaceOrientations`。
4. iPad 必须同时支持所有方向（Apple 审核要求）。
5. 横屏切换时禁止丢失用户输入状态（表单数据、滚动位置、播放进度）。
6. 横屏下的 Safe Area 左右 Inset 必须正确处理。

---

## 设备测试矩阵（MUST）

1. 发布前必须在以下最低设备覆盖上完成测试：

| 类别 | 最低要求 | 说明 |
|------|---------|------|
| iPhone（小屏） | ≥ 1 款 | iPhone SE 系列（4.7"），验证内容不截断 |
| iPhone（标准） | ≥ 1 款 | iPhone 15/16（6.1"），基准适配 |
| iPhone（大屏） | ≥ 1 款 | iPhone 15/16 Plus/Pro Max（6.7"+） |
| iPad | ≥ 1 款（Universal 应用） | iPad Air / iPad Pro，验证多栏布局 |
| iPad mini | 推荐 1 款 | 8.3" 屏幕，介于手机和标准 iPad 之间 |

2. 每个设备必须验证以下场景：
   - 竖屏 + 横屏（如支持）。
   - Dynamic Type：默认字号、Large、AX5（最大无障碍字号）。
   - 深色模式与浅色模式。
   - iPad 多任务：全屏、1/2 分屏、1/3 分屏、Slide Over。
   - VoiceOver 基础可用性。
3. 推荐使用 Xcode Simulator + 真机组合测试。
4. CI 流水线中至少包含 1 款标准 iPhone 的 UI Test。

---

## 动画与过渡（SHOULD）

1. 页面转场使用系统标准动画，避免自定义突兀的过渡效果。
2. SwiftUI 动画使用 `withAnimation`、`matchedGeometryEffect`。
3. UIKit 动画使用 `UIView.animate` 或 `UIViewPropertyAnimator`。
4. 动画时长建议 200ms ~ 350ms。
5. 尊重用户 Reduce Motion 设置（`UIAccessibility.isReduceMotionEnabled`）。
