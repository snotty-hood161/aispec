# rules/flutter/common/performance.md

## 文档目标
1. 定义 Flutter 应用的性能优化规范，覆盖渲染、内存、启动、包体积。

---

## Widget 构建优化（MUST）

1. `build()` 方法中禁止执行耗时操作（网络请求、数据库查询、复杂计算）。
2. 不可变 Widget 必须标记为 `const`，减少不必要的重建：

```dart
// 正确：使用 const
const SizedBox(height: 16);
const Icon(Icons.home, size: 24);
const Text('固定文本');

// 错误：未使用 const
SizedBox(height: 16); // 每次 build 都会创建新实例
```

3. 拆分大型 Widget 树为独立的小 Widget 类（而非方法），利用 Flutter 的 Element 复用机制。
4. 状态仅影响部分子树时，将 `StatefulWidget` 或状态管理下沉到受影响的子树，避免整棵树重建。
5. 使用 `const` 构造函数拦截重建传播。

---

## 列表性能（MUST）

1. 长列表必须使用 `ListView.builder` / `GridView.builder` 按需构建，禁止 `ListView(children: [...])` 一次性构建。
2. 列表项必须提供稳定的 `key`（基于业务 ID），优化 diff 算法。
3. 列表中图片使用 `cached_network_image` 或等效方案，支持占位图 + 渐进式加载。
4. 禁止在 `itemBuilder` 中创建新的 Stream / Future 订阅。
5. 复杂列表项推荐使用 `RepaintBoundary` 隔离重绘区域。

---

## 渲染性能（MUST）

1. UI 渲染帧率目标：60fps（16ms/帧），高刷设备 120fps（8ms/帧）。
2. 开发阶段必须使用 Flutter DevTools Performance 面板检测掉帧。
3. 避免不必要的 `ClipRRect` / `Opacity` / `ShaderMask` 嵌套（触发离屏渲染）。
4. 自定义 `CustomPaint` 中复用 `Paint` / `Path` 对象，禁止在 `paint()` 中创建。
5. 动画使用 `AnimatedBuilder` / `AnimatedWidget`，避免触发非动画区域重建。

---

## 启动优化（MUST）

1. 应用冷启动时间目标：< 2 秒（应用进程创建 → 首帧绘制）。
2. `main()` 函数中仅保留必要初始化，非关键初始化延迟到首页加载后。
3. 启动时使用原生 Splash Screen（`flutter_native_splash`），避免白屏。
4. 推荐使用 Deferred Components（按需加载）减少初始加载体积。
5. 禁止在启动路径中执行同步文件 IO 或大量 JSON 解析。

---

## 内存管理（MUST）

1. 大图使用 `ResizeImage` 或 `cacheWidth` / `cacheHeight` 限制解码尺寸。
2. 页面销毁时必须取消 Stream 订阅、Timer、AnimationController：

```dart
class _MyPageState extends State<MyPage> {
  late final StreamSubscription _subscription;
  late final AnimationController _controller;

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }
}
```

3. 禁止在全局范围持有 `BuildContext` 引用。
4. 使用 Flutter DevTools Memory 面板定期检查内存泄漏。

---

## Isolate 与计算密集型任务（MUST）

1. 计算密集型任务（JSON 大文件解析、图片处理、加密运算）必须在后台 Isolate 中执行。
2. 简单任务使用 `compute()` 函数，复杂长连接任务使用 `Isolate.spawn()`。
3. 禁止在主 Isolate 中执行 > 16ms 的同步计算。

---

## 包体积优化（SHOULD）

1. 使用 `--analyze-size` 分析构建产物体积分布：
   ```bash
   flutter build apk --analyze-size
   ```
2. 移除未使用的 package（`dart pub deps --no-dev` 审查）。
3. 图片资源使用 WebP 格式，矢量图使用 SVG（`flutter_svg`）。
4. 字体文件仅包含实际使用的字重（使用 `font-subset`）。
5. 按平台拆分原生库（Android ABI split，iOS App Thinning）。

---

## 网络性能（SHOULD）

1. API 响应推荐使用 ETag / Last-Modified 缓存策略。
2. 图片使用 CDN 加速，支持质量参数（按网络条件选择质量）。
3. 大量数据同步使用增量更新，避免全量拉取。
4. 弱网环境下提供加载超时提示和重试机制。

---

## 禁止事项

1. 禁止在 `build()` 方法中执行网络请求或数据库操作。
2. 禁止在 `itemBuilder` 中创建新的 Controller / Stream。
3. 禁止在主 Isolate 中执行 > 16ms 的同步计算。
4. 禁止全局持有 `BuildContext` 引用。
5. 禁止使用 `ListView(children: [...])` 渲染长列表。
