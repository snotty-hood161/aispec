# 可自动检查的规则条目清单

本文件列出可在代码审查中自动/半自动检查的规则条目，按来源文件分组。

## 使用方式
1. 根据变更文件路径与内容，匹配下方检查项。
2. 每项标注检查方式：`静态扫描`（cargo clippy/rustfmt/CI）/ `模式匹配`（正则/AST）/ `人工审查`。
3. P0 项必须全部通过，P1 项允许带条件通过。

---

## 一、技术基线（common/baseline.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| BL-01 | P0 | Rust edition 2021+ 且 Cargo.toml 指定 edition | 静态扫描：检查 Cargo.toml edition 字段 |
| BL-02 | P0 | Tauri 版本符合基线要求（v2.x） | 静态扫描：检查 Cargo.toml tauri 依赖版本 |
| BL-03 | P0 | cargo clippy 零警告 | 静态扫描：CI cargo clippy -- -D warnings |
| BL-04 | P0 | rustfmt 格式化通过 | 静态扫描：cargo fmt --check |

## 二、代码风格（common/code-style.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CS-01 | P0 | 函数/变量使用 snake_case | 静态扫描：Clippy non_snake_case |
| CS-02 | P0 | 类型/Trait 使用 PascalCase | 静态扫描：Clippy non_camel_case_types |
| CS-03 | P0 | 常量使用 UPPER_SNAKE_CASE | 静态扫描：Clippy non_upper_case_globals |
| CS-04 | P0 | 公共 API 有 rustdoc 注释 | 静态扫描：#![warn(missing_docs)] |
| CS-05 | P0 | 无 todo! / unimplemented! / dbg! 遗留 | 模式匹配：关键词扫描 |

## 三、架构（common/architecture.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AR-01 | P0 | IPC 命令使用 #[tauri::command] 宏注册 | 模式匹配：command 函数有宏标注且在 Builder 中注册 |
| AR-02 | P0 | 前后端通信走 invoke，禁止直接 HTTP 调用后端 | 模式匹配：前端代码中无 localhost / 127.0.0.1 API 调用 |
| AR-03 | P0 | 状态管理通过 tauri::State 注入 | 模式匹配：全局可变状态使用 State<> 而非 static mut |
| AR-04 | P0 | 前端组件不直接调用 Rust FFI | 人工审查 |

## 四、错误处理（common/error-handling.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| EH-01 | P0 | Command 返回 Result<T, E> 统一错误类型 | 模式匹配：#[tauri::command] 函数返回值签名检查 |
| EH-02 | P0 | 自定义 Error enum 实现 Serialize | 模式匹配：Error 类型 derive 检查 |
| EH-03 | P0 | 前端 invoke 调用有 .catch() 错误处理 | 模式匹配：invoke() 调用链中 catch/try-catch 检查 |
| EH-04 | P0 | 禁止 unwrap() / expect() 在生产代码路径 | 模式匹配：非测试文件中 unwrap/expect 调用扫描 |

## 五、安全（common/security.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| SC-01 | P0 | tauri.conf.json 权限最小化，禁止 all 权限 | 模式匹配：capabilities 配置中无 "all" 通配 |
| SC-02 | P0 | CSP 配置限制资源加载来源 | 模式匹配：检查 tauri.conf.json security.csp |
| SC-03 | P0 | 文件系统访问使用 scope 限制 | 模式匹配：fs plugin scope 配置检查 |
| SC-04 | P0 | 禁止 dangerousRemoteDomainIpcAccess | 模式匹配：tauri.conf.json 配置扫描 |
| SC-05 | P0 | Shell 命令白名单限制 | 模式匹配：shell plugin sidecar/scope 配置检查 |

## 六、数据访问（common/data-access.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| DA-01 | P0 | SQLite 访问通过统一数据层封装 | 模式匹配：command 中无直接 SQL 拼接 |
| DA-02 | P0 | 远程 API 调用通过 Service 模块封装 | 模式匹配：command 中无 reqwest 直接调用 |
| DA-03 | P0 | 数据库连接使用连接池（r2d2 / deadpool） | 模式匹配：连接池依赖引用检查 |
| DA-04 | P1 | 离线场景有降级处理 | 人工审查 |

## 七、配置管理（common/configuration.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| CF-01 | P0 | 敏感配置不硬编码 | 模式匹配：密钥/密码/secret 关键词扫描 |
| CF-02 | P0 | 环境配置通过 tauri.conf.json 或 .env 管理 | 模式匹配：硬编码 URL/端口检查 |
| CF-03 | P0 | 用户设置使用 tauri-plugin-store 持久化 | 模式匹配：用户配置存储方式检查 |

## 八、可观测性（common/observability.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| OB-01 | P0 | 后端使用 tracing crate 结构化日志 | 模式匹配：tracing 依赖与 #[instrument] 使用检查 |
| OB-02 | P0 | 崩溃报告自动收集并上报 | 人工审查 |
| OB-03 | P0 | 日志不包含敏感信息（密码、Token） | 人工审查 |
| OB-04 | P1 | 关键业务操作有遥测埋点 | 人工审查 |

## 九、性能（common/performance.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| PF-01 | P0 | 启动时间优化（延迟加载非关键模块） | 人工审查：启动流程检查 |
| PF-02 | P0 | 大数据传输使用 streaming / 分页 | 人工审查 |
| PF-03 | P0 | 前端资源按需加载（code splitting） | 模式匹配：路由懒加载检查 |
| PF-04 | P1 | Rust 侧避免不必要的 clone / copy | 人工审查 |

## 十、自动更新（common/auto-update.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| AU-01 | P0 | 使用 Tauri Updater Plugin 集成更新 | 模式匹配：tauri-plugin-updater 依赖与配置检查 |
| AU-02 | P0 | 更新端点使用 HTTPS | 模式匹配：更新 URL 协议检查 |
| AU-03 | P0 | 更新有用户交互确认 | 人工审查 |

## 十一、测试与发布（common/testing-and-release.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TR-01 | P0 | Rust 核心逻辑有单元测试 | 模式匹配：#[cfg(test)] mod tests 存在 |
| TR-02 | P0 | 前端组件有测试覆盖 | 模式匹配：.test / .spec 文件存在 |
| TR-03 | P0 | CI/CD 包含 cargo test + 前端 test + 构建 | 人工审查 |
| TR-04 | P0 | 打包配置正确（签名/版本号/图标） | 人工审查 |

## 十二、禁止事项（common/forbidden.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| FB-01 | P0 | 禁止 unsafe 块（除有安全注释说明） | 模式匹配：unsafe 关键词扫描，有注释则人工审查 |
| FB-02 | P0 | 禁止 println! / eprintln! 在生产代码 | 模式匹配：关键词扫描（应使用 tracing） |
| FB-03 | P0 | 禁止前端直接访问 Node.js API | 模式匹配：require() / process. / fs. 调用检查 |

---

## 十三、框架专项检查

### Tauri v2 追加项（profiles/tauri-v2/project-structure.md）

| ID | 级别 | 检查项 | 检查方式 |
|----|------|--------|----------|
| TV-01 | P0 | 项目结构符合 Tauri v2 标准模板（src-tauri/src/、src/） | 人工审查 |
| TV-02 | P0 | Plugin 注册在 lib.rs / main.rs 统一管理 | 模式匹配：plugin 注册集中度检查 |
| TV-03 | P0 | 前端入口配置正确（build.frontendDist） | 模式匹配：检查 tauri.conf.json build 配置 |
