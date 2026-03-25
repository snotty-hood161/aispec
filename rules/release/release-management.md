# 版本发布管理规范

## Skill 协作
1. DevOps 任务优先使用 `$devops-engineer`，自动加载本规则。
2. 跨域业务任务使用 `$task-router` 自动路由。

## 语义化版本（SemVer）（MUST）

### 版本号格式
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

示例：
1.0.0          — 正式发布
1.1.0          — 新功能（向后兼容）
1.1.1          — Bug 修复
2.0.0-beta.1   — 预发布版本
2.0.0-rc.1     — 发布候选
```

### 版本号递增规则

| 变更类型 | 递增位 | 示例 | 说明 |
|---------|--------|------|------|
| 不兼容的 API 变更 | MAJOR | 1.x.x → 2.0.0 | 重置 MINOR 和 PATCH |
| 新增功能（向后兼容） | MINOR | 1.1.x → 1.2.0 | 重置 PATCH |
| Bug 修复 | PATCH | 1.1.1 → 1.1.2 | — |
| 预发布 | PRERELEASE | 2.0.0-beta.1 | 不稳定版本 |

### 初始开发阶段
1. 首次发布使用 `1.0.0`（不使用 `0.x.x`）。
2. `0.x.x` 仅用于公开库的初始不稳定阶段。

## Git Tag 策略（MUST）

### Tag 命名
1. Tag 格式：`v{MAJOR}.{MINOR}.{PATCH}`，如 `v1.2.3`。
2. 预发布 Tag：`v{VERSION}-{PRERELEASE}`，如 `v2.0.0-beta.1`。
3. 每个发布版本必须创建 Git Tag，Tag 指向发布对应的 commit。

### 分支策略

| 分支 | 用途 | 保护策略 |
|------|------|---------|
| `main` | 生产代码，始终可部署 | 禁止直接 push，只通过 PR 合入 |
| `develop` | 开发集成分支 | 禁止直接 push |
| `feature/*` | 功能开发分支 | 开发者自行管理 |
| `hotfix/*` | 紧急修复分支 | 从 main 切出，合入 main + develop |
| `release/*` | 发布准备分支 | 从 develop 切出，合入 main + develop |

## Changelog 规范（MUST）

### Changelog 文件
文件名：`CHANGELOG.md`，放置在项目根目录。

### 格式规范
遵循 [Keep a Changelog](https://keepachangelog.com/) 格式：

```markdown
# Changelog

## [Unreleased]

## [1.2.0] - 2026-03-24
### Added
- 新增订单导出功能 (#123)
- 新增用户批量导入 API (#124)

### Changed
- 优化订单列表查询性能，响应时间降低 40% (#125)

### Fixed
- 修复分页查询在特定条件下返回空数据的问题 (#126)

### Deprecated
- 废弃 `GET /api/v1/orders/export`，请使用 `POST /api/v1/orders/export`

### Security
- 修复 XSS 漏洞 (CVE-2026-xxxx) (#127)

## [1.1.0] - 2026-03-01
### Added
- ...
```

### 变更分类

| 分类 | 含义 | 示例 |
|------|------|------|
| Added | 新增功能 | 新增 API、新增页面 |
| Changed | 功能变更 | 性能优化、行为调整 |
| Deprecated | 即将移除的功能 | 废弃的 API |
| Removed | 已移除的功能 | 已删除的端点 |
| Fixed | Bug 修复 | 数据异常修复 |
| Security | 安全相关修复 | 漏洞修复 |

### Changelog 编写规则
1. 每条记录使用完整的中文句子，描述"做了什么"而非"怎么做的"。
2. 关联 Issue / PR 编号（如 `#123`）。
3. 按影响范围从大到小排序。
4. 安全修复标注 CVE 编号（如有）。

## Release Notes 模板（MUST）

每次正式发布必须编写 Release Notes：

```markdown
# v{VERSION} Release Notes

## 发布信息
- 版本号：v{VERSION}
- 发布日期：{yyyy-MM-dd}
- 发布类型：{正式发布 / 热修复 / 预发布}

## 升级影响
- 是否包含不兼容变更：{是 / 否}
- 是否需要数据库迁移：{是 / 否}
- 是否需要配置变更：{是 / 否}

## 主要变更
### 新功能
- {功能描述} (#PR编号)

### 改进
- {改进描述} (#PR编号)

### 修复
- {修复描述} (#PR编号)

## 升级步骤
1. {步骤1}
2. {步骤2}

## 已知问题
- {已知问题描述}（计划在 v{NEXT_VERSION} 修复）
```

## 发布流程（MUST）

### 正常发布流程

```
1. 代码冻结
   └── develop 分支切出 release/v{VERSION} 分支
2. 版本号更新
   └── 更新 version 文件 / package.json / .csproj 等
3. Changelog 更新
   └── [Unreleased] 内容移至新版本号下
4. 发布准备测试
   └── staging 环境部署并验证
5. 合入 main
   └── release 分支 PR → main
6. 创建 Tag
   └── git tag v{VERSION}
7. 发布构建
   └── CI/CD 自动构建并发布
8. 编写 Release Notes
   └── GitHub Release / 内部文档
9. 合回 develop
   └── main 合回 develop（确保 develop 包含版本号变更）
```

### 热修复流程

```
1. 从 main 切出 hotfix/v{VERSION} 分支
2. 修复问题
3. 版本号递增 PATCH
4. 合入 main + 创建 Tag
5. 合回 develop
```

## 发布检查清单（MUST）

```
## 发布检查清单

### 代码质量
- [ ] 所有 CI 检查通过
- [ ] Code Review 完成
- [ ] 无 P0 阻断级 lint 错误

### 测试
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] staging 环境验证通过
- [ ] 回归测试通过

### 文档
- [ ] Changelog 已更新
- [ ] Release Notes 已编写
- [ ] API 文档已同步（如有变更）

### 数据库
- [ ] 迁移脚本已验证（staging 执行成功）
- [ ] 回滚脚本已准备

### 部署
- [ ] 配置变更已同步到各环境
- [ ] 发布窗口已预约
- [ ] 回滚方案已准备
- [ ] 监控告警已确认正常
```
