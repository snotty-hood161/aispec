# rules/tauri-desktop/profiles/tauri-v2/project-structure.md

## 适用场景
1. 跨平台桌面应用，使用 Tauri v2 框架。
2. Rust 后端 + Web 前端（React/Vue/Svelte/Solid）。
3. 支持平台：Windows、macOS、Linux。

## 推荐项目结构
```text
MyTauriApp/
├── src-tauri/                              # Rust 后端
│   ├── Cargo.toml                          # Rust 依赖管理
│   ├── tauri.conf.json                     # Tauri 核心配置
│   ├── capabilities/                       # 权限声明
│   │   └── main.json
│   ├── icons/                              # 应用图标（各平台）
│   ├── migrations/                         # 数据库迁移脚本
│   │   └── 001_init.sql
│   ├── src/
│   │   ├── main.rs                         # 入口
│   │   ├── lib.rs                          # 模块声明、Builder 配置
│   │   ├── commands/                       # Tauri Command（Controller 层）
│   │   │   ├── mod.rs
│   │   │   ├── user_commands.rs
│   │   │   └── file_commands.rs
│   │   ├── services/                       # 业务逻辑层
│   │   │   ├── mod.rs
│   │   │   ├── user_service.rs
│   │   │   └── update_service.rs
│   │   ├── models/                         # 数据模型 / DTO
│   │   │   ├── mod.rs
│   │   │   └── user.rs
│   │   ├── repositories/                   # 数据访问层
│   │   │   ├── mod.rs
│   │   │   └── user_repo.rs
│   │   ├── errors/                         # 统一错误类型
│   │   │   └── mod.rs
│   │   └── state/                          # 应用状态
│   │       └── mod.rs
│   └── config.default.toml                 # 默认运行时配置
│
├── src/                                    # Web 前端
│   ├── App.tsx                             # 根组件
│   ├── main.tsx                            # 前端入口
│   ├── api/                                # IPC 调用封装
│   │   ├── user.ts
│   │   └── file.ts
│   ├── pages/                              # 页面组件
│   │   ├── UserListPage.tsx
│   │   └── UserDetailPage.tsx
│   ├── components/                         # 通用 UI 组件
│   │   ├── UpdateDialog.tsx
│   │   └── ProgressBar.tsx
│   ├── stores/                             # 状态管理
│   │   └── userStore.ts
│   ├── hooks/                              # 自定义 Hooks
│   │   └── useUpdate.ts
│   ├── types/                              # TypeScript 类型
│   │   └── user.ts
│   └── utils/                              # 工具函数
│
├── package.json                            # 前端依赖
├── pnpm-lock.yaml
├── tsconfig.json
├── vite.config.ts                          # 前端构建配置
├── rust-toolchain.toml                     # Rust 版本锁定
└── .github/
    └── workflows/
        └── release.yml                     # CI/CD 发布流程
```

## Tauri v2 配置规则（MUST）

### tauri.conf.json 关键配置
```json
{
  "productName": "MyTauriApp",
  "version": "1.0.0",
  "identifier": "com.yourcompany.mytauriapp",
  "build": {
    "frontendDist": "../dist"
  },
  "app": {
    "security": {
      "csp": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"
    },
    "windows": [
      {
        "title": "MyTauriApp",
        "width": 1200,
        "height": 800,
        "minWidth": 800,
        "minHeight": 600,
        "center": true
      }
    ]
  },
  "bundle": {
    "active": true,
    "createUpdaterArtifacts": "v1Compatible",
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ]
  }
}
```

### 入口配置示例
```rust
// src-tauri/src/lib.rs
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_updater::Builder::new().build())
        .plugin(tauri_plugin_process::init())
        .plugin(tauri_plugin_store::Builder::new().build())
        .manage(AppState::new())
        .invoke_handler(tauri::generate_handler![
            commands::user_commands::get_user,
            commands::user_commands::create_user,
            commands::file_commands::read_file,
        ])
        .setup(|app| {
            let handle = app.handle().clone();
            tauri::async_runtime::spawn(async move {
                if let Err(e) = init_services(&handle).await {
                    tracing::error!("初始化失败: {:?}", e);
                }
            });
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

## 模块组织规则（MUST）

1. 每个 `commands/*.rs` 文件对应一个业务领域，在 `mod.rs` 中统一导出。
2. Command 函数仅做参数校验和 Service 调用，禁止包含业务逻辑。
3. `models/` 中定义 Rust 结构体，同时派生 `Serialize`/`Deserialize` 用于 IPC 传输。
4. `state/` 中定义 `AppState`，通过 `app.manage()` 注入，Command 通过 `tauri::State` 访问。
5. 前端 `api/` 层与 Rust `commands/` 一一对应，保持命名一致。

## 前端框架选择（SHOULD）

| 框架 | 推荐场景 | 备注 |
|------|---------|------|
| React + Zustand | 团队熟悉 React 生态 | 生态最丰富 |
| Vue 3 + Pinia | 团队熟悉 Vue 生态 | 上手快 |
| Svelte + SvelteKit | 追求极致性能和包体积 | 编译时框架 |
| Solid.js | 追求细粒度响应式 | 性能优秀 |

1. 前端框架选定后在项目生命周期内保持一致，禁止中途切换。
2. 构建工具推荐 Vite（Tauri 官方推荐）。
