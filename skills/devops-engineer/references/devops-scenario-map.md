# DevOps 场景 → 方案模块映射表

用此表将 DevOps 任务场景映射到需要设计的方案模块和规则文件。

## 使用方式
1. 从任务描述中提取 DevOps 需求。
2. 按下表确定需要设计的方案模块。
3. 加载对应的规范文件作为设计约束。

---

## 场景路由表

| 编号 | DevOps 场景 | 方案模块 | 加载规则 |
|------|------------|---------|---------|
| A | 新项目 CI/CD 搭建 | CI 流水线 + CD 流水线 | `rules/release/release-management.md` |
| B | 容器化部署方案 | Dockerfile + 编排（K8s/Compose） | — |
| C | 多环境管理 | 环境规划 + 配置管理 + 密钥管理 | `rules/environment/environment-management.md` |
| D | 监控告警方案 | 指标 + 日志 + 链路追踪 + 告警 | `rules/observability/observability.md` |
| E | 发布策略设计 | 部署策略 + 回滚方案 | `rules/release/release-management.md` |
| F | 安全基础设施 | WAF + TLS + 密钥管理 + 安全扫描 | `rules/security/security-baseline.md` |
| G | 数据库运维 | 备份恢复 + 迁移部署 | `rules/database/data-migration.md` |
| H | CDN / 静态资源 | CDN 配置 + 缓存策略 | — |
| I | 灰度/功能开关 | 功能开关管理 + 灰度策略 | `rules/environment/environment-management.md` §功能开关 |
| J | SLO 定义 | SLI/SLO/错误预算 | `rules/observability/observability.md` §SLO |

## 按技术栈的 CI/CD 工具推荐

| 技术栈 | 构建工具 | 测试命令 | 制品格式 | Lint 工具 |
|--------|---------|---------|---------|---------|
| Go | `go build` | `go test ./...` | 二进制 / Docker 镜像 | golangci-lint |
| .NET | `dotnet build` | `dotnet test` | Docker 镜像 / 发布包 | dotnet format |
| 前端（Vue/React） | `pnpm build` | `pnpm test` | 静态文件 / Docker 镜像 | ESLint + Prettier |
| Flutter | `flutter build` | `flutter test` | APK/IPA/Web | dart analyze |
| iOS | `xcodebuild` | `xcodebuild test` | IPA | SwiftLint |
| Android | `gradlew assembleRelease` | `gradlew test` | APK/AAB | ktlint / detekt |
| Tauri | `cargo build` + `pnpm build` | `cargo test` + `pnpm test` | 安装包 | clippy + ESLint |
| .NET 桌面 | `dotnet publish` | `dotnet test` | MSIX / 安装包 | dotnet format |

## CI 流水线阶段模板

```
阶段 1：代码质量
  - lint / format check / type-check

阶段 2：单元测试
  - 运行单元测试 + 覆盖率报告

阶段 3：构建
  - 编译 / 打包 / Docker 镜像构建

阶段 4：安全扫描
  - 依赖漏洞扫描 + SAST + 密钥扫描

阶段 5：集成测试
  - 启动依赖服务 + 运行集成测试

阶段 6：制品发布
  - 推送到制品库（Docker Registry / npm / NuGet）

阶段 7：部署（按环境）
  - test → staging → prod（灰度 → 全量）
```
