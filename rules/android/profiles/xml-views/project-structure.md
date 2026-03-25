# rules/android/profiles/xml-views/project-structure.md

## 文档目标
1. 定义传统 XML Views 项目的标准目录结构与规范（适用于旧项目维护）。

---

## 项目结构（MUST）

```text
app/
├── build.gradle.kts
├── proguard-rules.pro
└── src/
    ├── main/
    │   ├── AndroidManifest.xml
    │   ├── java/com/example/app/
    │   │   ├── App.kt                          # Application 入口
    │   │   ├── di/                             # Hilt 模块
    │   │   ├── ui/                             # UI Layer
    │   │   │   ├── base/                       # 基类
    │   │   │   │   ├── BaseActivity.kt
    │   │   │   │   ├── BaseFragment.kt
    │   │   │   │   └── BaseViewModel.kt
    │   │   │   └── feature/                    # 按功能分包
    │   │   │       ├── home/
    │   │   │       │   ├── HomeActivity.kt
    │   │   │       │   ├── HomeFragment.kt
    │   │   │       │   ├── HomeViewModel.kt
    │   │   │       │   └── HomeAdapter.kt
    │   │   │       └── profile/
    │   │   │           ├── ProfileFragment.kt
    │   │   │           └── ProfileViewModel.kt
    │   │   ├── domain/                         # Domain Layer
    │   │   │   ├── model/
    │   │   │   ├── usecase/
    │   │   │   └── repository/
    │   │   └── data/                           # Data Layer
    │   │       ├── local/
    │   │       ├── remote/
    │   │       ├── mapper/
    │   │       └── repository/
    │   └── res/
    │       ├── layout/                         # 布局文件
    │       │   ├── activity_home.xml
    │       │   ├── fragment_home.xml
    │       │   └── item_user.xml
    │       ├── navigation/                     # Navigation Graph
    │       │   └── nav_main.xml
    │       ├── menu/
    │       ├── drawable/
    │       ├── values/
    │       │   ├── strings.xml
    │       │   ├── colors.xml
    │       │   ├── dimens.xml
    │       │   ├── styles.xml
    │       │   └── themes.xml
    │       ├── values-night/
    │       │   ├── colors.xml
    │       │   └── themes.xml
    │       └── xml/
    │           └── network_security_config.xml
    ├── test/
    └── androidTest/
```

---

## XML Views 规范（MUST）

### ViewBinding
1. 必须使用 **ViewBinding**，禁止使用 `findViewById` 或 Kotlin Synthetics。
2. ViewBinding 在 Fragment 中必须在 `onDestroyView` 中置空，防止内存泄漏。

```kotlin
class HomeFragment : Fragment(R.layout.fragment_home) {
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        _binding = FragmentHomeBinding.bind(view)
        // 使用 binding
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

### 布局规范
1. 推荐使用 `ConstraintLayout` 作为根布局，减少嵌套层级。
2. 布局文件命名：`activity_*.xml`、`fragment_*.xml`、`item_*.xml`、`view_*.xml`。
3. 尺寸定义使用 `dimens.xml`，禁止在布局中硬编码数值。
4. 颜色引用通过 Theme 属性（`?attr/colorPrimary`），禁止直接引用 `@color/`。

### RecyclerView
1. 必须使用 `ListAdapter` + `DiffUtil`，禁止使用 `notifyDataSetChanged()`。
2. ViewHolder 中禁止持有 Activity/Fragment 引用。
3. 大列表启用 `setHasFixedSize(true)`。

### Navigation Component
1. 使用 Navigation Component + Safe Args 管理页面导航。
2. Fragment 之间数据传递使用 Safe Args，禁止裸 `Bundle` 传递。
3. 导航图文件放在 `res/navigation/` 目录。

---

## 迁移建议

对于需要从 XML Views 迁移到 Compose 的项目：
1. 优先新增页面使用 Compose。
2. 已有页面通过 `ComposeView` 逐步嵌入 Compose 组件。
3. 共享 Theme 通过 `MdcTheme` 桥接。
4. 迁移过程中同时遵守 `common/*` 和 `profiles/compose/*` 规则。
