# rules/dotnet-desktop/profiles/wpf/project-structure.md

## 适用场景
1. Windows 桌面应用，使用 WPF（Windows Presentation Foundation）框架。
2. 目标框架：`.NET 8` 及以上（新项目禁止使用 .NET Framework WPF）。

## 推荐解决方案结构
```text
MyWpfApp/
├── src/
│   ├── MyWpfApp/                                # WPF 主项目（启动项目）
│   │   ├── App.xaml                             # 应用定义、全局资源引用
│   │   ├── App.xaml.cs                          # DI 配置、全局异常处理、生命周期
│   │   ├── appsettings.json                     # 应用配置
│   │   ├── Views/                               # 视图层（XAML + Code-Behind）
│   │   │   ├── MainWindow.xaml
│   │   │   ├── MainWindow.xaml.cs               # 仅纯 UI 逻辑
│   │   │   ├── Pages/                           # 页面视图
│   │   │   │   ├── UserListPage.xaml
│   │   │   │   └── UserDetailPage.xaml
│   │   │   └── Dialogs/                         # 对话框视图
│   │   │       └── ConfirmDialog.xaml
│   │   ├── Resources/                           # 资源字典
│   │   │   ├── Themes/                          # 主题资源
│   │   │   │   ├── LightTheme.xaml
│   │   │   │   └── DarkTheme.xaml
│   │   │   ├── Styles/                          # 控件样式
│   │   │   │   ├── ButtonStyles.xaml
│   │   │   │   └── TextStyles.xaml
│   │   │   ├── Converters/                      # 值转换器
│   │   │   │   ├── BoolToVisibilityConverter.cs
│   │   │   │   └── DateTimeFormatConverter.cs
│   │   │   └── Icons/                           # 图标资源
│   │   ├── ViewModels/                          # 视图模型层
│   │   │   ├── MainWindowViewModel.cs
│   │   │   ├── Pages/
│   │   │   │   ├── UserListViewModel.cs
│   │   │   │   └── UserDetailViewModel.cs
│   │   │   └── Dialogs/
│   │   │       └── ConfirmDialogViewModel.cs
│   │   └── Hosting/                             # DI 注册扩展
│   │       ├── ViewModelExtensions.cs
│   │       └── ServiceExtensions.cs
│   │
│   ├── MyWpfApp.Application/                    # 应用服务层（业务逻辑）
│   │   ├── Users/
│   │   │   ├── IUserService.cs
│   │   │   ├── UserService.cs
│   │   │   └── Validators/
│   │   │       └── CreateUserValidator.cs
│   │   └── Orders/
│   │       ├── IOrderService.cs
│   │       └── OrderService.cs
│   │
│   ├── MyWpfApp.Domain/                         # 领域层（实体、异常、接口）
│   │   ├── Entities/
│   │   │   └── User.cs
│   │   ├── Exceptions/
│   │   │   ├── BusinessException.cs
│   │   │   └── UserException.cs
│   │   └── Interfaces/
│   │       ├── IUserRepository.cs
│   │       ├── IDialogService.cs
│   │       ├── INavigationService.cs
│   │       └── IFileDialogService.cs
│   │
│   ├── MyWpfApp.Infrastructure/                 # 基础设施层
│   │   ├── Data/                                # 本地数据库
│   │   │   ├── AppDbContext.cs
│   │   │   ├── Configurations/
│   │   │   ├── Repositories/
│   │   │   └── Migrations/
│   │   ├── ApiClients/                          # 远程 API 客户端
│   │   │   └── UserApiClient.cs
│   │   ├── Services/                            # 基础设施服务实现
│   │   │   ├── DialogService.cs                 # IDialogService 的 WPF 实现
│   │   │   ├── NavigationService.cs
│   │   │   └── FileDialogService.cs
│   │   ├── Settings/                            # 用户设置持久化
│   │   │   └── JsonUserSettingsService.cs
│   │   └── Extensions/
│   │       ├── DatabaseExtensions.cs
│   │       └── HttpClientExtensions.cs
│   │
│   └── MyWpfApp.Shared/                         # 跨层共享（仅技术组件）
│       └── Options/
│           └── ApiOptions.cs
│
├── tests/
│   ├── MyWpfApp.UnitTests/
│   └── MyWpfApp.IntegrationTests/
│
├── Directory.Build.props
├── Directory.Packages.props
└── MyWpfApp.sln
```

## MVVM 规则

### View（视图）
1. XAML 负责 UI 布局和数据绑定，Code-Behind 仅处理纯 UI 逻辑（动画、焦点、拖放、窗口尺寸）。
2. View 通过 `DataContext` 绑定 ViewModel，推荐在 DI 中注入（构造函数或 `ViewModelLocator`）。
3. 禁止在 Code-Behind 中访问 Service、Repository 或执行业务逻辑。

### ViewModel（视图模型）
1. 继承 `ObservableObject`（CommunityToolkit.Mvvm），使用 `[ObservableProperty]` 和 `[RelayCommand]` Source Generator。
2. ViewModel 与 View 一一对应（`UserListPage.xaml` ↔ `UserListViewModel.cs`）。
3. ViewModel 禁止引用 `System.Windows` 命名空间下的任何类型。

### 数据绑定
1. 优先使用编译时绑定（`x:Bind`）或 `{Binding}` + `Mode`，禁止在 Code-Behind 中手动赋值控件属性。
2. 双向绑定仅用于表单输入，列表展示使用单向绑定。
3. 复杂数据转换使用 `IValueConverter`，集中定义在 `Resources/Converters/`。
4. 绑定错误必须在调试阶段发现和修复（输出窗口中的绑定错误）。

## 资源管理规则
1. 全局样式和主题定义在 `Resources/Themes/` 和 `Resources/Styles/`，通过 `App.xaml` 合并引用。
2. 主题切换使用 `DynamicResource`，静态资源使用 `StaticResource`。
3. 图标优先使用矢量图标（`PathGeometry` / `DrawingImage`），禁止在高 DPI 场景使用低分辨率位图。
4. 字符串资源使用 `Resources.resx`，支持多语言切换。

## 窗口与导航规则
1. 单窗口多页面应用使用 `Frame` + `Page` 导航或 `ContentControl` + `DataTemplate` 切换。
2. 多窗口应用中子窗口必须通过 `IDialogService` 创建，禁止在 ViewModel 中直接 `new Window()`。
3. 窗口位置和大小使用用户设置持久化（参见 `common/configuration.md`）。

## WPF 特有约束
1. 高 DPI 适配：设置 `dpiAware` 为 `PerMonitorV2`，确保多显示器不同 DPI 下正确渲染。
2. `Dispatcher` 调用仅在 Infrastructure 层的 Service 实现中使用，ViewModel 不应直接调用 Dispatcher。
3. 控件模板自定义（`ControlTemplate`）必须定义在资源字典中，禁止在使用处内联。
