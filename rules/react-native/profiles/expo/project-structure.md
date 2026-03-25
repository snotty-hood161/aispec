# rules/react-native/profiles/expo/project-structure.md

## 文档目标
1. 定义基于 Expo 的 React Native 项目目录结构规范，适用于 Expo Managed Workflow 和 Expo Router。

---

## 项目初始化（MUST）

1. 新项目必须通过 `npx create-expo-app` 创建，使用最新的 Expo SDK 版本。
2. 推荐使用 **Expo Router**（基于文件系统路由）作为导航方案。
3. 项目必须使用 `app.config.ts`（TypeScript 动态配置）替代 `app.json`。
4. 必须在创建后立即配置 TypeScript strict 模式和 ESLint。
5. Expo SDK 版本升级必须使用 `npx expo install --fix` 确保依赖兼容。

---

## 目录结构（MUST）

1. Expo Router 项目必须遵循以下目录结构：

```
my-expo-app/
├── app/                          # 路由目录（Expo Router 文件系统路由）
│   ├── _layout.tsx               # 根布局（导航容器、Provider 注入）
│   ├── index.tsx                  # 首页路由 /
│   ├── (auth)/                   # 认证相关路由组
│   │   ├── _layout.tsx           # 认证路由组布局
│   │   ├── login.tsx             # 登录页 /login
│   │   └── register.tsx          # 注册页 /register
│   ├── (tabs)/                   # Tab 导航路由组
│   │   ├── _layout.tsx           # Tab 布局定义
│   │   ├── home.tsx              # 首页 Tab
│   │   ├── orders.tsx            # 订单 Tab
│   │   └── profile.tsx           # 我的 Tab
│   ├── order/
│   │   └── [id].tsx              # 订单详情（动态路由） /order/:id
│   └── +not-found.tsx            # 404 页面
├── src/                          # 业务源码
│   ├── components/               # 可复用 UI 组件
│   │   ├── ui/                   # 基础 UI 组件（AppButton / AppText / AppInput）
│   │   └── business/             # 业务组件（OrderCard / UserAvatar）
│   ├── hooks/                    # 自定义 Hook
│   │   ├── useAuth.ts
│   │   └── useOrderList.ts
│   ├── services/                 # Service 层（API 调用 / 业务逻辑）
│   │   ├── api/                  # API Client 与接口定义
│   │   │   ├── client.ts         # Axios 实例与拦截器
│   │   │   ├── authApi.ts
│   │   │   └── orderApi.ts
│   │   ├── authService.ts
│   │   └── orderService.ts
│   ├── stores/                   # 状态管理（Zustand / Redux）
│   │   ├── authStore.ts
│   │   └── appStore.ts
│   ├── models/                   # TypeScript 类型定义
│   │   ├── user.types.ts
│   │   ├── order.types.ts
│   │   └── api.types.ts
│   ├── utils/                    # 工具函数
│   │   ├── dateUtils.ts
│   │   ├── formatCurrency.ts
│   │   └── validation.ts
│   ├── constants/                # 常量定义
│   │   ├── config.ts
│   │   └── enums.ts
│   ├── theme/                    # 主题系统
│   │   ├── index.ts
│   │   ├── colors.ts
│   │   ├── typography.ts
│   │   └── spacing.ts
│   ├── i18n/                     # 国际化
│   │   ├── index.ts
│   │   ├── zh.json
│   │   └── en.json
│   └── providers/                # React Context Providers
│       ├── ThemeProvider.tsx
│       └── AuthProvider.tsx
├── assets/                       # 静态资源
│   ├── images/
│   ├── fonts/
│   └── icons/
├── __tests__/                    # 测试文件（或与源文件同目录）
├── app.config.ts                 # Expo 动态配置
├── babel.config.js               # Babel 配置
├── metro.config.js               # Metro 配置（如需自定义）
├── tsconfig.json                 # TypeScript 配置
├── .eslintrc.js                  # ESLint 配置
├── .prettierrc                   # Prettier 配置
├── .env.example                  # 环境变量模板
├── eas.json                      # EAS Build / Update 配置
└── package.json
```

---

## Expo Router 路由规范（MUST）

1. 路由文件必须是默认导出的 React 组件（`export default function`）。
2. 路由分组使用 `(groupName)` 目录，不影响 URL 路径。
3. 布局文件 `_layout.tsx` 必须在每个路由组根目录定义导航结构。
4. 动态路由使用 `[paramName].tsx` 命名，参数通过 `useLocalSearchParams` 获取。
5. 404 页面必须使用 `+not-found.tsx` 定义。
6. API Routes（如使用）放在 `app/api/` 目录下。
7. 路由文件中禁止包含业务逻辑，仅负责布局与页面组件组合。

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { useTheme } from '@/theme';

export default function TabLayout() {
  const theme = useTheme();
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: theme.colors.primary,
        headerShown: false,
      }}
    >
      <Tabs.Screen name="home" options={{ title: '首页', tabBarIcon: ... }} />
      <Tabs.Screen name="orders" options={{ title: '订单', tabBarIcon: ... }} />
      <Tabs.Screen name="profile" options={{ title: '我的', tabBarIcon: ... }} />
    </Tabs>
  );
}
```

---

## Expo 配置规范（MUST）

1. 必须使用 `app.config.ts` 动态配置，支持环境变量注入：

```typescript
import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: process.env.APP_NAME ?? 'MyApp',
  slug: 'my-app',
  version: '1.0.0',
  orientation: 'portrait',
  scheme: 'myapp',
  ios: {
    bundleIdentifier: process.env.IOS_BUNDLE_ID ?? 'com.company.myapp',
    supportsTablet: true,
  },
  android: {
    package: process.env.ANDROID_PACKAGE ?? 'com.company.myapp',
    adaptiveIcon: { foregroundImage: './assets/adaptive-icon.png' },
  },
  plugins: ['expo-router', 'expo-secure-store'],
  extra: {
    eas: { projectId: process.env.EAS_PROJECT_ID },
  },
});
```

2. `eas.json` 必须配置 `development` / `preview` / `production` 三个 Build Profile。
3. EAS Update 的 channel 必须与 Build Profile 对应（`preview` → `staging`，`production` → `production`）。

---

## EAS 构建与更新（MUST）

1. 构建必须通过 **EAS Build** 执行，禁止从本地机器直接构建上传。
2. OTA 更新使用 **EAS Update**，配置灰度发布策略。
3. `eas.json` 配置示例：

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "channel": "staging"
    },
    "production": {
      "channel": "production",
      "autoIncrement": true
    }
  }
}
```

4. Development Build 必须使用 **Expo Dev Client**（`expo-dev-client`），替代 Expo Go 以支持原生模块。

---

## 路径别名（MUST）

1. 必须配置路径别名 `@/` 指向 `src/` 目录，避免深层相对路径导入：

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

2. `babel.config.js` 中配置 `babel-plugin-module-resolver` 与 TypeScript paths 保持一致。
3. 禁止超过 3 层的相对路径导入（如 `../../../utils/format`），必须使用别名。

---

## Expo 特有规范（MUST）

1. 优先使用 Expo SDK 内置模块（`expo-camera` / `expo-location` / `expo-notifications`），而非社区同功能包。
2. 需要原生自定义代码时使用 **Config Plugins**（`expo-build-properties`），禁止直接修改 `android/` 或 `ios/` 目录。
3. `npx expo prebuild` 生成的原生目录（`android/` / `ios/`）推荐加入 `.gitignore`（Continuous Native Generation 模式）。
4. 使用 `expo-secure-store` 替代 `AsyncStorage` 存储敏感数据。
5. 推荐使用 `expo-constants` 读取运行时配置，替代 `react-native-config`。

---

## 禁止事项

1. 禁止在 Expo 项目中直接修改 `android/` / `ios/` 原生目录（使用 Config Plugins）。
2. 禁止使用 Expo Go 测试包含原生模块的功能（使用 Dev Client）。
3. 禁止路由文件中包含业务逻辑代码。
4. 禁止超过 3 层相对路径导入。
5. 禁止从本地机器直接构建生产版本。
