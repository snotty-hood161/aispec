# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（dart analyze/flutter analyze）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-01 | P0 | Flutter SDK 版本锁定，`pubspec.yaml` 中明确声明 environment 约束 | 静态扫描：检查 pubspec.yaml |
| FL-02 | P0 | 所有代码通过 `dart format` 格式化，无手动风格调整 | 静态扫描：dart format --set-exit-if-changed |
| FL-03 | P0 | `dart analyze` 零告警通过，启用 `analysis_options.yaml` | 静态扫描：dart analyze |
| FL-04 | P0 | `pubspec.lock` 提交到版本控制，依赖版本锁定 | 静态扫描：检查 pubspec.lock 是否存在 |
| FL-05 | P1 | 启用严格模式（`strict-casts`、`strict-raw-types`） | 静态扫描：检查 analysis_options.yaml |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-06 | P0 | 类名使用 UpperCamelCase，变量/函数使用 lowerCamelCase | 静态扫描：dart analyze（lint rules） |
| FL-07 | P0 | 文件名使用 snake_case，与类名对应 | 模式匹配：检查文件名与类名映射 |
| FL-08 | P1 | 单个文件不超过 500 行，单个函数不超过 80 行 | 静态扫描：行数统计 |
| FL-09 | P0 | 分层架构：presentation → domain → data，禁止逆向依赖 | 人工审查：检查 import 依赖方向 |
| FL-10 | P1 | 导出 API 必须有 DartDoc 注释 | 静态扫描：dart analyze（public_member_api_docs） |

## 三、架构与状态管理（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-11 | P0 | 使用统一状态管理方案，禁止混用多种状态管理库 | 人工审查：检查 pubspec.yaml 依赖 |
| FL-12 | P0 | Widget 与业务逻辑分离，UI 层禁止直接操作数据源 | 模式匹配：搜索 Widget 中的网络/数据库调用 |
| FL-13 | P0 | 依赖注入通过统一容器管理，禁止手动全局单例 | 模式匹配：搜索非 DI 容器的单例模式 |
| FL-14 | P1 | 路由注册集中管理，禁止分散的 Navigator.push 硬编码路由 | 模式匹配：搜索硬编码路由字符串 |

## 四、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-15 | P0 | 网络请求必须有 try-catch 包裹，异常分类处理 | 模式匹配：搜索未包裹的网络调用 |
| FL-16 | P0 | 自定义异常类体系，禁止裸抛 Exception/Error 字符串 | 模式匹配：搜索 throw Exception('...') |
| FL-17 | P1 | 错误信息面向用户与面向开发者分离 | 人工审查：检查错误展示逻辑 |
| FL-18 | P1 | Future 链必须有 catchError 或 try-catch，禁止未处理的 Future 异常 | 静态扫描：dart analyze（unawaited_futures） |

## 五、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-19 | P0 | 敏感数据（Token/密钥）禁止硬编码或明文存储 | 模式匹配：搜索硬编码密钥/Token 模式 |
| FL-20 | P0 | 使用安全存储（flutter_secure_storage 或平台 Keychain/Keystore） | 模式匹配：搜索 SharedPreferences 存储敏感数据 |
| FL-21 | P0 | HTTPS 强制，禁止生产环境 HTTP 明文请求 | 模式匹配：搜索 http:// URL |
| FL-22 | P1 | 证书固定（Certificate Pinning）用于关键 API | 人工审查：检查网络配置 |
| FL-23 | P1 | 混淆开启（release 构建启用 --obfuscate） | 人工审查：检查构建配置 |

## 六、数据访问（common/data-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-24 | P0 | 网络请求通过统一 HTTP Client 封装，禁止分散的 http.get 调用 | 模式匹配：搜索直接使用 http 包的调用 |
| FL-25 | P0 | 本地数据库操作通过 Repository 层封装 | 模式匹配：搜索 UI 层直接操作数据库 |
| FL-26 | P1 | 请求/响应模型与 UI 模型分离（DTO → Domain Model） | 人工审查：检查模型层次 |
| FL-27 | P1 | 离线缓存策略明确（缓存优先/网络优先/仅网络） | 人工审查：检查缓存实现 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-28 | P0 | 多环境配置分离（dev/staging/prod），构建时注入 | 模式匹配：搜索环境配置加载方式 |
| FL-29 | P0 | 签名密钥文件禁止提交到代码仓库 | 静态扫描：检查 .gitignore 与密钥文件 |
| FL-30 | P1 | Flavor/Scheme 配置完整，支持一键切换环境 | 人工审查：检查构建配置 |

## 八、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-31 | P0 | 崩溃报告集成（Firebase Crashlytics / Sentry），覆盖全局异常 | 模式匹配：搜索 FlutterError.onError 配置 |
| FL-32 | P0 | 日志分级使用（debug/info/warning/error），禁止生产环境 print() | 模式匹配：搜索 print() 调用 |
| FL-33 | P1 | 关键业务操作埋点（页面访问/关键点击/转化漏斗） | 人工审查：检查埋点覆盖 |
| FL-34 | P1 | 性能监控集成（启动时间/帧率/网络耗时） | 人工审查：检查性能监控配置 |

## 九、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-35 | P0 | 列表使用 ListView.builder / SliverList 懒加载，禁止一次性构建全部子项 | 模式匹配：搜索 ListView(children: [...]) 大列表 |
| FL-36 | P0 | 图片加载使用缓存方案（cached_network_image），有占位与错误图 | 模式匹配：搜索 Image.network 无缓存使用 |
| FL-37 | P1 | 使用 const 构造函数优化 Widget 重建 | 静态扫描：dart analyze（prefer_const_constructors） |
| FL-38 | P1 | 避免在 build() 方法中执行耗时操作（网络请求/计算） | 模式匹配：搜索 build 方法中的异步调用 |

## 十、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-39 | P0 | 核心业务逻辑有单元测试，覆盖率 ≥ 60% | 静态扫描：flutter test --coverage |
| FL-40 | P0 | 测试文件命名 *_test.dart，位于 test/ 目录 | 模式匹配：检查测试文件位置与命名 |
| FL-41 | P1 | 关键 UI 流程有 Widget 测试或集成测试 | 人工审查：检查测试覆盖范围 |
| FL-42 | P1 | CI 流水线包含 analyze → test → build 阶段 | 人工审查：检查 CI 配置 |

## 十一、UI 框架（common/ui-framework.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-43 | P0 | 使用统一主题（ThemeData），禁止 Widget 中硬编码颜色/字体 | 模式匹配：搜索 Color(0x...) / TextStyle 硬编码 |
| FL-44 | P0 | 导航使用声明式路由或统一路由管理器 | 模式匹配：搜索分散的 Navigator.push 调用 |
| FL-45 | P1 | 无障碍标注（Semantics）覆盖关键交互元素 | 模式匹配：搜索缺少 Semantics 的交互 Widget |
| FL-46 | P1 | 国际化使用 flutter_localizations + intl/arb，禁止硬编码中文字符串 | 模式匹配：搜索硬编码中文字符串 |

## 十二、设备适配（common/device-adaptation.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-47 | P0 | 使用 MediaQuery / LayoutBuilder 响应式布局，禁止固定像素宽度 | 模式匹配：搜索 width: <固定数值> 全屏布局 |
| FL-48 | P1 | 平板/折叠屏适配有专用布局策略 | 人工审查：检查大屏适配方案 |
| FL-49 | P1 | 横屏模式支持或显式锁定竖屏并说明理由 | 人工审查：检查屏幕方向配置 |
| FL-50 | P1 | 安全区域（SafeArea）覆盖全屏页面 | 模式匹配：搜索 Scaffold 是否包含 SafeArea |

## 十三、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FL-51 | P0 | 禁止生产代码中使用 print() 输出日志 | 模式匹配：搜索 print() 调用 |
| FL-52 | P0 | 禁止提交包含密钥/密码/Token 的代码 | 静态扫描：git-secrets / gitleaks |
| FL-53 | P0 | 禁止在 Widget build() 中直接调用 setState 发起网络请求 | 模式匹配：搜索 build 中的 setState + 网络调用 |
| FL-54 | P0 | 禁止 UI 层直接操作数据库或文件系统 | 模式匹配：搜索 Widget 中的 DB/文件操作 |
| FL-55 | P0 | 禁止使用已废弃 API（@deprecated） | 静态扫描：dart analyze |

---

## Profile 专项检查

### Mobile 专项（profiles/mobile/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| MB-01 | P0 | 项目遵循标准 Flutter 目录结构（lib/features 或 lib/modules） | 人工审查：检查目录结构 |
| MB-02 | P1 | Android minSdkVersion 与 iOS Deployment Target 符合规范 | 模式匹配：检查平台配置文件 |
| MB-03 | P1 | 权限声明最小化，AndroidManifest.xml 与 Info.plist 仅声明必要权限 | 人工审查：检查权限清单 |
| MB-04 | P1 | 应用图标与启动页按规范配置，覆盖各分辨率 | 人工审查：检查资源文件完整性 |
