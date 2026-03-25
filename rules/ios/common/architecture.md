# rules/ios/common/architecture.md

## 整体架构

iOS 应用采用 **MVVM** 分层设计，结合 Swift Concurrency 实现响应式数据流：
- **View Layer**：SwiftUI View / UIKit ViewController 负责 UI 渲染。
- **ViewModel Layer**：管理 UI 状态、处理用户操作、协调业务逻辑。
- **Service Layer**：封装可复用的业务逻辑与外部服务交互。
- **Repository/Data Layer**：聚合数据源（本地 + 远程），对上层屏蔽实现细节。

## 分层规则（MUST）

### 模块化分层
```text
ProjectName/
├── App/
│   ├── ProjectNameApp.swift         # @main 入口（SwiftUI）
│   └── AppDelegate.swift            # AppDelegate（UIKit/混合）
├── DI/                              # 依赖注入容器
│   └── DependencyContainer.swift
├── UI/                              # View Layer
│   ├── Navigation/
│   │   └── AppRouter.swift
│   ├── Components/                  # 通用 UI 组件
│   │   ├── LoadingView.swift
│   │   └── ErrorView.swift
│   └── Features/                    # 按功能分包
│       ├── Home/
│       │   ├── HomeView.swift
│       │   ├── HomeViewModel.swift
│       │   └── HomeUiState.swift
│       └── Profile/
│           ├── ProfileView.swift
│           ├── ProfileViewModel.swift
│           └── ProfileUiState.swift
├── Domain/                          # Domain Layer
│   ├── Models/
│   │   └── User.swift
│   ├── UseCases/
│   │   └── GetUserUseCase.swift
│   └── Repositories/               # Repository 协议定义
│       └── UserRepositoryProtocol.swift
├── Data/                            # Data Layer
│   ├── Local/
│   │   ├── CoreData/
│   │   └── UserDefaults/
│   ├── Remote/
│   │   ├── API/
│   │   │   └── UserAPI.swift
│   │   ├── DTOs/
│   │   │   └── UserDTO.swift
│   │   └── NetworkClient.swift
│   ├── Mappers/
│   │   └── UserMapper.swift
│   └── Repositories/               # Repository 实现
│       └── UserRepository.swift
└── Common/                          # 通用工具
    ├── Extensions/
    ├── Utilities/
    └── Constants.swift
```

### 依赖方向
```
View → ViewModel → UseCase → Repository Protocol
                                     ↑
                           Repository Implementation
                          ┌──────────┴──────────┐
                     LocalDataSource        RemoteDataSource
```

1. 依赖方向单向向下，禁止反向依赖。
2. Domain Layer 不依赖 UIKit / SwiftUI（纯 Swift）。
3. Data Layer 实现 Domain Layer 定义的 Repository 协议。
4. View Layer 仅通过 ViewModel 访问数据，禁止直接调用 Repository。

## 依赖注入（MUST）

1. 推荐使用轻量 DI 容器（手动构造 / Factory 模式 / swift-dependencies）。
2. 所有依赖通过初始化器注入，禁止在使用处直接创建依赖实例。
3. 协议与实现分离，便于测试时 Mock 替换。

```swift
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var uiState = HomeUiState()

    private let getUserUseCase: GetUserUseCaseProtocol

    init(getUserUseCase: GetUserUseCaseProtocol) {
        self.getUserUseCase = getUserUseCase
    }

    func loadUser(id: Int) async {
        uiState.isLoading = true
        do {
            let user = try await getUserUseCase.execute(id: id)
            uiState.user = user
        } catch {
            uiState.errorMessage = error.localizedDescription
        }
        uiState.isLoading = false
    }
}

struct HomeUiState {
    var user: User?
    var isLoading = false
    var errorMessage: String?
}
```

## ViewModel 规范（MUST）

1. ViewModel 必须遵循 `ObservableObject` 协议（SwiftUI）或自定义 Observable 模式（UIKit）。
2. UI 状态通过 `@Published` 属性暴露，使用不可变值类型（struct）。
3. ViewModel 使用 `@MainActor` 标注，确保 UI 状态更新在主线程。
4. ViewModel 禁止持有 View / UIViewController 引用。
5. 异步操作使用 Swift Concurrency（`async`/`await`），新代码禁止使用回调嵌套。

## 导航规范（MUST）

1. SwiftUI 使用 `NavigationStack` + 类型安全路由。
2. UIKit 使用 Coordinator 模式管理导航。
3. 路由定义集中管理，禁止硬编码字符串路由。
4. Deep Link 处理通过统一路由分发。
