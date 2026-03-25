# rules/dotnet-desktop/common/performance.md

## 文档目标
1. 定义 C#/.NET 桌面应用性能约束，涵盖 UI 响应性、启动性能、内存管理、渲染优化。
2. 线程模型参见 `common/threading-and-ui.md`。

---

## UI 响应性（MUST）

1. UI 线程帧率目标 >= 60fps，单帧处理时间 <= 16ms，禁止在 UI 线程执行 > 50ms 的操作。
2. 以下操作必须在后台线程执行，禁止在 UI 线程同步执行：
   - 文件 I/O（读写、搜索）。
   - 网络请求（API 调用、下载）。
   - 数据库查询和写入。
   - 大量数据处理（排序、过滤、转换）。
   - 图片解码和处理。
3. 长列表/数据表格必须使用虚拟化（Virtualization）：
   - WPF：`VirtualizingStackPanel`，设置 `VirtualizingPanel.IsVirtualizing="True"`。
   - MAUI：`CollectionView` 默认虚拟化。
   - WinForms：`DataGridView` 虚拟模式。
4. 大数据集加载必须分页或增量加载（Incremental Loading），禁止一次性加载全部数据到内存。

检查方式：UI 响应性测试 + Profiling
阻断级别：阻断合并

---

## 启动性能（MUST）

1. 应用冷启动时间目标：<= 3 秒显示主窗口，<= 5 秒可交互。
2. 启动阶段策略：
   - **必须在启动前完成**：配置加载、日志初始化、DI 容器构建。
   - **可以延迟加载**：非首屏数据、缓存预热、后台服务启动、插件加载。
3. 闪屏页（Splash Screen）必须在应用启动时立即显示，耗时初始化在后台进行。
4. 禁止在启动路径中执行网络请求（除非是强制登录流程），网络请求应在主窗口显示后异步执行。
5. 启动阶段必须记录关键时间节点日志，便于排查启动性能劣化。

### SHOULD
1. 考虑使用 ReadyToRun（R2R）或 NativeAOT 编译减少 JIT 开销，加快启动速度。
2. 使用 `dotnet-trace` 采集启动热路径，优化耗时模块。
3. 懒加载（Lazy Loading）非首屏页面和窗口的 ViewModel 和依赖。

检查方式：启动时间测量 + Profiling
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）

---

## 内存管理（MUST）

1. 大对象（> 85KB）禁止高频创建，必须使用 `ArrayPool<T>` 或 `ObjectPool<T>` 复用。
2. 图片资源必须正确释放，WPF 中 `BitmapImage` 使用 `CacheOption = OnLoad` 后立即释放流。
3. 事件订阅必须在对象销毁时取消（`-=` 或使用弱事件模式 `WeakEventManager`），防止内存泄漏。
4. `IDisposable` 对象必须及时释放，ViewModel 卸载时必须释放持有的资源。
5. 页面/窗口关闭后，对应的 ViewModel 和数据必须可被 GC 回收，禁止因事件订阅或静态引用导致泄漏。
6. 禁止在循环中使用字符串拼接（`+=`），必须使用 `StringBuilder`。

### 常见内存泄漏模式及预防
| 泄漏模式 | 预防措施 |
|---------|---------|
| 事件未取消订阅 | 使用 `WeakEventManager` 或在 `Unloaded`/`Dispose` 中 `-=` |
| 静态引用持有 ViewModel | 禁止静态集合持有 ViewModel 引用 |
| Timer 未停止 | 在 ViewModel 卸载时停止并释放 Timer |
| BindingSource 未清理 | 窗口关闭前清理绑定数据源 |
| 大图片未释放 | 使用 `CacheOption = OnLoad`，显式释放流 |

### SHOULD
1. 使用 Server GC（`<ServerGarbageCollection>true</ServerGarbageCollection>`）提升 GC 性能（多核场景）。
2. 定期通过 `dotnet-dump` / Visual Studio Diagnostic Tools 分析内存快照，检测泄漏。
3. 内存使用超过基线 2 倍时触发告警日志。

检查方式：内存分析 + 代码审查
阻断级别：阻断合并

---

## 渲染性能（MUST — WPF/MAUI）

1. 禁止在数据模板（`DataTemplate`）中嵌套过深的可视化树（建议 <= 10 层），过深会导致布局计算和渲染开销急剧增加。
2. 频繁更新的 UI 元素优先使用轻量级控件（如 `TextBlock` 而非 `Label`）。
3. 大量数据变更时使用批量更新，禁止逐条触发 UI 刷新：
   - 先收集变更，一次性替换 `ObservableCollection` 或使用 `CollectionViewSource.DeferRefresh()`。
4. 动画必须使用硬件加速（WPF 的 `RenderTransform` 而非 `LayoutTransform`），避免触发布局重计算。
5. 图片控件必须设置 `DecodePixelWidth`/`DecodePixelHeight`，禁止以原始分辨率加载大图后缩放显示。

### SHOULD
1. 使用 WPF Performance Suite / MAUI Diagnostics 工具检测渲染瓶颈。
2. 复杂布局考虑使用 `Canvas` + 手动定位替代多层嵌套 `Grid`/`StackPanel`。

检查方式：渲染性能测试 + Profiling
阻断级别：阻断合并（MUST 项）/ 告警记录（SHOULD 项）
