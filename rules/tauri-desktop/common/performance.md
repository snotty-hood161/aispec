# rules/tauri-desktop/common/performance.md

## 文档目标
1. 定义 Tauri 桌面应用的性能优化规范。

---

## 启动性能（MUST）

1. 应用冷启动到主窗口可见必须 <= 3 秒。
2. 启动阶段仅加载必要资源，非关键初始化延迟到窗口显示后。
3. 前端首屏使用骨架屏或 Loading 状态，避免白屏等待。
4. Rust 侧初始化使用 `setup` 钩子异步执行，禁止阻塞窗口创建。

```rust
// 正确：异步初始化
.setup(|app| {
    let handle = app.handle().clone();
    tauri::async_runtime::spawn(async move {
        // 数据库初始化、缓存预热等
        init_services(&handle).await;
    });
    Ok(())
})
```

---

## 内存管理（MUST）

1. 大数据集使用分页/虚拟滚动，禁止一次性加载全量数据到前端。
2. 图片资源使用懒加载，超出视口的图片延迟加载。
3. Rust 侧避免不必要的 `clone()`，优先使用引用和借用。
4. 长生命周期的缓存设置上限和淘汰策略。

---

## IPC 性能（MUST）

1. 单次 IPC 传输数据量控制在 1MB 以内，大数据使用分页或流式传输。
2. 高频操作（如搜索输入）使用防抖（debounce），避免频繁 IPC 调用。
3. 批量操作合并为单次 IPC 调用，禁止循环中逐条调用 `invoke()`。
4. IPC 返回的数据结构精简，仅包含前端展示所需字段。

---

## 渲染性能（SHOULD）

1. 长列表使用虚拟滚动（`react-virtuoso`、`vue-virtual-scroller` 等）。
2. 复杂动画使用 CSS Animation / `requestAnimationFrame`，避免 JavaScript 驱动。
3. 避免频繁 DOM 操作，使用框架的批量更新机制。
4. WebView 渲染性能受限于系统 WebView 引擎，避免过度复杂的 CSS 效果。

---

## 构建优化（SHOULD）

1. Rust 发布构建启用 LTO（Link-Time Optimization）和 `strip`：
   ```toml
   # Cargo.toml
   [profile.release]
   lto = true
   strip = true
   codegen-units = 1
   opt-level = "s"  # 优化体积
   ```
2. 前端构建启用 Tree Shaking、代码分割、资源压缩。
3. 最终安装包体积目标：Windows < 15MB、macOS < 12MB、Linux < 10MB。
