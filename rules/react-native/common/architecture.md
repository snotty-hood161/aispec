# rules/react-native/common/architecture.md

## 文档目标
1. 定义 React Native 应用的架构分层与状态管理规范，确保可维护性和可测试性。

---

## 分层架构（MUST）

1. 必须采用清晰的分层架构，推荐四层结构：

```
┌─────────────────────────┐
│      UI Layer           │  Screen / Component / Navigation
├─────────────────────────┤
│      Hook Layer         │  Custom Hooks（组合业务逻辑与 UI 状态）
├─────────────────────────┤
│    Service Layer        │  API 调用 / 业务逻辑 / 数据转换
├─────────────────────────┤
│     Model Layer         │  TypeScript 类型定义 / 枚举 / 常量
└─────────────────────────┘
```

2. 依赖方向单向流动：`UI → Hook → Service → Model`。
3. Service 层不依赖 React（纯 TypeScript），便于单元测试。
4. 外部依赖（网络请求、本地存储、原生模块）通过 Service 层封装，UI / Hook 层不直接调用。
5. Model 层为纯类型定义，不包含任何逻辑代码。

---

## 状态管理（MUST）

1. 必须使用团队统一的状态管理方案，禁止同项目混用多种全局状态方案。
2. 推荐方案（任选其一，项目初始化时确定）：
   - **Zustand**：轻量级，适合中大型项目，API 简洁。
   - **Redux Toolkit**（`@reduxjs/toolkit`）：适合大型项目、需要严格数据流追踪。
   - **Jotai**：原子化状态管理，适合精细粒度状态场景。
3. 服务端状态（API 数据）推荐使用 **TanStack Query**（`@tanstack/react-query`），与本地状态分离管理。
4. 组件内部局部 UI 状态允许使用 `useState` / `useReducer`，禁止将其用于跨组件共享状态。
5. 状态 Store 必须是可序列化的纯对象，禁止在 Store 中存储函数、类实例或 React 组件。
6. 状态变更必须可追踪：Zustand 集成 devtools middleware，Redux 集成 Redux DevTools。

```typescript
// Zustand Store 示例
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  devtools(
    (set) => ({
      user: null,
      isAuthenticated: false,
      login: async (credentials) => {
        const user = await authService.login(credentials);
        set({ user, isAuthenticated: true });
      },
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    { name: 'AuthStore' },
  ),
);
```

---

## 导航架构（MUST）

1. 必须使用 **React Navigation**（`@react-navigation/native`）或 **Expo Router** 管理导航。
2. 导航结构定义必须集中管理，禁止在业务组件中分散定义路由。
3. 导航参数必须使用 TypeScript 类型约束：

```typescript
type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string };
  OrderDetail: { orderId: string; from?: 'list' | 'push' };
};

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
```

4. 深层嵌套导航不超过 3 层（Stack → Tab → Stack），超过时重构为平铺结构。
5. 导航事件处理（页面聚焦/失焦）使用 `useFocusEffect`，禁止在 `useEffect` 中监听导航状态。

---

## 依赖注入（SHOULD）

1. Service 层依赖通过模块导出 / React Context 注入，禁止在组件中直接实例化 Service。
2. 推荐使用 React Context + Provider 模式注入全局服务依赖。
3. 测试时通过 Provider 替换为 Mock 实现。
4. 复杂项目可引入轻量 DI 容器（如 `tsyringe` / `inversify`）管理 Service 依赖关系。

---

## 单向数据流（MUST）

1. UI 数据流必须为单向：`User Action → State Update → UI Re-render`。
2. 组件只负责：
   - 触发 Action（用户交互 → 调用 Hook / dispatch）。
   - 渲染状态（State → JSX）。
3. 禁止在组件中直接调用 `fetch` / `axios` 发起网络请求（必须通过 Hook / Service 封装）。
4. 禁止组件之间通过超过 2 层的 Props 传递复杂状态（应使用状态管理或 Context）。

---

## Custom Hook 规范（MUST）

1. 共享业务逻辑必须封装为 Custom Hook，一个 Hook 只做一件事。
2. Hook 必须以 `use` 前缀命名，返回值使用语义化结构：

```typescript
interface UseOrderListReturn {
  orders: Order[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
  loadMore: () => void;
}

export function useOrderList(params: OrderListParams): UseOrderListReturn {
  // ...
}
```

3. Hook 内禁止直接操作 UI（如 `Alert.alert`），UI 交互通过返回值让组件层处理。
4. Hook 依赖的外部服务通过参数注入或模块导入，便于测试 Mock。

---

## 模块化（SHOULD）

1. 大型项目推荐按功能模块组织目录，每个模块包含完整的 screens / components / hooks / services。
2. 公共模块（网络、存储、主题）提取到 `shared/` 或 `core/` 目录。
3. 模块间通过 `index.ts` 暴露公开 API，禁止直接引用其他模块的内部文件。
4. Monorepo 使用 Turborepo / Nx 管理多 Package 构建与依赖。
