# rules/react-native/common/data-access.md

## 文档目标
1. 定义 React Native 应用的数据访问规范，覆盖 API 调用、离线缓存、数据持久化。

---

## API 调用规范（MUST）

1. HTTP 请求必须通过统一封装的 API Client 发起，禁止在组件中直接调用 `fetch` / `axios`。
2. 推荐使用 **axios** 作为 HTTP Client，配合拦截器统一处理：
   - 请求拦截：注入 Token、设置公共 Header（Platform / Version / DeviceId）。
   - 响应拦截：统一错误码处理、Token 刷新、重试逻辑。

```typescript
import axios from 'axios';

const apiClient = axios.create({
  baseURL: Config.API_BASE_URL,
  timeout: 30_000,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use((config) => {
  const token = secureStorage.getString('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    if (error.response?.status === 401) {
      return handleTokenRefresh(error);
    }
    throw toAppError(error);
  },
);
```

3. 所有 API 接口必须定义请求参数和响应数据的 TypeScript 类型。
4. API 函数按业务模块组织在 `services/` 目录，每个模块一个文件。
5. 禁止在 URL 中拼接敏感参数（Token、密码），必须通过 Header 或 Body 传输。

---

## 服务端状态管理（MUST）

1. 服务端数据（API 返回的列表、详情等）推荐使用 **TanStack Query** 管理：
   - 自动缓存、去重请求、失效重取。
   - `staleTime` 根据业务场景配置（频繁变化的数据 < 30s，静态数据 > 5min）。

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useOrderList(params: OrderListParams) {
  return useQuery({
    queryKey: ['orders', params],
    queryFn: () => orderService.getOrders(params),
    staleTime: 30_000,
  });
}

export function useCancelOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (orderId: string) => orderService.cancelOrder(orderId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['orders'] }),
  });
}
```

2. 禁止手动管理 loading / error / data 三态（应使用 TanStack Query 的返回值）。
3. 列表数据分页推荐使用 `useInfiniteQuery`。
4. 乐观更新推荐使用 `useMutation` 的 `onMutate` / `onError` / `onSettled` 回调。

---

## 数据传输对象（MUST）

1. API 返回的原始数据（DTO）必须在 Service 层转换为前端 Model 类型，禁止在 UI 层直接使用 DTO。
2. 禁止使用 `Record<string, any>` 或 `object` 作为 API 响应类型。
3. 推荐使用 **zod** 在运行时校验 API 响应结构，防止后端字段变更导致运行时崩溃。

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  createdAt: z.string().transform((s) => new Date(s)),
});

type User = z.infer<typeof UserSchema>;
```

4. DTO → Model 的转换函数必须集中定义，禁止在多处重复编写转换逻辑。

---

## 离线缓存（SHOULD）

1. 需要离线访问的数据推荐使用 **WatermelonDB**（大量结构化数据）或 **react-native-mmkv**（小量键值数据）。
2. 缓存策略必须明确（任选其一并在文档中标注）：
   - **Cache First**：优先读缓存，后台更新。
   - **Network First**：优先网络，失败回退缓存。
   - **Stale While Revalidate**：返回缓存同时异步刷新。
3. 缓存数据必须设置过期时间（TTL），定期清理过期数据。
4. TanStack Query 配合 `@tanstack/query-async-storage-persister` 实现查询缓存持久化。

---

## 数据持久化（MUST）

1. 持久化方案按数据类型选择：

| 数据类型 | 推荐方案 | 备注 |
|---------|---------|------|
| 用户偏好 / 配置 | `react-native-mmkv` | 高性能同步读写 |
| 敏感凭证 | `react-native-keychain` | 平台安全存储 |
| 结构化业务数据 | `WatermelonDB` / `@nozbe/watermelondb` | 大量数据 + 离线同步 |
| 简单缓存 | `react-native-mmkv` | 替代 AsyncStorage |
| 文件 / 图片缓存 | `react-native-fs` + 缓存目录 | 二进制文件 |

2. 禁止使用 `AsyncStorage` 存储大量数据（> 6MB）或高频读写数据。
3. 数据库操作推荐在后台线程执行（WatermelonDB 默认支持）。
4. 应用卸载时敏感数据必须随之清除（Keychain 数据默认不随卸载删除，需特别处理 iOS）。

---

## 数据同步（SHOULD）

1. 离线数据修改推荐实现乐观更新 + 冲突检测机制。
2. 同步失败的操作必须进入重试队列，恢复网络后自动重试。
3. 大量数据同步使用增量更新（基于时间戳 / 版本号），避免全量拉取。
4. 同步状态必须对用户可见（同步中 / 已同步 / 同步失败）。

---

## 禁止事项

1. 禁止在组件中直接调用 `fetch` / `axios` 发起请求。
2. 禁止使用 `Record<string, any>` 作为 API 响应类型。
3. 禁止在 `AsyncStorage` 中存储 > 6MB 数据。
4. 禁止在 JS 线程中执行耗时的数据库查询（使用后台线程）。
5. 禁止 API 响应数据未经类型校验直接渲染到 UI。
