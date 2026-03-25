# rules/android/common/performance.md

## 文档目标
1. 定义 Android 应用的性能优化规范，覆盖启动、内存、渲染、电量等。

---

## 冷启动优化（MUST）

1. `Application.onCreate()` 中禁止执行耗时初始化，必须延迟或异步。
2. 推荐使用 **App Startup** 库管理初始化依赖顺序。
3. 冷启动时间目标：< 1 秒（应用进程创建 → 首帧绘制）。
4. 发布前必须使用 **Baseline Profile** 优化关键启动路径。

```kotlin
class AppInitializer : Initializer<Unit> {
    override fun create(context: Context) {
        // 轻量初始化
    }
    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}
```

---

## 内存管理（MUST）

1. 开发阶段必须集成 **LeakCanary** 检测内存泄漏。
2. Activity/Fragment 中禁止持有长生命周期对象的强引用。
3. Bitmap 加载必须使用 **Coil**（Compose）或 **Glide** 图片加载库，禁止手动 decode。
4. 大列表使用 `LazyColumn`（Compose）或 `RecyclerView`（XML），禁止 `ScrollView` + 动态添加 View。
5. `onTrimMemory` 回调中释放非关键缓存。

---

## 渲染性能（MUST）

1. UI 渲染必须保持 60fps（16ms/帧），复杂页面目标 90fps。
2. Compose：避免在 Composition 中执行耗时计算，使用 `remember` / `derivedStateOf` 缓存。
3. XML：减少布局嵌套层级（推荐 `ConstraintLayout`），避免 `RelativeLayout` 嵌套。
4. 禁止在 `onDraw()` / Composable 函数中创建对象（Paint、Path 等复用）。
5. 长列表 Item 使用 `key` 参数优化 diff（Compose `LazyColumn { items(key = { it.id }) }`）。

---

## 电量优化（MUST）

1. 后台任务使用 **WorkManager**，禁止使用 `AlarmManager` + `BroadcastReceiver` 组合。
2. 网络请求合并批量执行，避免频繁唤醒网络。
3. 定位请求使用最低精度满足需求，及时移除定位监听。
4. 推送使用 FCM，禁止自建长连接保活。

---

## 包体积优化（SHOULD）

1. 启用 R8 代码缩减与资源缩减（`isMinifyEnabled = true`、`isShrinkResources = true`）。
2. 图片资源优先使用 Vector Drawable，位图使用 WebP 格式。
3. so 库按 ABI 拆分（`splits.abi`），或使用 App Bundle 按需分发。
4. 移除未使用的依赖和资源（`./gradlew lint` 检查 unused resources）。

---

## 禁止事项

1. 禁止在主线程执行数据库查询、网络请求、文件 IO。
2. 禁止在 `RecyclerView.onBindViewHolder` / Composable 中执行耗时操作。
3. 禁止使用 `Thread.sleep()` 实现延迟逻辑（应使用 `delay()` 或 `Handler.postDelayed`）。
4. 禁止在循环中频繁创建对象（字符串拼接使用 `StringBuilder`）。
