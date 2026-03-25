# rules/ios/profiles/uikit/project-structure.md

## 文档目标
1. 定义 UIKit 项目的标准目录结构与规范（适用于旧项目维护）。

---

## 项目结构（MUST）

```text
ProjectName/
├── ProjectName.xcodeproj
├── Config/
│   ├── Base.xcconfig
│   ├── Debug.xcconfig
│   └── Release.xcconfig
├── ProjectName/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── AppCoordinator.swift          # 根 Coordinator
│   ├── DI/
│   │   └── DependencyContainer.swift
│   ├── UI/
│   │   ├── Base/                          # 基类
│   │   │   ├── BaseViewController.swift
│   │   │   └── BaseViewModel.swift
│   │   ├── Components/                    # 通用 UI 组件
│   │   │   ├── LoadingView.swift
│   │   │   └── ErrorView.swift
│   │   └── Features/                      # 按功能分包
│   │       ├── Home/
│   │       │   ├── HomeViewController.swift
│   │       │   ├── HomeViewModel.swift
│   │       │   ├── HomeCoordinator.swift
│   │       │   └── Views/
│   │       │       └── HomeCell.swift
│   │       └── Profile/
│   │           ├── ProfileViewController.swift
│   │           ├── ProfileViewModel.swift
│   │           └── ProfileCoordinator.swift
│   ├── Domain/
│   │   ├── Models/
│   │   ├── UseCases/
│   │   └── Repositories/
│   ├── Data/
│   │   ├── Local/
│   │   ├── Remote/
│   │   ├── Mappers/
│   │   └── Repositories/
│   ├── Common/
│   │   ├── Extensions/
│   │   ├── Utilities/
│   │   └── Constants.swift
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.strings
│       ├── LaunchScreen.storyboard
│       └── Info.plist
├── ProjectNameTests/
└── ProjectNameUITests/
```

---

## UIKit 规范（MUST）

### Coordinator 模式
1. 使用 **Coordinator** 模式管理导航，ViewController 禁止直接 `push` / `present` 其他 ViewController。
2. 每个 Feature 有独立的 Coordinator。
3. Coordinator 负责创建 ViewController 和 ViewModel，注入依赖。

```swift
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

final class HomeCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let container: DependencyContainer

    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = HomeViewModel(getUserUseCase: container.getUserUseCase)
        viewModel.coordinator = self
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showProfile(userId: Int) {
        let coordinator = ProfileCoordinator(
            navigationController: navigationController,
            container: container,
            userId: userId
        )
        coordinator.start()
    }
}
```

### ViewController 规范
1. ViewController 保持轻量，UI 逻辑通过 ViewModel 处理。
2. 布局使用代码（SnapKit 或原生 Auto Layout），禁止新增 Storyboard。
3. 已有 Storyboard 允许维护，新页面必须使用代码布局。

### 数据绑定
1. 使用 **Combine** 绑定 ViewModel 到 ViewController。
2. ViewModel 通过 `@Published` 暴露状态。
3. ViewController 在 `viewDidLoad` 中订阅，`cancellables` 在 `deinit` 中自动释放。

```swift
final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("不使用 Storyboard") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        Task { await viewModel.loadUser() }
    }

    private func bindViewModel() {
        viewModel.$uiState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(with: state)
            }
            .store(in: &cancellables)
    }
}
```

### UICollectionView / UITableView
1. 必须使用 `UICollectionViewDiffableDataSource` 或 `UITableViewDiffableDataSource`。
2. 禁止使用 `reloadData()` 全量刷新（使用 `apply(snapshot)`）。
3. Cell 注册使用 `register` 方法，禁止使用 Storyboard Prototype Cell。

---

## 迁移建议

对于需要从 UIKit 迁移到 SwiftUI 的项目：
1. 优先新增页面使用 SwiftUI。
2. 已有 UIKit 页面通过 `UIHostingController` 嵌入 SwiftUI View。
3. SwiftUI View 中嵌入 UIKit 组件使用 `UIViewRepresentable`。
4. ViewModel 保持协议统一，SwiftUI 和 UIKit 共用。
5. 迁移过程中同时遵守 `common/*` 和 `profiles/swiftui/*` 规则。
