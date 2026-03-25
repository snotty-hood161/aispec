# rules/electron-desktop/common/testing-and-release.md

## 文档目标
1. 定义 Electron 桌面应用的测试策略和发布流程。

---

## 测试策略（MUST）

### 主进程测试
1. Service 层和 Repository 层必须有单元测试。
2. 使用 Vitest 或 Jest 执行测试，推荐 Vitest。
3. Mock Electron API 使用 `electron-mock-ipc` 或手动 mock。
4. IPC handler 测试覆盖参数校验与错误路径。

```typescript
// services/__tests__/userService.test.ts
import { describe, it, expect, vi } from 'vitest';
import { UserService } from '../userService';

describe('UserService', () => {
  it('should return user profile', async () => {
    const mockRepo = { findById: vi.fn().mockResolvedValue({ id: 1, name: 'test' }) };
    const service = new UserService(mockRepo);
    const result = await service.getProfile(1);
    expect(result.name).toBe('test');
  });
});
```

### 渲染进程测试
1. 组件测试使用框架对应工具（React: Vitest + Testing Library、Vue: Vitest + Vue Test Utils）。
2. IPC 调用在测试中 Mock（`vi.mock` window.electronAPI）。
3. E2E 测试使用 Playwright 或 Spectron（推荐 Playwright + Electron）。

### 测试覆盖率
1. 主进程：核心业务逻辑覆盖率 >= 70%。
2. 渲染进程：组件覆盖率 >= 60%。

---

## CI 流水线（MUST）

```yaml
# 每次 PR 必须通过的检查
- eslint --max-warnings 0   # TypeScript lint
- prettier --check .         # 格式化检查
- vitest run                 # 单元测试
- npm audit                  # 依赖漏洞检测
- electron-builder build     # 构建验证
```

1. 以上检查全部通过才允许合并 PR。
2. `npm audit` 发现高危漏洞（CVSS >= 7.0）阻断合并。

---

## 发布流程（MUST）

### 版本号规范
1. 遵循 SemVer（`MAJOR.MINOR.PATCH`）。
2. 版本号在 `package.json` 中维护，`electron-builder` 自动读取。
3. 推荐使用 `standard-version` 或 `changesets` 自动管理版本号和 CHANGELOG。

### 发布检查清单
1. 所有测试通过。
2. CHANGELOG 已更新。
3. 版本号已递增。
4. 签名证书已配置到 CI/CD。
5. 更新端点已部署并可访问。

### 打包格式

| 平台 | 安装包格式 | 更新包格式 |
|------|-----------|-----------|
| Windows | NSIS `.exe` / MSI | NSIS `.exe` + `latest.yml` |
| macOS | `.dmg` / `.pkg` | `.zip` + `latest-mac.yml` |
| Linux | `.AppImage` / `.deb` / `.rpm` | `.AppImage` + `latest-linux.yml` |

### 代码签名（MUST）
1. Windows：使用 Authenticode 证书签名（EV 证书可避免 SmartScreen 警告）。
2. macOS：使用 Apple Developer ID 签名 + 公证（Notarization）。
3. Linux：使用 GPG 签名（可选）。
4. 签名证书/密钥通过 CI/CD Secret 管理，禁止提交到版本控制。

### CI/CD 集成示例（GitHub Actions）

```yaml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: windows-latest
          - os: macos-latest
          - os: ubuntu-22.04

    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: pnpm install

      - name: Build and release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          CSC_LINK: ${{ secrets.CSC_LINK }}
          CSC_KEY_PASSWORD: ${{ secrets.CSC_KEY_PASSWORD }}
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_APP_SPECIFIC_PASSWORD: ${{ secrets.APPLE_APP_SPECIFIC_PASSWORD }}
        run: pnpm electron-builder --publish always
```
