# rules/ios/common/performance.md

## 文档目标
1. 定义 iOS 应用的性能优化规范，覆盖启动、内存、渲染、包体积等。

---

## 冷启动优化（MUST）

1. `application(_:didFinishLaunchingWithOptions:)` 中禁止执行耗时初始化，必须延迟或异步。
2. 冷启动时间目标：< 400ms（Pre-main + Post-main）。
3. 减少动态库数量，推荐合并为静态库或 Framework。
4. 使用 Instruments（App Launch template）分析启动瓶颈。
5. `+load` 方法中禁止执行耗时操作（Objective-C 遗留代码注意）。

---

## 内存管理（MUST）

### ARC 循环引用防护
1. Closure 捕获 `self` 时使用 `[weak self]` 或 `[unowned self]`。
2. Delegate 属性使用 `weak` 修饰。
3. 定时器（Timer）使用 `[weak self]` 避免循环引用。
4. Combine 订阅使用 `store(in: &cancellables)` 并在 `deinit` 中自动取消。

```swift
class HomeViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    func observe() {
        notificationCenter.publisher(for: .userDidLogin)
            .sink { [weak self] _ in
                self?.refreshData()
            }
            .store(in: &cancellables)
    }
}
```

### 内存使用规范
1. 大图使用 `UIImage` 的缩略图 API 或 `ImageIO` 按需解码。
2. 列表中图片使用异步加载 + 缓存（AsyncImage / SDWebImage / Kingfisher）。
3. 使用 Instruments（Leaks / Allocations）定期检测内存泄漏。
4. 内存警告时释放非关键缓存（`applicationDidReceiveMemoryWarning`）。

---

## 渲染性能（MUST）

1. UI 渲染必须保持 60fps（16ms/帧），ProMotion 设备目标 120fps。
2. SwiftUI：避免在 `body` 计算中执行耗时操作，使用 `@State` / `@StateObject` 缓存。
3. UIKit：避免在 `layoutSubviews` 中频繁创建对象。
4. 列表使用 `List` / `LazyVStack`（SwiftUI）或 `UICollectionView`（UIKit），配合 cell 复用。
5. 复杂视图启用离屏渲染优化，避免 `cornerRadius` + `masksToBounds` 组合。

---

## 网络性能（SHOULD）

1. API 响应启用 HTTP 缓存（`URLCache`），减少重复请求。
2. 图片使用 CDN 加速，支持 WebP 格式。
3. 数据同步使用增量更新，避免全量拉取。
4. 大文件使用断点续传。

---

## 包体积优化（SHOULD）

1. 启用 Bitcode（Xcode 自动优化，已在 Xcode 14+ 废弃，关注 App Thinning）。
2. 图片资源使用 Asset Catalog，启用 App Thinning 按设备分发。
3. 移除未使用的代码和资源（`periphery` 工具检测）。
4. 避免引入体积过大的第三方库，优先使用系统 API。

---

## 禁止事项

1. 禁止在主线程执行网络请求、数据库操作、文件 IO。
2. 禁止在 `cellForRowAt` / Composable `body` 中执行耗时计算。
3. 禁止使用 `DispatchQueue.main.sync` 从后台线程同步到主线程（死锁风险）。
4. 禁止强持有 Delegate（使用 `weak`）。
5. 禁止在循环中频繁创建 `DateFormatter`（应复用）。
