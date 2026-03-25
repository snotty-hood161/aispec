# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（ESLint/tsc）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-01 | P0 | React Native 版本锁定，`package.json` 中明确声明 react-native 版本 | 静态扫描：检查 package.json |
| RN-02 | P0 | 所有代码通过 Prettier 格式化，无手动风格调整 | 静态扫描：prettier --check |
| RN-03 | P0 | ESLint 零错误通过，启用 `@react-native/eslint-config` | 静态扫描：eslint --max-warnings 0 |
| RN-04 | P0 | `package-lock.json` / `yarn.lock` 提交到版本控制，依赖版本锁定 | 静态扫描：检查 lock 文件是否存在 |
| RN-05 | P0 | TypeScript strict 模式开启，`tsconfig.json` 中 `strict: true` | 静态扫描：检查 tsconfig.json |
| RN-06 | P1 | 启用 Hermes 引擎（React Native ≥ 0.70） | 静态扫描：检查 build 配置 |

## 二、编码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-07 | P0 | 组件名使用 PascalCase，变量/函数使用 camelCase | 静态扫描：ESLint naming-convention |
| RN-08 | P0 | 文件名与导出组件名保持一致 | 模式匹配：检查文件名与导出名映射 |
| RN-09 | P1 | 单个文件不超过 500 行，单个函数不超过 80 行 | 静态扫描：行数统计 |
| RN-10 | P0 | 分层架构：screens → hooks/services → api/storage，禁止逆向依赖 | 人工审查：检查 import 依赖方向 |
| RN-11 | P1 | 导出 API 必须有 JSDoc/TSDoc 注释 | 静态扫描：ESLint jsdoc 规则 |

## 三、架构与状态管理（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-12 | P0 | 使用统一状态管理方案，禁止混用多种状态管理库 | 人工审查：检查 package.json 依赖 |
| RN-13 | P0 | 组件与业务逻辑分离，UI 组件禁止直接操作数据源 | 模式匹配：搜索组件中的 fetch/数据库调用 |
| RN-14 | P0 | 依赖注入通过 Context/Provider 或统一容器管理，禁止手动全局单例 | 模式匹配：搜索非 DI 容器的单例模式 |
| RN-15 | P0 | 路由注册集中管理（React Navigation），禁止分散的硬编码导航 | 模式匹配：搜索硬编码路由字符串 |
| RN-16 | P0 | 原生模块桥接必须有 TypeScript 类型定义，禁止 `any` 类型 | 静态扫描：tsc --noEmit |

## 四、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-17 | P0 | 网络请求必须有 try-catch 包裹，异常分类处理 | 模式匹配：搜索未包裹的 fetch/axios 调用 |
| RN-18 | P0 | 自定义错误类体系，禁止裸抛 Error 字符串 | 模式匹配：搜索 throw new Error('...') 无分类 |
| RN-19 | P0 | 全局 ErrorBoundary 组件覆盖，捕获渲染异常 | 模式匹配：搜索 ErrorBoundary 配置 |
| RN-20 | P1 | 错误信息面向用户与面向开发者分离 | 人工审查：检查错误展示逻辑 |
| RN-21 | P1 | Promise 链必须有 .catch() 或 try-catch，禁止未处理的 Promise rejection | 静态扫描：ESLint no-floating-promises |

## 五、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-22 | P0 | 敏感数据（Token/密钥）禁止硬编码或明文存储 | 模式匹配：搜索硬编码密钥/Token 模式 |
| RN-23 | P0 | 使用安全存储（react-native-keychain / expo-secure-store） | 模式匹配：搜索 AsyncStorage 存储敏感数据 |
| RN-24 | P0 | HTTPS 强制，禁止生产环境 HTTP 明文请求 | 模式匹配：搜索 http:// URL |
| RN-25 | P1 | 证书固定（Certificate Pinning）用于关键 API | 人工审查：检查网络配置 |
| RN-26 | P1 | 发布构建启用代码混淆（ProGuard/R8 + Hermes bytecode） | 人工审查：检查构建配置 |

## 六、数据访问（common/data-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-27 | P0 | 网络请求通过统一 HTTP Client 封装（axios/ky 实例），禁止分散的 fetch 调用 | 模式匹配：搜索直接使用 fetch 的调用 |
| RN-28 | P0 | 本地数据库操作通过 Repository 层封装 | 模式匹配：搜索 UI 层直接操作数据库 |
| RN-29 | P1 | 请求/响应模型与 UI 模型分离（DTO → Domain Model） | 人工审查：检查模型层次 |
| RN-30 | P1 | 离线缓存策略明确（缓存优先/网络优先/仅网络） | 人工审查：检查缓存实现 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-31 | P0 | 多环境配置分离（dev/staging/prod），构建时注入 | 模式匹配：搜索环境配置加载方式 |
| RN-32 | P0 | 签名密钥文件禁止提交到代码仓库 | 静态扫描：检查 .gitignore 与密钥文件 |
| RN-33 | P1 | 环境变量使用 react-native-config / expo-constants，禁止硬编码 | 模式匹配：搜索硬编码环境变量 |

## 八、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-34 | P0 | 崩溃报告集成（Sentry / Firebase Crashlytics），覆盖 JS + 原生异常 | 模式匹配：搜索崩溃报告初始化配置 |
| RN-35 | P0 | 日志分级使用（debug/info/warning/error），禁止生产环境 console.log() | 模式匹配：搜索 console.log() 调用 |
| RN-36 | P1 | 关键业务操作埋点（页面访问/关键点击/转化漏斗） | 人工审查：检查埋点覆盖 |
| RN-37 | P1 | 性能监控集成（启动时间/帧率/JS Bundle 加载耗时） | 人工审查：检查性能监控配置 |

## 九、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-38 | P0 | 长列表使用 FlatList/SectionList/FlashList，禁止 ScrollView 渲染大量子项 | 模式匹配：搜索 ScrollView 嵌套大列表 |
| RN-39 | P0 | 图片加载使用缓存方案（react-native-fast-image / expo-image），有占位与错误图 | 模式匹配：搜索 Image 组件无缓存使用 |
| RN-40 | P0 | 桥通信避免高频调用，批量操作优先使用 Turbo Module / JSI | 模式匹配：搜索循环中的桥调用 |
| RN-41 | P1 | 使用 React.memo/useMemo/useCallback 优化不必要的重渲染 | 静态扫描：ESLint react-hooks 规则 |
| RN-42 | P1 | 避免在渲染路径中执行耗时操作（网络请求/复杂计算） | 模式匹配：搜索组件函数体中的异步调用 |

## 十、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-43 | P0 | 核心业务逻辑有单元测试，覆盖率 ≥ 60% | 静态扫描：jest --coverage |
| RN-44 | P0 | 测试文件命名 *.test.ts(x) / *.spec.ts(x)，位于 __tests__/ 或同级目录 | 模式匹配：检查测试文件位置与命名 |
| RN-45 | P1 | 关键 UI 流程有组件测试或 E2E 测试（Detox/Maestro） | 人工审查：检查测试覆盖范围 |
| RN-46 | P1 | CI 流水线包含 lint → typecheck → test → build 阶段 | 人工审查：检查 CI 配置 |
| RN-47 | P1 | OTA 更新（CodePush/EAS Update）配置正确，灰度策略明确 | 人工审查：检查 OTA 配置 |

## 十一、UI 框架（common/ui-framework.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-48 | P0 | 使用统一设计系统/主题（StyleSheet.create / styled-components / NativeWind），禁止内联样式硬编码颜色/字体 | 模式匹配：搜索内联 style 硬编码颜色 |
| RN-49 | P0 | 导航使用 React Navigation 统一管理，路由声明集中 | 模式匹配：搜索分散的 navigation.navigate 硬编码 |
| RN-50 | P1 | 无障碍标注（accessibilityLabel/accessibilityRole）覆盖关键交互元素 | 模式匹配：搜索缺少 accessibility 属性的交互组件 |
| RN-51 | P1 | 国际化使用 i18next / expo-localization + intl，禁止硬编码中文字符串 | 模式匹配：搜索硬编码中文字符串 |

## 十二、设备适配（common/device-adaptation.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-52 | P0 | 使用 Dimensions/useWindowDimensions 响应式布局，禁止固定像素宽度全屏布局 | 模式匹配：搜索 width: <固定数值> 全屏布局 |
| RN-53 | P1 | 平板/折叠屏适配有专用布局策略 | 人工审查：检查大屏适配方案 |
| RN-54 | P1 | 横屏模式支持或显式锁定竖屏并说明理由 | 人工审查：检查屏幕方向配置 |
| RN-55 | P1 | 安全区域（SafeAreaView / react-native-safe-area-context）覆盖全屏页面 | 模式匹配：搜索页面是否包含 SafeAreaView |

## 十三、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| RN-56 | P0 | 禁止生产代码中使用 console.log() / console.warn() 输出日志 | 模式匹配：搜索 console.* 调用 |
| RN-57 | P0 | 禁止提交包含密钥/密码/Token 的代码 | 静态扫描：git-secrets / gitleaks |
| RN-58 | P0 | 禁止在渲染函数中直接发起网络请求或 setState 循环 | 模式匹配：搜索渲染路径中的 fetch/setState 循环 |
| RN-59 | P0 | 禁止 UI 组件直接操作数据库或文件系统 | 模式匹配：搜索组件中的 DB/文件操作 |
| RN-60 | P0 | 禁止使用 `any` 类型（除已注释说明的例外） | 静态扫描：ESLint @typescript-eslint/no-explicit-any |

---

## Profile 专项检查

### Expo 专项（profiles/expo/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EX-01 | P0 | 项目遵循 Expo 标准目录结构（app/ 或 src/） | 人工审查：检查目录结构 |
| EX-02 | P1 | 使用 Expo SDK 内置模块优先于社区替代 | 模式匹配：检查 package.json 依赖 |
| EX-03 | P1 | EAS Build 配置完整（eas.json），覆盖 dev/preview/production | 人工审查：检查 eas.json |
| EX-04 | P1 | OTA 更新配置正确（EAS Update），灰度策略明确 | 人工审查：检查更新配置 |

### Bare 专项（profiles/bare/*.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BR-01 | P0 | 原生模块有完整的 TypeScript 类型定义 | 静态扫描：tsc --noEmit |
| BR-02 | P0 | Android minSdkVersion 与 iOS Deployment Target 符合规范 | 模式匹配：检查平台配置文件 |
| BR-03 | P1 | 权限声明最小化，AndroidManifest.xml 与 Info.plist 仅声明必要权限 | 人工审查：检查权限清单 |
| BR-04 | P1 | 应用图标与启动页按规范配置，覆盖各分辨率 | 人工审查：检查资源文件完整性 |
