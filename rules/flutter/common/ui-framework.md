# rules/flutter/common/ui-framework.md

## 文档目标
1. 定义 Flutter 应用的 UI 框架通用规范，覆盖设计系统、主题、导航、无障碍。

---

## 设计系统（MUST）

1. 默认遵循 **Material Design 3** 设计规范，使用 `material3: true`。
2. iOS 专属交互场景推荐使用 Cupertino 组件（`CupertinoAlertDialog` / `CupertinoPicker`）。
3. 推荐使用 `adaptive` 后缀组件自动适配平台风格（如 `Switch.adaptive`、`Slider.adaptive`）。
4. 禁止混用 Material 2 与 Material 3 组件（统一使用 M3）。

---

## 主题管理（MUST）

1. 必须使用 `ThemeData` 集中定义主题，禁止在组件中硬编码颜色 / 字体。
2. 必须同时定义 Light 和 Dark 主题：

```dart
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ThemeMode.system,
);
```

3. 颜色使用 Material 3 Color Scheme（`ColorScheme.fromSeed` 或自定义）。
4. 排版使用 `TextTheme`，禁止直接使用 `TextStyle(fontSize: 16)` 硬编码。
5. 间距 / 圆角 / 阴影使用统一的 Design Token 常量：

```dart
abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract class AppRadius {
  static const sm = Radius.circular(4);
  static const md = Radius.circular(8);
  static const lg = Radius.circular(16);
}
```

---

## 导航（MUST）

1. 必须使用声明式路由方案，推荐 **GoRouter** 或 **auto_route**。
2. 路由路径集中定义为常量：

```dart
abstract class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const orderDetail = '/orders/:id';
  static const settings = '/settings';
}
```

3. Deep Link 配置必须在 `AndroidManifest.xml` 和 `Info.plist` 中声明。
4. 页面间参数传递使用类型化参数（路由库支持的 `$extra` 或 typed params），禁止字符串拼接。
5. 路由守卫（Guard / Redirect）统一处理鉴权跳转，禁止在各页面分散判断。

---

## 国际化（SHOULD）

1. 面向多语言市场的应用推荐使用 `flutter_localizations` + `intl` 包。
2. 文本禁止硬编码在 Widget 中，必须通过 `AppLocalizations` 引用。
3. 日期 / 数字 / 货币格式化使用 `intl` 包的 `DateFormat` / `NumberFormat`。
4. RTL（从右到左）布局使用 `Directionality` 自动适配，禁止使用 `left` / `right`，应使用 `start` / `end`。

---

## 无障碍（MUST）

1. 所有可交互元素必须提供 `Semantics` 标签：
   - `Image` / `Icon`：提供 `semanticLabel`。
   - 装饰性图片：设置 `excludeFromSemantics: true`。
   - 自定义手势组件：包裹 `Semantics` Widget。
2. 触摸目标最小尺寸 48 x 48 逻辑像素。
3. 颜色不作为唯一信息传达方式（色盲友好）。
4. 文本对比度符合 WCAG 2.1 AA 标准（普通文本 4.5:1，大文本 3:1）。
5. 支持系统字体缩放（`MediaQuery.textScaleFactor`），布局不得在大字体下截断。
6. 动画提供 Reduce Motion 替代方案：

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
if (reduceMotion) {
  // 使用简单的淡入淡出替代复杂动画
}
```

---

## 深色模式（MUST）

1. 应用必须支持深色模式（Dark Theme）。
2. 使用 `ThemeMode.system` 跟随系统设置，同时提供手动切换选项。
3. 图片资源需考虑深色模式（透明背景或提供 dark 变体）。
4. 禁止硬编码颜色值，必须通过 `Theme.of(context).colorScheme` 引用。

---

## 动画（SHOULD）

1. 页面转场使用路由库内置动画或 Material Motion 规范。
2. 微交互动画时长建议 150ms ~ 300ms。
3. 优先使用隐式动画（`AnimatedContainer` / `AnimatedOpacity`），复杂场景使用显式动画。
4. 尊重用户 Reduce Motion 设置。
