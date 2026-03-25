# Tauri 桌面应用 PR 评审清单模板

## 文档目标
1. 用于 Tauri 桌面应用 PR 评审，评审人逐项核对，确保代码质量达标。

## 使用方式
1. **谁用**：PR 评审人（Reviewer）。
2. **何时用**：每次 Tauri 桌面应用 PR 提交评审时。
3. **怎么用**：复制清单到 PR 评审评论中，逐项勾选，未通过项写明阻塞原因。

## 优先级说明
1. `P0` 为阻塞项，必须全部通过才可合并。
2. `P1` 为改进项，允许带条件合并，但必须登记技术债与回收计划。

---

## PR 基本信息
- [ ] [P0] 已说明变更目的、影响范围、测试结果
- [ ] [P0] 已附关键场景测试结果

## Rust 代码质量
- [ ] [P0] `cargo fmt --check` 通过
- [ ] [P0] `cargo clippy -- -D warnings` 通过
- [ ] [P0] `cargo test` 全部通过
- [ ] [P0] `cargo audit` 无高危漏洞
- [ ] [P0] 无 `unwrap()` 出现在生产代码中
- [ ] [P0] 无 `unsafe` 块（或已经评审批准）
- [ ] [P0] 公开 API 有文档注释

## 架构与分层
- [ ] [P0] Command 仅做参数校验和调用转发，无业务逻辑
- [ ] [P0] Service 层不依赖 Tauri API
- [ ] [P0] 前端通过 API 层调用 IPC，无直接 `invoke()`
- [ ] [P0] 无循环依赖
- [ ] [P0] 新增 IPC 接口有对应的 TypeScript 类型定义

## 安全
- [ ] [P0] Capability 权限声明遵循最小权限原则
- [ ] [P0] CSP 配置严格，无 `unsafe-eval`
- [ ] [P0] 无硬编码密钥、Token、凭据
- [ ] [P0] 敏感数据使用系统密钥链存储
- [ ] [P0] 文件路径无 Path Traversal 风险
- [ ] [P0] HTTP 请求使用 HTTPS

## 错误处理
- [ ] [P0] Rust 侧使用统一 `AppError` 枚举
- [ ] [P0] 前端 IPC 调用有 `try/catch`
- [ ] [P0] 错误信息对用户友好，无内部细节泄露
- [ ] [P0] 无未处理的 Promise rejection

## 性能
- [ ] [P0] 无阻塞 UI 的同步操作
- [ ] [P1] 大数据集使用分页/虚拟滚动
- [ ] [P1] IPC 传输数据量合理（< 1MB）
- [ ] [P1] 无循环中逐条 `invoke()` 调用

## 前端质量
- [ ] [P0] TypeScript `strict: true`，无 `any` 类型
- [ ] [P0] 无 `console.log` 调试代码残留
- [ ] [P0] ESLint + Prettier 检查通过
- [ ] [P1] 组件有基本测试覆盖

## 测试
- [ ] [P0] `cargo test` + 前端测试通过
- [ ] [P0] 缺陷修复包含回归测试
- [ ] [P1] Service 层关键逻辑有单元测试

## 可观测性
- [ ] [P0] 使用 `tracing` 结构化日志，无 `println!` 调试代码
- [ ] [P0] 日志中无敏感信息

---

## 结论
- [ ] `Approve`（全部 `P0` 通过）
- [ ] `Request Changes`（存在任一 `P0` 未通过）
- [ ] `Conditional Approve`（`P0` 通过，存在 `P1` 未通过且已登记技术债）
