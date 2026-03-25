# rules/react-native/common/performance.md

## 文档目标
1. 定义 React Native 应用的性能优化规范，覆盖列表、图片、JS 线程、原生桥调用、启动优化。

---

## 列表优化（MUST）

1. 长列表必须使用 `FlatList` / `SectionList` 按需渲染，禁止使用 `ScrollView` + `map()` 一次性渲染。
2. 大数据量列表（> 100 项）推荐使用 **FlashList**（`@shopify/flash-list`）替代 `FlatList`，性能提升显著。
3. 列表项必须提供稳定的 `keyExtractor`（基于业务 ID），禁止使用 `index` 作为 key。
4. `renderItem` 中的组件必须使用 `React.memo` 包裹，避免父组件刷新导致所有列表项重渲染。
5. 列表中传递给子组件的回调函数必须使用 `useCallback` 包裹。
6. FlatList 必须配置性能参数：

```tsx
<FlashList
  data={orders}
  renderItem={renderOrderItem}
  keyExtractor={(item) => item.id}
  estimatedItemSize={120}
  drawDistance={300}
/>

// 或 FlatList
<FlatList
  data={orders}
  renderItem={renderOrderItem}
  keyExtractor={(item) => item.id}
  windowSize={5}
  maxToRenderPerBatch={10}
  initialNumToRender={10}
  removeClippedSubviews={true}
  getItemLayout={(data, index) => ({ length: 120, offset: 120 * index, index })}
/>
```

7. 列表项中禁止创建新的 `StyleSheet.create()` 调用（样式必须在模块级定义）。
8. 嵌套列表（列表内嵌列表）禁止使用 `FlatList` 嵌套 `FlatList`，改用 `SectionList` 或扁平化数据。

---

## 图片优化（MUST）

1. 网络图片必须使用 **react-native-fast-image**（FastImage）加载，支持缓存与优先级控制。
2. 图片必须指定 `width` 和 `height`（或 `aspectRatio`），避免布局抖动。
3. 列表中的图片推荐使用缩略图 URL（后端支持图片裁剪参数），减少内存占用。
4. 大图展示推荐使用渐进式加载（先加载低分辨率占位图，再加载高清图）。
5. 本地图片资源推荐使用 WebP 格式（体积比 PNG 小 25-35%）。
6. 禁止在列表项中加载原始尺寸大图（> 1MB）。

---

## JS 线程优化（MUST）

1. JS 线程帧率目标：60fps（16ms/帧），禁止执行 > 16ms 的同步计算。
2. 计算密集型任务推荐方案：
   - 使用 `InteractionManager.runAfterInteractions()` 延迟到动画完成后执行。
   - 使用 **react-native-reanimated** worklet 在 UI 线程执行动画计算。
   - 大量数据处理使用 `requestIdleCallback` 或分片执行。
3. 禁止在渲染周期（render 函数）中执行副作用操作（网络请求、存储读写、定时器创建）。
4. `useMemo` / `useCallback` 用于缓存昂贵计算和回调引用，但禁止滥用（仅在确有性能问题时使用）。
5. 推荐使用 **Flipper** / **React DevTools Profiler** 分析组件重渲染。

---

## 原生桥调用优化（MUST）

1. 禁止在循环中高频调用原生桥方法（每次调用有序列化 / 反序列化开销）。
2. 批量数据操作推荐一次性传递（而非多次单条传递）：

```typescript
// 正确：批量传递
await nativeModule.batchInsert(items);

// 错误：循环逐条调用
for (const item of items) {
  await nativeModule.insert(item); // 禁止
}
```

3. 动画操作推荐使用 **react-native-reanimated**（在 UI 线程执行），避免 JS ↔ Native 频繁通信。
4. 手势处理推荐使用 **react-native-gesture-handler**（在原生线程处理），避免 JS 线程瓶颈。
5. 支持 New Architecture（Fabric / TurboModules）的项目推荐迁移以减少桥调用开销。

---

## 启动优化（MUST）

1. 应用冷启动时间目标：< 2 秒（应用进程创建 → 首屏内容可见）。
2. `index.js` / `App.tsx` 中仅保留必要初始化，非关键初始化延迟到首页加载后：

```typescript
// 立即初始化（启动阻塞）
Sentry.init({ ... });
const secureStorage = new MMKV({ ... });

// 延迟初始化（首屏渲染后）
InteractionManager.runAfterInteractions(() => {
  analytics.init();
  codePush.sync();
  remoteConfig.fetchAndActivate();
});
```

3. 启动时使用原生 Splash Screen（**react-native-bootsplash** 或 **expo-splash-screen**），避免白屏。
4. 推荐启用 Metro 的 `inline requires`（`metro.config.js` 中 `getTransformOptions`），减少启动时模块加载量。
5. 推荐使用 Hermes 的预编译 bytecode（`.hbc`），减少 JS 解析时间。
6. 禁止在启动路径中执行同步文件 IO 或大量 JSON 解析。

---

## 内存管理（MUST）

1. 页面卸载时必须清理副作用：取消网络请求、清除定时器、取消事件监听。
2. `useEffect` 必须返回清理函数：

```typescript
useEffect(() => {
  const subscription = eventEmitter.addListener('event', handler);
  return () => subscription.remove();
}, []);
```

3. 禁止在组件外部全局持有组件引用或状态对象（造成内存泄漏）。
4. 大图在离开可视区域后推荐释放（FlashList / FlatList 的 `removeClippedSubviews`）。
5. 使用 Flipper Memory Plugin 或 Xcode Instruments / Android Profiler 定期检查内存泄漏。

---

## 包体积优化（SHOULD）

1. 使用 **react-native-bundle-visualizer** 或 **source-map-explorer** 分析 JS Bundle 体积。
2. 移除未使用的依赖（`npx depcheck`）。
3. 图片资源使用 WebP 格式，矢量图使用 SVG（`react-native-svg`）。
4. 推荐按需加载非核心模块（React.lazy + Suspense，需 React 18+）。
5. Android ABI 拆分（`abiFilters`），仅包含目标架构。
6. 字体文件仅包含实际使用的字重。

---

## 动画性能（MUST）

1. 复杂动画必须使用 **react-native-reanimated**，在 UI 线程执行，避免 JS 线程阻塞。
2. 禁止使用 `Animated` API 实现高频动画（如手势跟随），必须使用 Reanimated 的 `useAnimatedStyle`。
3. 页面转场动画推荐使用 React Navigation 的 `@react-navigation/native-stack`（基于原生导航栈）。
4. 骨架屏 / Loading 动画推荐使用 Lottie（`lottie-react-native`），减少自定义动画开发成本。

---

## 禁止事项

1. 禁止使用 `ScrollView` + `map()` 渲染长列表。
2. 禁止使用 `index` 作为 `FlatList` 的 `key`。
3. 禁止在 `renderItem` / 渲染函数中执行网络请求或存储操作。
4. 禁止在循环中高频调用原生桥方法。
5. 禁止在启动路径中执行同步阻塞操作。
6. 禁止在列表项中加载未裁剪的原始大图。
