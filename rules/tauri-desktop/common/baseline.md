# rules/tauri-desktop/common/baseline.md

## 技术基线
1. Rust 版本以 `rust-toolchain.toml` 为准，推荐 stable 最新版，升级版本必须单独提交并验证兼容性。
2. Tauri 版本：新项目必须使用 **Tauri v2**，禁止新建 Tauri v1 项目。
3. 前端框架不限（React/Vue/Svelte/Solid），但必须使用 TypeScript。
4. 包管理：Rust 侧使用 Cargo，前端侧使用 pnpm（首选）或 npm。
5. 提交前必须确保 `cargo check` 和前端构建均无错误。

## Rust 工具链要求（MUST）

1. `rust-toolchain.toml` 必须纳入版本控制，锁定 Rust 版本。
2. 必须启用以下 Clippy lint：
   ```toml
   # Cargo.toml
   [lints.clippy]
   all = { level = "warn", priority = -1 }
   pedantic = { level = "warn", priority = -1 }
   unwrap_used = "deny"
   expect_used = "warn"
   ```
3. CI 流水线必须执行 `cargo clippy -- -D warnings` 和 `cargo fmt --check`。
4. 必须启用 `cargo audit` 检测已知漏洞依赖，高危漏洞（CVSS >= 7.0）阻断合并。
