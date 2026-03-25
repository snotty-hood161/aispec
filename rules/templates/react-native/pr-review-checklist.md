# React Native 应用 PR 评审清单

## 使用方式
1. 复制本清单到 PR 评审评论中，逐项勾选。
2. P0 项全部通过才可合并，P1 项允许带条件通过（必须登记技术债）。

---

## P0 阻断项（全部通过才可合并）

### 代码质量
- [ ] `eslint --max-warnings 0` 零错误通过
- [ ] `prettier --check .` 格式检查通过
- [ ] `tsc --noEmit` TypeScript 类型检查通过
- [ ] 无 `console.log()` / `console.warn()` 用于生产日志
- [ ] 无 `any` 类型使用（或已注释说明原因）
- [ ] 无空 `catch` 块
- [ ] 导出 API 有 JSDoc/TSDoc 文档注释

### 架构
- [ ] UI 组件不直接调用 HTTP Client / Database
- [ ] 状态管理使用团队统一方案（Zustand/Redux/React Query）
- [ ] 外部依赖通过 Context/Provider 注入
- [ ] 数据流单向流动（Action → State → UI）
- [ ] 原生模块桥接有完整 TypeScript 类型定义

### 安全
- [ ] 无硬编码密钥 / Token / 密码
- [ ] 敏感数据使用安全存储（react-native-keychain / expo-secure-store）
- [ ] 日志中无敏感信息输出
- [ ] 网络请求均使用 HTTPS

### 性能
- [ ] 渲染路径中无耗时操作（网络请求/复杂计算）
- [ ] 长列表使用 `FlatList` / `FlashList`
- [ ] 适当使用 `React.memo` / `useMemo` / `useCallback`
- [ ] 页面卸载时清理副作用（订阅/Timer/Listener）
- [ ] 桥通信避免高频循环调用

### 导航与设备适配
- [ ] 使用 `SafeAreaView` / `react-native-safe-area-context` 处理异形屏
- [ ] 布局基于 `useWindowDimensions` / `Dimensions`，无硬编码设备尺寸
- [ ] React Navigation 路由声明集中管理
- [ ] 深色模式正常显示

### 测试
- [ ] 核心业务逻辑有单元测试
- [ ] 新增代码不降低测试覆盖率
- [ ] CI 流水线通过（lint + typecheck + test + build）

---

## P1 建议项（允许带条件合并）

### 代码质量
- [ ] 代码复杂度合理（单个方法 ≤ 50 行）
- [ ] 命名清晰、符合 TypeScript/React 约定
- [ ] 无重复代码（DRY）

### 性能
- [ ] 图片使用缓存加载（react-native-fast-image / expo-image）
- [ ] 复杂动画使用 `react-native-reanimated`
- [ ] JS Bundle 体积在合理范围内

### 设备适配
- [ ] 支持系统字体缩放（Dynamic Type）
- [ ] 横屏模式下布局正常（如支持横屏）
- [ ] 无障碍标签完整（`accessibilityLabel` / `accessibilityRole`）
- [ ] 平板设备提供适当布局适配

### 测试与发布
- [ ] 组件测试覆盖关键页面（React Native Testing Library）
- [ ] 边界场景有测试覆盖（空列表、网络错误、超长文本）
- [ ] OTA 更新配置正确（CodePush / EAS Update），灰度策略明确

---

## 评审结论

- **P0 阻断项**：__ 项通过 / __ 项未通过
- **P1 建议项**：__ 项通过 / __ 项未通过
- **结论**：`Approve` / `Request Changes` / `Conditional Approve`
