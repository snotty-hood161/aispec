# Flutter 应用 PR 评审清单

## 使用方式
1. 复制本清单到 PR 评审评论中，逐项勾选。
2. P0 项全部通过才可合并，P1 项允许带条件通过（必须登记技术债）。

---

## P0 阻断项（全部通过才可合并）

### 代码质量
- [ ] `dart analyze --fatal-infos` 零错误通过
- [ ] `dart format --set-exit-if-changed .` 格式检查通过
- [ ] 无 `print()` 用于生产日志
- [ ] 无 `dynamic` 类型使用（或已注释说明原因）
- [ ] 无 `!` 强制解包滥用
- [ ] 无空 `catch` 块
- [ ] 公开 API 有 `///` 文档注释

### 架构
- [ ] Widget 层不直接调用 HTTP Client / Database
- [ ] 状态管理使用团队统一方案
- [ ] 外部依赖通过 DI 注入
- [ ] 数据流单向流动（Event → State → UI）

### 安全
- [ ] 无硬编码密钥 / Token / 密码
- [ ] 敏感数据使用 `flutter_secure_storage`
- [ ] 日志中无敏感信息输出
- [ ] 网络请求均使用 HTTPS

### 性能
- [ ] `build()` 方法中无耗时操作
- [ ] 长列表使用 `ListView.builder`
- [ ] 不可变 Widget 使用 `const`
- [ ] 页面销毁时取消 Stream 订阅 / Timer / Controller

### 设备适配
- [ ] 使用 `SafeArea` 处理异形屏
- [ ] 布局基于 `LayoutBuilder` / `MediaQuery`，无硬编码设备尺寸
- [ ] 平板设备提供多窗格布局（如面向商店分发）
- [ ] 深色模式正常显示

### 测试
- [ ] 核心业务逻辑有单元测试
- [ ] 新增代码不降低测试覆盖率
- [ ] CI 流水线通过（analyze + format + test + build）

---

## P1 建议项（允许带条件合并）

### 代码质量
- [ ] 代码复杂度合理（单个方法 ≤ 50 行）
- [ ] 命名清晰、符合 Dart 约定
- [ ] 无重复代码（DRY）

### 性能
- [ ] 图片使用缓存加载
- [ ] 复杂列表使用 `RepaintBoundary`
- [ ] 资源文件使用 WebP / SVG

### 设备适配
- [ ] 支持系统字体缩放（Dynamic Type）
- [ ] 横屏模式下布局正常（如支持横屏）
- [ ] 无障碍标签完整（`semanticLabel` / `Semantics`）

### 测试
- [ ] Widget Test 覆盖关键页面组件
- [ ] 边界场景有测试覆盖（空列表、网络错误、超长文本）

---

## 评审结论

- **P0 阻断项**：__ 项通过 / __ 项未通过
- **P1 建议项**：__ 项通过 / __ 项未通过
- **结论**：`Approve` / `Request Changes` / `Conditional Approve`
