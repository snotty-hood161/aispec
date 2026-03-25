# rules/tauri-desktop/common/forbidden.md

## 文档目标
1. 汇总 Tauri 桌面应用开发中的禁止事项，便于快速检查。

---

## Rust 侧禁止事项

1. 禁止在生产代码中使用 `unwrap()`，必须使用 `?` 或 `expect("明确原因")`。
2. 禁止使用 `unsafe` 块（除非经评审批准并注释说明）。
3. 禁止使用 `lazy_static!` + `static mut` 管理可变状态。
4. 禁止在 Tauri Command 中执行长时间阻塞操作而不使用异步。
5. 禁止在 Command 中包含业务逻辑（Command 仅做参数校验和调用转发）。
6. 禁止硬编码 API 地址、密钥、凭据。
7. 禁止同步文件 I/O 阻塞异步运行时。
8. 禁止忽略 `Result` 返回值（`let _ = ...` 需注释说明原因）。

## 前端侧禁止事项

9. 禁止在组件中直接调用 `invoke()`，必须通过 API 层封装。
10. 禁止使用 `any` 类型（TypeScript `strict: true`）。
11. 禁止生产环境残留 `console.log` 调试代码。
12. 禁止使用 `alert()` 展示错误信息。
13. 禁止在前端硬编码敏感信息（Token、密钥）。
14. 禁止未处理的 Promise rejection。
15. 禁止在循环中逐条调用 `invoke()`（应合并为批量操作）。

## 安全禁止事项

16. 禁止使用 `dangerousRemoteDomainIpcAccess`。
17. 禁止在 CSP 中使用 `unsafe-eval`。
18. 禁止禁用 SSL 证书校验。
19. 禁止将敏感数据存储在 `localStorage` 或 `tauri-plugin-store`。
20. 禁止在生产构建中启用 DevTools。
21. 禁止跳过更新包签名验证。
22. 禁止将签名私钥提交到版本控制。

## 架构禁止事项

23. 禁止前端直接操作数据库（必须通过 Rust 侧 IPC）。
24. 禁止前端直接调用外部 HTTP API（必须通过 Rust 侧代理）。
25. 禁止 Service 层依赖 Tauri API（保持可测试性）。
26. 禁止循环依赖（模块间单向依赖）。

## 发布禁止事项

27. 禁止要求用户手动访问官网下载安装包进行更新。
28. 禁止自行实现"下载 zip → 解压覆盖"的更新逻辑。
29. 禁止跳过代码签名直接分发安装包。
30. 禁止发布未经 `cargo clippy` 和 `cargo test` 验证的代码。
