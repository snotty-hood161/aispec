# rules/ios/profiles/swiftui/project-structure.md

## 文档目标
1. 定义 SwiftUI 项目的标准目录结构与最佳实践。

---

## 项目结构（MUST）

```text
ProjectName/
├── ProjectName.xcodeproj (或 .xcworkspace)
├── Config/
│   ├── Base.xcconfig
│   ├── Debug.xcconfig
│   ├── Staging.xcconfig
│   └── Release.xcconfig
├── ProjectName/
│   ├── App/
│   │   ├── ProjectNameApp.swift          # @main 入口
│   │   └── ContentView.swift             # 根视图
│   ├── DI/
│   │   └── DependencyContainer.swift     # 依赖注入容器
│   ├── UI/
│   │   ├── Navigation/
│   │   │   ├── AppRouter.swift           # 路由管理
│   │   │   └── Routes.swift              # 路由定义
│   │   ├── Components/                   # 通用 UI 组件
│   │   │   ├── LoadingView.swift
│   │   │   ├── ErrorView.swift
│   │   │   └── EmptyStateView.swift
│   │   ├── Modifiers/                    # 自定义 ViewModifier
│   │   │   └── ShimmerModifier.swift
│   │   └── Features/                     # 按功能分包
│   │       ├── Home/
│   │       │   ├── HomeView.swift
│   │       │   ├── HomeViewModel.swift
│   │       │   ├── HomeUiState.swift
│   │       │   └── Components/           # 功能专属组件
│   │       │       └── HomeCard.swift
│   │       ├── Profile/
│   │       │   ├── ProfileView.swift
│   │       │   ├── ProfileViewModel.swift
│   │       │   └── ProfileUiState.swift
│   │       └── Settings/
│   │           ├── SettingsView.swift
│   │           └── SettingsViewModel.swift
│   ├── Domain/
│   │   ├── Models/
│   │   │   └── User.swift
│   │   ├── UseCases/
│   │   │   └── GetUserUseCase.swift
│   │   └── Repositories/                # Repository 协议
│   │       └── UserRepositoryProtocol.swift
│   ├── Data/
│   │   ├── Local/
│   │   │   ├── SwiftData/
│   │   │   │   └── UserEntity.swift
│   │   │   └── UserDefaultsStore.swift
│   │   ├── Remote/
│   │   │   ├── API/
│   │   │   │   └── UserAPI.swift
│   │   │   ├── DTOs/
│   │   │   │   └── UserDTO.swift
│   │   │   └── NetworkClient.swift
│   │   ├── Mappers/
│   │   │   └── UserMapper.swift
│   │   └── Repositories/                # Repository 实现
│   │       └── UserRepository.swift
│   ├── Common/
│   │   ├── Extensions/
│   │   ├── Utilities/
│   │   └── Constants.swift
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Localizable.xcstrings
│       └── Info.plist
├── ProjectNameTests/                     # 单元测试
│   ├── Domain/
│   ├── Data/
│   └── Mocks/
├── ProjectNameUITests/                   # UI 测试
├── Packages/                             # 本地 SPM 包（可选）
└── fastlane/                             # Fastlane 配置
    ├── Fastfile
    └── Appfile
```

---

## SwiftUI 最佳实践（MUST）

### App 入口
1. 使用 `@main` + `App` 协议作为应用入口。
2. 根视图设置全局环境对象和导航。

```swift
@main
struct ProjectNameApp: App {
    @StateObject private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.appRouter)
        }
    }
}
```

### 状态管理
1. 每个 Feature View 对应一个 ViewModel，通过 `@StateObject` 或 `@ObservedObject` 持有。
2. UI State 使用 `@Published` 属性 + 不可变 struct。
3. 全局状态使用 `@EnvironmentObject` 传递。
4. 轻量本地状态使用 `@State`。

### View 规范
1. View 保持轻量：`body` 中禁止执行耗时操作。
2. 复杂 View 拆分为小组件，每个文件一个主要 View。
3. 所有 View 必须提供 `#Preview` 宏预览。
4. Modifier 链过长时提取为自定义 `ViewModifier`。

```swift
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.uiState.isLoading {
                    LoadingView()
                } else if let user = viewModel.uiState.user {
                    UserDetailView(user: user)
                } else if let error = viewModel.uiState.errorMessage {
                    ErrorView(message: error, onRetry: { Task { await viewModel.loadUser() } })
                }
            }
            .navigationTitle("首页")
        }
        .task { await viewModel.loadUser() }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(getUserUseCase: MockGetUserUseCase()))
}
```

### 导航
1. 使用 `NavigationStack` + `navigationDestination(for:)` 类型安全导航。
2. 路由定义为 `enum` 或 `Hashable` struct。
3. Tab Bar 使用 `TabView`。

### 性能注意事项
1. 列表使用 `List` 或 `LazyVStack`（大数据集），禁止 `VStack` + `ForEach` 一次性渲染。
2. 使用 `@State` / `@Binding` 最小化状态刷新范围。
3. 异步图片加载使用 `AsyncImage` 或第三方缓存库。
4. 使用 `Equatable` 协议帮助 SwiftUI diff 优化。

---

## SPM 模块化（SHOULD）

大型项目推荐按功能拆分为本地 SPM 包：

```text
Packages/
├── CoreUI/           # 通用 UI 组件 + Theme
├── CoreData/         # 通用数据层
├── CoreDomain/       # 通用领域模型
├── FeatureHome/      # 首页功能模块
├── FeatureProfile/   # 个人中心功能模块
└── FeatureSettings/  # 设置功能模块
```
