# E2E 测试规范

## Skill 协作
1. 测试相关任务优先使用 `$qa-test-strategist`，自动加载本规则。
2. 各域 coding-guide 中的 testing-and-release.md / testing.md 为域内测试细则，本文件为跨域 E2E 测试基线。
3. 跨域业务任务使用 `$task-router` 自动路由。

## 测试策略总览

### 测试金字塔

```
        ╱  E2E  ╲           — 少量，覆盖核心用户流程
       ╱ 集成测试 ╲          — 适量，覆盖服务间交互
      ╱  单元测试  ╲         — 大量，覆盖业务逻辑细节
     ╱──────────────╲

推荐比例：单元 70% / 集成 20% / E2E 10%
```

### E2E 测试定位
1. E2E 测试验证核心用户流程的端到端正确性。
2. 不追求覆盖所有场景，聚焦于高价值的关键路径。
3. E2E 测试是 QA Agent 的主要产出，单元/集成测试由各域 Agent 负责。

## E2E 测试框架选型（SHOULD）

| 平台 | 推荐框架 | 备选 |
|------|---------|------|
| Web 前端 | Playwright | Cypress |
| 移动端（iOS/Android） | Appium | Detox（React Native） |
| Flutter | integration_test | patrol |
| API | Playwright API Testing / REST Client | Postman/Newman |
| 桌面（Tauri/.NET） | Playwright（WebView）| WinAppDriver |

## 测试项目结构（MUST）

```
e2e/
├── playwright.config.ts          ← 配置文件
├── fixtures/                     ← 测试 fixture
│   ├── auth.fixture.ts           ← 认证 fixture
│   └── data.fixture.ts           ← 测试数据 fixture
├── pages/                        ← Page Object Model
│   ├── login.page.ts
│   ├── dashboard.page.ts
│   └── order.page.ts
├── tests/                        ← 测试用例
│   ├── auth/
│   │   ├── login.spec.ts
│   │   └── register.spec.ts
│   ├── order/
│   │   ├── create-order.spec.ts
│   │   └── order-list.spec.ts
│   └── smoke/
│       └── smoke.spec.ts         ← 冒烟测试集
├── utils/                        ← 工具函数
│   ├── api-helper.ts
│   └── test-data.ts
└── reports/                      ← 测试报告输出目录
```

## Page Object Model（MUST）

### POM 设计原则
1. 每个页面/组件对应一个 Page Object 类。
2. Page Object 封装页面的元素定位和操作方法。
3. 测试用例中不直接操作元素选择器，只调用 Page Object 方法。
4. Page Object 方法返回值用于断言，不在 Page Object 内做断言。

### 命名规范
1. Page Object 文件：`{page-name}.page.ts`。
2. 测试文件：`{feature-name}.spec.ts`。
3. Fixture 文件：`{scope}.fixture.ts`。

## 测试用例编写规范（MUST）

### 用例结构
1. 使用 `describe` 按功能模块分组。
2. 使用 `test` / `it` 描述具体场景。
3. 用例标题使用"动词 + 预期结果"格式：`should display error when password is wrong`。
4. 每个用例独立，不依赖其他用例的执行顺序。

### 测试数据
1. 测试数据通过 fixture 或 API 在测试前创建。
2. 测试完成后清理测试数据（使用 `afterEach` / `afterAll`）。
3. 禁止使用硬编码的生产数据。
4. 测试账号使用统一前缀：`test_e2e_`。

### 等待策略
1. 禁止使用固定等待（`sleep` / `waitForTimeout`）。
2. 使用条件等待：`waitForSelector`、`waitForResponse`、`waitForURL`。
3. 设置合理的超时时间（默认 30s，可按场景调整）。

## 核心测试场景（MUST）

每个产品至少覆盖以下场景的 E2E 测试：

| 场景类别 | 必测场景 | 优先级 |
|---------|---------|--------|
| 认证 | 注册、登录、登出、密码重置 | P0 |
| 核心业务 | 创建/查看/编辑/删除核心业务对象 | P0 |
| 支付（如有） | 支付流程、退款流程 | P0 |
| 权限 | 不同角色的页面可见性和操作权限 | P1 |
| 搜索/筛选 | 列表搜索、筛选、分页 | P1 |
| 错误处理 | 表单校验、网络错误、权限不足 | P1 |
| 跨端一致性 | 同一操作在不同客户端的一致性 | P2 |

## CI 集成（MUST）

### E2E 测试在 CI 中的位置

```
代码提交
  → lint + type-check
  → 单元测试
  → 构建
  → 集成测试
  → 部署到 test 环境
  → E2E 冒烟测试（smoke）     ← 每次 PR 必跑
  → 部署到 staging
  → E2E 全量测试（full）       ← 发布前必跑
```

### CI 配置要点
1. E2E 测试使用独立的测试环境，与开发环境隔离。
2. 测试失败时自动生成截图和视频记录。
3. 测试报告自动上传（HTML report / JUnit XML）。
4. 冒烟测试超时 ≤ 10 分钟，全量测试超时 ≤ 30 分钟。

## 测试报告格式（MUST）

```
## E2E 测试报告

### 执行概览
- 环境：{test / staging}
- 日期：{yyyy-MM-dd HH:mm}
- 总用例数：{n}
- 通过：{n}（{%}）
- 失败：{n}（{%}）
- 跳过：{n}（{%}）
- 执行时长：{mm:ss}

### 失败用例详情
| 用例 | 模块 | 错误信息 | 截图 |
|------|------|---------|------|
| {用例名} | {模块名} | {错误摘要} | {截图链接} |

### 覆盖率
| 功能模块 | 用例数 | 通过率 | 未覆盖场景 |
|---------|--------|--------|-----------|
| {模块名} | {n} | {%} | {列出未覆盖的关键场景} |

### 结论
- 冒烟测试：{通过 / 不通过}
- 可发布性：{可以发布 / 修复后发布 / 不建议发布}
```
