# rules/tauri-desktop/common/architecture.md

## 整体架构

Tauri 应用采用"Rust 后端 + Web 前端"双进程架构：
- **Rust Core**：系统级操作（文件、网络、数据库、加密）、业务逻辑、状态管理。
- **WebView Frontend**：UI 渲染、用户交互、展示逻辑。
- **IPC Bridge**：通过 Tauri Command 和 Event 连接前后端。

## 分层规则（MUST）

### Rust 侧分层
```text
src-tauri/src/
├── main.rs              # 入口，Tauri Builder 配置
├── lib.rs               # 模块声明
├── commands/            # Tauri Command 定义（类似 Controller）
│   ├── mod.rs
│   ├── user_commands.rs
│   └── file_commands.rs
├── services/            # 业务逻辑层
│   ├── mod.rs
│   ├── user_service.rs
│   └── update_service.rs
├── models/              # 数据模型
│   ├── mod.rs
│   └── user.rs
├── repositories/        # 数据访问层
│   ├── mod.rs
│   └── user_repo.rs
├── errors/              # 错误类型定义
│   └── mod.rs
└── state/               # 应用状态（Tauri Managed State）
    └── mod.rs
```

### 前端侧分层
```text
src/
├── App.tsx              # 根组件
├── api/                 # IPC 调用封装层（禁止组件直接 invoke）
│   ├── user.ts
│   └── file.ts
├── pages/               # 页面组件
├── components/          # 通用 UI 组件
├── stores/              # 状态管理（Zustand/Pinia/Signals）
├── hooks/               # 自定义 Hooks
├── types/               # TypeScript 类型定义
└── utils/               # 工具函数
```

### 依赖方向
```
Frontend Component → API Layer → [IPC] → Tauri Command → Service → Repository
```

1. 前端组件禁止直接调用 `invoke()`，必须通过 `api/` 层封装。
2. Tauri Command 仅做参数校验和调用转发，禁止包含业务逻辑。
3. Service 层包含核心业务逻辑，禁止依赖 Tauri API。
4. Repository 层负责数据持久化，禁止依赖 Service 层。

## IPC 通信规范（MUST）

### Tauri Command
```rust
// commands/user_commands.rs
#[tauri::command]
async fn get_user(
    state: tauri::State<'_, AppState>,
    user_id: i64,
) -> Result<UserDto, AppError> {
    let service = &state.user_service;
    service.get_user(user_id).await
}
```

```typescript
// api/user.ts
import { invoke } from '@tauri-apps/api/core';
import type { UserDto } from '@/types/user';

export async function getUser(userId: number): Promise<UserDto> {
  return invoke<UserDto>('get_user', { userId });
}
```

### 规则
1. Command 函数参数使用 `snake_case`，Tauri 自动转换为前端的 `camelCase`。
2. Command 返回值必须是 `Result<T, E>`，`E` 实现 `Serialize`。
3. 需要访问应用状态时使用 `tauri::State<'_, T>`，禁止使用全局 `static mut`。
4. 长耗时操作使用 Event 推送进度，禁止在 Command 中长时间阻塞。

### Tauri Event（后端 → 前端推送）
```rust
// 后端推送进度
app_handle.emit("download-progress", ProgressPayload { percent: 75 })?;
```

```typescript
// 前端监听
import { listen } from '@tauri-apps/api/event';

const unlisten = await listen<ProgressPayload>('download-progress', (event) => {
  setProgress(event.payload.percent);
});
// 组件卸载时取消监听
unlisten();
```

## 状态管理（MUST）

### Rust 侧
1. 应用级状态使用 `app.manage(state)` 注入，通过 `tauri::State` 访问。
2. 状态结构体内部可变字段使用 `Mutex<T>` 或 `RwLock<T>` 保护。
3. 禁止使用 `lazy_static!` + `static mut` 管理可变状态。

```rust
pub struct AppState {
    pub db: sqlx::SqlitePool,
    pub user_service: UserService,
    pub settings: RwLock<AppSettings>,
}
```

### 前端侧
1. 使用框架对应的状态管理方案（React: Zustand、Vue: Pinia、Svelte: Stores）。
2. 来自 Rust 侧的数据通过 IPC 获取后存入前端 Store，禁止在多个组件中重复调用 IPC。
3. 前端状态与 Rust 状态保持单一数据源原则：持久化数据以 Rust 侧为准。
