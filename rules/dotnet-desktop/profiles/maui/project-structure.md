# rules/dotnet-desktop/profiles/maui/project-structure.md

## 适用场景
1. 跨平台桌面/移动应用，使用 .NET MAUI 框架。
2. 目标框架：`.NET 8` 及以上。
3. 支持平台：Windows、macOS、Android、iOS（按项目需求选择）。

## 推荐解决方案结构
```text
MyMauiApp/
├── src/
│   ├── MyMauiApp/                                # MAUI 主项目
│   │   ├── App.xaml                              # 应用定义
│   │   ├── App.xaml.cs                           # DI 配置、生命周期
│   │   ├── AppShell.xaml                         # Shell 导航定义
│   │   ├── AppShell.xaml.cs
│   │   ├── MauiProgram.cs                        # 启动配置、DI 注册
│   │   ├── Views/                                # 视图层
│   │   │   ├── Pages/
│   │   │   │   ├── UserListPage.xaml
│   │   │   │   ├── UserListPage.xaml.cs
│   │   │   │   └── UserDetailPage.xaml
│   │   │   ├── Controls/                         # 自定义控件
│   │   │   │   └── LoadingIndicator.xaml
│   │   │   └── Popups/                           # 弹出层
│   │   │       └── ConfirmPopup.xaml
│   │   ├── ViewModels/
│   │   │   ├── UserListViewModel.cs
│   │   │   └── UserDetailViewModel.cs
│   │   ├── Resources/
│   │   │   ├── Styles/
│   │   │   │   ├── Colors.xaml                   # 颜色定义
│   │   │   │   └── Styles.xaml                   # 控件样式
│   │   │   ├── Fonts/                            # 字体资源
│   │   │   ├── Images/                           # 图片资源
│   │   │   └── Raw/                              # 原始资源文件
│   │   ├── Converters/                           # 值转换器
│   │   ├── Platforms/                            # 平台特定代码
│   │   │   ├── Windows/
│   │   │   ├── MacCatalyst/
│   │   │   ├── Android/
│   │   │   └── iOS/
│   │   └── Hosting/                              # DI 注册
│   │       └── ServiceExtensions.cs
│   │
│   ├── MyMauiApp.Application/                    # 应用服务层（平台无关）
│   │   ├── Users/
│   │   │   ├── IUserService.cs
│   │   │   └── UserService.cs
│   │   └── Sync/
│   │       └── ISyncService.cs
│   │
│   ├── MyMauiApp.Domain/                         # 领域层（平台无关）
│   │   ├── Entities/
│   │   ├── Exceptions/
│   │   └── Interfaces/
│   │       ├── IUserRepository.cs
│   │       ├── IDialogService.cs
│   │       ├── IConnectivityService.cs           # 网络状态抽象
│   │       └── ISecureStorageService.cs          # 安全存储抽象
│   │
│   ├── MyMauiApp.Infrastructure/                 # 基础设施层（平台无关部分）
│   │   ├── Data/
│   │   │   ├── AppDbContext.cs
│   │   │   └── Repositories/
│   │   ├── ApiClients/
│   │   │   └── UserApiClient.cs
│   │   └── Services/
│   │       ├── MauiDialogService.cs              # MAUI 平台 Dialog 实现
│   │       ├── MauiConnectivityService.cs        # 网络状态封装
│   │       └── MauiSecureStorageService.cs       # SecureStorage 封装
│   │
│   └── MyMauiApp.Shared/
│       └── Options/
│
├── tests/
│   ├── MyMauiApp.UnitTests/
│   └── MyMauiApp.IntegrationTests/
│
├── Directory.Build.props
└── MyMauiApp.sln
```

## MVVM 规则

### MUST
1. 必须使用 MVVM 架构，推荐 CommunityToolkit.Mvvm。
2. ViewModel 注册到 DI 容器，View 通过构造函数注入 ViewModel 并设置 `BindingContext`。
3. 导航使用 Shell 路由：`Routing.RegisterRoute` + `Shell.Current.GoToAsync`，导航参数通过 `IQueryAttributable` 接收。
4. ViewModel 禁止引用 `Microsoft.Maui.*` UI 类型。

### 页面注册示例
```csharp
// MauiProgram.cs
builder.Services.AddTransient<UserListPage>();
builder.Services.AddTransient<UserListViewModel>();

// UserListPage.xaml.cs
public UserListPage(UserListViewModel viewModel)
{
    InitializeComponent();
    BindingContext = viewModel;
}
```

## 跨平台适配规则

### MUST
1. 业务逻辑、数据访问、网络调用必须平台无关，放在 `Application`、`Domain`、`Infrastructure` 项目中。
2. 平台特定代码（文件选择、推送通知、生物识别）放在 `Platforms/` 目录或使用条件编译（`#if WINDOWS` / `#if ANDROID`）。
3. 平台特定功能必须通过接口抽象，不同平台通过 DI 注册不同实现。
4. UI 布局必须适配不同屏幕尺寸：
   - 桌面端：固定宽度或响应式布局。
   - 移动端：全宽自适应布局。
   - 使用 `OnPlatform` / `OnIdiom` 标记处理平台差异。
5. 禁止使用仅在特定平台可用的 API 而不做平台检查。

### SHOULD
1. 使用 MAUI Essentials API（`Connectivity`、`SecureStorage`、`Preferences`、`FileSystem`）替代直接调用平台 API。
2. 图片资源使用 SVG 或提供多分辨率版本（`@1x`、`@2x`、`@3x`）。

## MAUI 特有约束
1. Shell 导航为首选导航方式，复杂导航场景可搭配 `NavigationPage`。
2. `CollectionView` 替代 `ListView`（性能更优，默认虚拟化）。
3. Handler 自定义（替代旧 Renderer）放在 `Platforms/` 对应目录。
4. Hot Reload 开发时可用，但禁止依赖 Hot Reload 跳过编译验证。
