# rules/electron-desktop/common/performance.md

## 文档目标
1. 定义 Electron 桌面应用的性能优化规范。

---

## 启动性能（MUST）

1. 应用冷启动到主窗口可见必须 <= 3 秒。
2. 启动阶段仅加载必要资源，非关键初始化延迟到窗口显示后。
3. 渲染进程首屏使用骨架屏或 Loading 状态，避免白屏等待。
4. 主进程 `app.whenReady()` 后立即创建窗口，禁止在 `ready` 事件前执行耗时操作。

```typescript
app.whenReady().then(async () => {
  createMainWindow();
  // 非关键初始化异步执行
  setTimeout(() => {
    initNonCriticalServices();
  }, 0);
});
```

5. 推荐使用 `v8-compile-cache` 或 Electron 的 V8 快照加速主进程启动。

---

## 内存管理（MUST）

1. 大数据集使用分页/虚拟滚动，禁止一次性加载全量数据到渲染进程。
2. 图片资源使用懒加载，超出视口的图片延迟加载。
3. 关闭的窗口必须及时销毁（`win.destroy()`），防止内存泄漏。
4. IPC 事件监听器必须在不需要时移除。
5. 长生命周期的缓存设置上限和淘汰策略。

---

## IPC 性能（MUST）

1. 单次 IPC 传输数据量控制在 1MB 以内，大数据使用分页或流式传输。
2. 高频操作（如搜索输入）使用防抖（debounce），避免频繁 IPC 调用。
3. 批量操作合并为单次 IPC 调用，禁止循环中逐条调用 IPC。
4. IPC 返回的数据结构精简，仅包含渲染进程展示所需字段。

---

## 渲染性能（SHOULD）

1. 长列表使用虚拟滚动（`react-virtuoso`、`vue-virtual-scroller` 等）。
2. 复杂动画使用 CSS Animation / `requestAnimationFrame`，避免 JavaScript 驱动。
3. 避免频繁 DOM 操作，使用框架的批量更新机制。
4. 渲染进程独立于主进程，禁止主进程同步计算阻塞 IPC 响应。

---

## 构建优化（SHOULD）

1. 主进程代码使用 Tree Shaking 和代码分割，减小打包体积。
2. 渲染进程构建启用 Tree Shaking、代码分割、资源压缩。
3. 使用 `@electron/asar` 打包应用资源，加速文件读取。
4. 最终安装包体积目标：Windows < 80MB、macOS < 70MB、Linux < 70MB（含 Chromium 运行时）。

---

## Electron 特有优化（SHOULD）

1. 在不需要 GPU 加速的场景下，禁用硬件加速以降低内存占用：
   ```typescript
   app.disableHardwareAcceleration();
   ```
2. 非活跃窗口使用 `backgroundThrottling` 降低 CPU 消耗。
3. 使用 `BrowserWindow.setBackgroundColor` 设置窗口背景色，减少白屏感知。
