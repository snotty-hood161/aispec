# rules/flutter/profiles/mobile/project-structure.md

## 文档目标
1. 定义面向 Android + iOS 移动端的 Flutter 项目标准目录结构。

---

## 目录结构（MUST）

```
my_app/
├── android/                          ← Android 平台工程（AGP 管理）
├── ios/                              ← iOS 平台工程（Xcode 管理）
├── lib/
│   ├── main.dart                     ← 应用入口
│   ├── app.dart                      ← MaterialApp 配置（路由、主题、国际化）
│   ├── bootstrap.dart                ← 启动初始化（DI、日志、崩溃报告）
│   │
│   ├── core/                         ← 全局基础设施（不依赖具体业务）
│   │   ├── constants/                ← 全局常量（API 路径、尺寸、颜色 Token）
│   │   ├── di/                       ← 依赖注入配置（get_it / riverpod）
│   │   ├── error/                    ← 统一异常定义（AppException 体系）
│   │   ├── extensions/               ← Dart/Flutter 扩展方法
│   │   ├── network/                  ← HTTP 客户端封装（Dio + Interceptor）
│   │   ├── storage/                  ← 本地存储封装（SecureStorage / SharedPreferences）
│   │   ├── router/                   ← 路由配置（GoRouter / auto_route）
│   │   ├── theme/                    ← 主题定义（Light / Dark / Design Token）
│   │   ├── l10n/                     ← 国际化（arb 文件 + 生成代码）
│   │   └── utils/                    ← 工具函数（日期格式化、校验器等）
│   │
│   ├── features/                     ← 业务功能模块（按功能域拆分）
│   │   ├── auth/                     ← 认证模块
│   │   │   ├── data/                 ← 数据层
│   │   │   │   ├── datasources/      ← 数据源（Remote / Local）
│   │   │   │   ├── models/           ← DTO（json_serializable）
│   │   │   │   └── repositories/     ← Repository 实现
│   │   │   ├── domain/               ← 领域层
│   │   │   │   ├── entities/         ← 业务实体（纯 Dart 类）
│   │   │   │   ├── repositories/     ← Repository 接口（abstract class）
│   │   │   │   └── usecases/         ← 用例（可选，简单场景可省略）
│   │   │   └── presentation/         ← 展示层
│   │   │       ├── bloc/             ← BLoC / Cubit（或 providers/）
│   │   │       ├── pages/            ← 页面 Widget
│   │   │       └── widgets/          ← 页面专属组件
│   │   ├── home/
│   │   ├── order/
│   │   └── profile/
│   │
│   └── shared/                       ← 跨功能共享组件
│       ├── widgets/                  ← 通用 UI 组件（按钮、卡片、加载指示器）
│       ├── models/                   ← 跨功能共享的数据模型
│       └── mixins/                   ← 共享 Mixin
│
├── test/                             ← 单元测试 + Widget 测试
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── ...
│   ├── shared/
│   └── helpers/                      ← 测试工具（Mock 工厂、Fixture 数据）
│
├── integration_test/                 ← 集成测试
│   └── app_test.dart
│
├── assets/                           ← 静态资源
│   ├── images/
│   │   ├── 1.0x/
│   │   ├── 2.0x/
│   │   └── 3.0x/
│   ├── icons/                        ← SVG 图标
│   ├── fonts/                        ← 自定义字体
│   └── l10n/                         ← 本地化 arb 文件（或放 lib/core/l10n/）
│
├── config/                           ← 构建环境配置
│   ├── dev.json                      ← 开发环境 --dart-define-from-file
│   ├── staging.json                  ← 预发布环境
│   └── prod.json                     ← 生产环境
│
├── scripts/                          ← 自动化脚本
│   ├── build.sh                      ← 构建脚本
│   └── gen_code.sh                   ← 代码生成（build_runner）
│
├── pubspec.yaml                      ← 依赖与资源声明
├── analysis_options.yaml             ← 静态分析配置
├── .fvmrc                            ← FVM Flutter 版本锁定
└── README.md
```

---

## 目录规则（MUST）

1. `features/` 按业务功能域拆分，每个功能模块包含完整的 `data / domain / presentation` 三层。
2. 模块内部文件禁止被其他模块直接引用（通过 `core/` 或 `shared/` 共享）。
3. `core/` 为全局基础设施，不包含任何业务逻辑。
4. `shared/` 存放跨功能共享的 UI 组件和模型，但不包含业务逻辑。
5. 测试目录 `test/` 镜像 `lib/` 的目录结构。

---

## 代码生成（MUST）

1. 使用 `build_runner` 进行代码生成（json_serializable / freezed / injectable 等）。
2. 生成文件命名为 `*.g.dart`（json）/ `*.freezed.dart`（freezed），纳入版本控制。
3. 执行代码生成的脚本统一放在 `scripts/gen_code.sh`：
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## 平台工程（MUST）

### Android（`android/`）
1. `minSdk` 推荐 API 24（Android 7.0）及以上。
2. 使用 Gradle Kotlin DSL + Version Catalog。
3. keystore 文件禁止提交到代码仓库。

### iOS（`ios/`）
1. 最低部署目标推荐 iOS 16+。
2. 使用 `.xcconfig` 管理 Build Settings。
3. 推荐使用 Fastlane Match 管理证书。

---

## Monorepo 结构（SHOULD — 大型项目）

1. 大型项目推荐 Melos Monorepo：

```
my_workspace/
├── melos.yaml
├── packages/
│   ├── app/                          ← 主应用
│   ├── core/                         ← 核心包（网络、存储、主题）
│   ├── features/
│   │   ├── auth/                     ← 认证功能包
│   │   ├── order/                    ← 订单功能包
│   │   └── profile/                  ← 个人中心功能包
│   └── shared/                       ← 共享 UI 组件包
```

2. 每个 Package 独立 `pubspec.yaml`，通过 `path` 依赖引用。
3. 使用 `melos bootstrap` 统一安装依赖。
4. 使用 `melos run` 统一执行测试和分析。
