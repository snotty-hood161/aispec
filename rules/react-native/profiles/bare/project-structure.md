# rules/react-native/profiles/bare/project-structure.md

## 文档目标
1. 定义基于 Bare Workflow（`react-native init`）的 React Native 项目目录结构规范。

---

## 项目初始化（MUST）

1. 新项目必须通过 `npx react-native init` 或 `npx @react-native-community/cli init` 创建。
2. 创建后必须立即初始化 TypeScript 严格模式（`tsconfig.json` → `strict: true`）。
3. 必须配置 ESLint（`@react-native/eslint-config`）+ Prettier。
4. 必须选定并配置导航方案（推荐 React Navigation）。
5. 原生目录（`android/` / `ios/`）必须纳入版本控制。

---

## 目录结构（MUST）

1. Bare Workflow 项目必须遵循以下目录结构：

```
my-rn-app/
├── android/                      # Android 原生工程
│   ├── app/
│   │   ├── build.gradle          # 应用级 Gradle 配置
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── java/         # 原生 Android 代码
│   │           └── res/          # Android 资源
│   ├── build.gradle              # 项目级 Gradle 配置
│   └── gradle.properties         # Gradle 属性（签名信息等）
├── ios/                          # iOS 原生工程
│   ├── MyApp/
│   │   ├── AppDelegate.mm
│   │   ├── Info.plist
│   │   └── Images.xcassets
│   ├── MyApp.xcodeproj
│   ├── MyApp.xcworkspace
│   ├── Podfile                   # CocoaPods 依赖
│   └── Podfile.lock
├── src/                          # 业务源码（所有 JS/TS 代码）
│   ├── app/                      # 应用入口与全局配置
│   │   ├── App.tsx               # 根组件
│   │   ├── navigation/           # 导航配置
│   │   │   ├── RootNavigator.tsx  # 根导航器
│   │   │   ├── AuthNavigator.tsx  # 认证流导航
│   │   │   ├── MainNavigator.tsx  # 主 Tab 导航
│   │   │   └── types.ts          # 导航参数类型定义
│   │   └── providers/            # 全局 Provider
│   │       ├── AppProviders.tsx   # Provider 组合
│   │       ├── ThemeProvider.tsx
│   │       └── QueryProvider.tsx
│   ├── features/                 # 功能模块（按业务域划分）
│   │   ├── auth/                 # 认证模块
│   │   │   ├── screens/
│   │   │   │   ├── LoginScreen.tsx
│   │   │   │   └── RegisterScreen.tsx
│   │   │   ├── components/
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   └── PhoneInput.tsx
│   │   │   ├── hooks/
│   │   │   │   └── useAuth.ts
│   │   │   ├── services/
│   │   │   │   └── authService.ts
│   │   │   └── types.ts
│   │   ├── orders/               # 订单模块
│   │   │   ├── screens/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── services/
│   │   │   └── types.ts
│   │   └── profile/              # 个人中心模块
│   │       ├── screens/
│   │       ├── components/
│   │       ├── hooks/
│   │       └── types.ts
│   ├── shared/                   # 共享模块
│   │   ├── components/           # 公共 UI 组件
│   │   │   ├── ui/               # 基础组件（AppButton / AppText / AppInput）
│   │   │   │   ├── AppButton.tsx
│   │   │   │   ├── AppButton.styles.ts
│   │   │   │   ├── AppText.tsx
│   │   │   │   └── index.ts
│   │   │   └── feedback/         # 反馈组件（Toast / Loading / Empty）
│   │   │       ├── Toast.tsx
│   │   │       └── LoadingOverlay.tsx
│   │   ├── hooks/                # 公共 Hook
│   │   │   ├── useDebounce.ts
│   │   │   ├── useNetworkStatus.ts
│   │   │   └── useAppState.ts
│   │   ├── services/             # 公共 Service
│   │   │   ├── api/
│   │   │   │   ├── client.ts     # Axios 实例与拦截器
│   │   │   │   └── types.ts      # API 通用类型
│   │   │   ├── storage/
│   │   │   │   ├── secureStorage.ts  # MMKV / Keychain 封装
│   │   │   │   └── mmkvStorage.ts
│   │   │   ├── logger.ts         # 日志封装
│   │   │   └── crashReporter.ts  # 崩溃上报封装
│   │   ├── utils/                # 工具函数
│   │   │   ├── dateUtils.ts
│   │   │   ├── formatCurrency.ts
│   │   │   ├── validation.ts
│   │   │   └── permissions.ts
│   │   ├── constants/            # 常量
│   │   │   ├── config.ts
│   │   │   ├── enums.ts
│   │   │   └── queryKeys.ts
│   │   └── types/                # 全局类型定义
│   │       ├── common.types.ts
│   │       ├── navigation.types.ts
│   │       └── env.d.ts
│   ├── stores/                   # 全局状态管理
│   │   ├── authStore.ts
│   │   ├── appStore.ts
│   │   └── index.ts
│   └── theme/                    # 主题系统
│       ├── index.ts
│       ├── colors.ts
│       ├── typography.ts
│       ├── spacing.ts
│       └── darkTheme.ts
├── assets/                       # 静态资源
│   ├── images/
│   ├── fonts/
│   └── icons/
├── e2e/                          # E2E 测试（Detox / Maestro）
│   ├── login.test.ts
│   └── order.test.ts
├── scripts/                      # 构建与自动化脚本
│   ├── setup-env.sh
│   └── bump-version.ts
├── index.js                      # 应用入口
├── metro.config.js               # Metro 打包器配置
├── babel.config.js               # Babel 配置
├── tsconfig.json                 # TypeScript 配置
├── jest.config.js                # Jest 测试配置
├── .eslintrc.js                  # ESLint 配置
├── .prettierrc                   # Prettier 配置
├── .env.example                  # 环境变量模板
├── Gemfile                       # Ruby 依赖（Fastlane / CocoaPods）
├── fastlane/                     # Fastlane 配置
│   ├── Fastfile
│   ├── Appfile
│   └── Matchfile
├── react-native.config.js        # React Native CLI 配置
└── package.json
```

---

## 功能模块规范（MUST）

1. 业务代码按功能模块（Feature）组织在 `src/features/` 目录，每个模块包含完整的分层结构：

```
features/
  moduleName/
    screens/        # 页面组件（Screen）
    components/     # 模块私有组件
    hooks/          # 模块私有 Hook
    services/       # 模块私有 Service
    types.ts        # 模块类型定义
    index.ts        # 模块公开 API 导出
```

2. 模块间引用必须通过 `index.ts` 导出的公开 API，禁止直接引用其他模块的内部文件。
3. 新功能模块必须遵循以上目录结构，禁止在 `src/` 根目录散放业务文件。
4. 公共代码必须放在 `src/shared/` 目录，禁止在功能模块中重复定义。

---

## 导航配置规范（MUST）

1. 导航定义集中在 `src/app/navigation/` 目录，禁止在业务模块中分散定义路由。
2. 导航器结构推荐：

```
RootNavigator (Stack)
├── AuthNavigator (Stack)
│   ├── LoginScreen
│   └── RegisterScreen
└── MainNavigator (Tab)
    ├── HomeStack (Stack)
    │   ├── HomeScreen
    │   └── DetailScreen
    ├── OrdersStack (Stack)
    │   ├── OrderListScreen
    │   └── OrderDetailScreen
    └── ProfileStack (Stack)
        ├── ProfileScreen
        └── SettingsScreen
```

3. 所有导航参数必须在 `navigation/types.ts` 中集中定义 TypeScript 类型。
4. Screen 组件的 `name` 必须使用常量定义（`SCREEN_NAMES`），禁止硬编码字符串。

```typescript
// src/app/navigation/types.ts
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
  Register: { referralCode?: string };
};

export type MainTabParamList = {
  HomeTab: undefined;
  OrdersTab: undefined;
  ProfileTab: undefined;
};

export type HomeStackParamList = {
  Home: undefined;
  ProductDetail: { productId: string };
};
```

---

## 原生代码管理（MUST）

1. `android/` 和 `ios/` 目录必须纳入版本控制。
2. iOS 依赖通过 **CocoaPods** 管理，`Podfile.lock` 必须提交。
3. Android 依赖通过 **Gradle** 管理，`gradle.properties` 中的签名信息使用变量引用。
4. 原生代码修改必须在 PR 中标注 `[NATIVE]` 标签，触发额外的构建验证。
5. 原生模块封装推荐使用 **TurboModules**（New Architecture），旧项目使用 Native Modules。
6. 原生桥接代码必须在 `android/app/src/main/java/` 和 `ios/` 对应目录中组织，禁止放在 `src/` 中。

---

## 路径别名（MUST）

1. 必须配置路径别名，避免深层相对路径导入：

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@features/*": ["src/features/*"],
      "@shared/*": ["src/shared/*"],
      "@theme/*": ["src/theme/*"],
      "@stores/*": ["src/stores/*"]
    }
  }
}
```

2. `babel.config.js` 中配置 `babel-plugin-module-resolver` 与 TypeScript paths 保持一致。
3. 禁止超过 3 层的相对路径导入（如 `../../../shared/utils/format`），必须使用别名。

---

## Provider 组织规范（MUST）

1. 全局 Provider 集中在 `src/app/providers/AppProviders.tsx` 中组合：

```tsx
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from '@/shared/providers/ThemeProvider';
import { queryClient } from '@/shared/services/api/queryClient';

export function AppProviders({ children }: { children: React.ReactNode }) {
  return (
    <SafeAreaProvider>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          <ErrorBoundary>
            {children}
          </ErrorBoundary>
        </ThemeProvider>
      </QueryClientProvider>
    </SafeAreaProvider>
  );
}
```

2. Provider 嵌套顺序：SafeArea → QueryClient → Theme → ErrorBoundary → Navigation。
3. 禁止在业务模块中重复创建全局 Provider。

---

## Fastlane 配置（SHOULD）

1. 推荐使用 **Fastlane** 自动化 iOS / Android 构建与分发。
2. `fastlane/` 目录包含 `Fastfile`（构建流程）、`Appfile`（应用信息）、`Matchfile`（证书管理）。
3. Fastlane 的 lane 按环境划分：`beta`（内测分发）、`release`（商店发布）。
4. 版本号自增推荐通过 Fastlane `increment_version_number` / `increment_build_number` 自动化。

---

## 禁止事项

1. 禁止原生目录（`android/` / `ios/`）不纳入版本控制。
2. 禁止在 `src/` 根目录散放业务文件（必须放在 `features/` 模块中）。
3. 禁止跨模块直接引用内部文件（必须通过 `index.ts` 导出）。
4. 禁止在业务模块中分散定义路由（必须集中在 `navigation/` 目录）。
5. 禁止超过 3 层相对路径导入。
6. 禁止在 `gradle.properties` 中硬编码签名密码（使用环境变量或 CI Secret）。
