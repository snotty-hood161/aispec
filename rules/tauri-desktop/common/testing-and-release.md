# rules/tauri-desktop/common/testing-and-release.md

## 文档目标
1. 定义 Tauri 桌面应用的测试策略和发布流程。

---

## 测试策略（MUST）

### Rust 侧测试
1. Service 层和 Repository 层必须有单元测试。
2. 使用 `#[cfg(test)]` 模块组织测试代码。
3. 异步测试使用 `#[tokio::test]`。
4. Mock 外部依赖使用 `mockall` crate。

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_user_returns_user() {
        let mut mock_repo = MockUserRepository::new();
        mock_repo.expect_find_by_id()
            .with(eq(1))
            .returning(|_| Ok(Some(User { id: 1, name: "test".into() })));

        let service = UserService::new(mock_repo);
        let result = service.get_user(1).await.unwrap();
        assert_eq!(result.name, "test");
    }
}
```

### 前端测试
1. 组件测试使用框架对应工具（React: Vitest + Testing Library、Vue: Vitest + Vue Test Utils）。
2. IPC 调用在测试中 Mock（`vi.mock('@tauri-apps/api/core')`）。
3. E2E 测试使用 WebDriver（Tauri 内置 WebDriver 支持）。

### 测试覆盖率
1. Rust 侧：`cargo tarpaulin` 或 `cargo llvm-cov`，核心业务逻辑覆盖率 >= 70%。
2. 前端侧：Vitest coverage，组件覆盖率 >= 60%。

---

## CI 流水线（MUST）

```yaml
# 每次 PR 必须通过的检查
- cargo fmt --check          # Rust 格式化
- cargo clippy -- -D warnings # Rust lint
- cargo test                  # Rust 单元测试
- cargo audit                 # Rust 依赖漏洞
- pnpm lint                   # 前端 lint
- pnpm test                   # 前端测试
- pnpm tauri build            # 构建验证
```

1. 以上检查全部通过才允许合并 PR。
2. `cargo audit` 发现高危漏洞（CVSS >= 7.0）阻断合并。

---

## 发布流程（MUST）

### 版本号规范
1. 遵循 SemVer（`MAJOR.MINOR.PATCH`）。
2. 版本号在 `Cargo.toml` 和 `tauri.conf.json` 中同步维护。
3. 推荐使用 `cargo-release` 或脚本自动同步版本号。

### 发布检查清单
1. 所有测试通过。
2. CHANGELOG 已更新。
3. 版本号已递增。
4. 签名密钥已配置到 CI/CD。
5. 更新端点已部署并可访问。

### 打包格式

| 平台 | 安装包格式 | 更新包格式 |
|------|-----------|-----------|
| Windows | NSIS `.exe` | `.nsis.zip` + `.sig` |
| macOS | `.dmg` | `.app.tar.gz` + `.sig` |
| Linux | `.AppImage` / `.deb` | `.AppImage.tar.gz` + `.sig` |

### 代码签名（MUST）
1. Windows：使用 Authenticode 证书签名（EV 证书可避免 SmartScreen 警告）。
2. macOS：使用 Apple Developer ID 签名 + 公证（Notarization）。
3. Linux：使用 GPG 签名（可选）。
4. 签名证书/密钥通过 CI/CD Secret 管理，禁止提交到版本控制。
