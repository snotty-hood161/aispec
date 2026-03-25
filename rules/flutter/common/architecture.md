# rules/flutter/common/architecture.md

## 文档目标
1. 定义 Flutter 应用的架构分层与状态管理规范，确保可维护性和可测试性。

---

## 分层架构（MUST）

1. 必须采用清晰的分层架构，推荐三层结构：

```
┌─────────────────────────┐
│   Presentation Layer    │  Widget / Page / State Management
├─────────────────────────┤
│     Domain Layer        │  Entity / UseCase / Repository Interface
├─────────────────────────┤
│      Data Layer         │  Repository Impl / DataSource / DTO
└─────────────────────────┘
```

2. 依赖方向单向流动：`Presentation → Domain → Data`。
3. Domain 层不依赖 Flutter 框架（纯 Dart），便于单元测试。
4. 外部依赖（网络、数据库、平台服务）通过接口（abstract class）隔离在 Data 层。

---

## 状态管理（MUST）

1. 必须使用团队统一的状态管理方案，禁止同项目混用多种方案。
2. 推荐方案（任选其一，项目初始化时确定）：
   - **BLoC / Cubit**（`flutter_bloc`）：适合大型项目、事件驱动场景。
   - **Riverpod**：适合声明式依赖管理、全局与局部状态混合场景。
   - **Provider**：适合中小项目、简单状态管理。
3. 禁止使用 `setState` 管理跨 Widget 共享状态（仅限 Widget 内部局部 UI 状态）。
4. 状态类必须是不可变的（immutable），使用 `freezed` 或手动实现 `copyWith`。
5. 状态变更必须可追踪：支持日志 / DevTools 时间旅行调试。

```dart
// BLoC 状态定义示例（使用 freezed）
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated(String? message) = _Unauthenticated;
}
```

---

## 依赖注入（MUST）

1. 必须使用依赖注入管理组件依赖关系，禁止在业务代码中直接实例化基础设施组件。
2. 推荐方案：
   - **get_it** + **injectable**：Service Locator 模式，适合 BLoC 项目。
   - **Riverpod Provider**：与 Riverpod 状态管理一体化。
3. 所有外部依赖（HTTP Client / Database / SharedPreferences）通过 DI 容器注册。
4. 测试时通过 DI 容器替换为 Mock 实现。

---

## 单向数据流（MUST）

1. UI 数据流必须为单向：`Event/Action → State Management → State → UI`。
2. Widget 只负责：
   - 派发事件（用户交互 → Event）。
   - 渲染状态（State → Widget 树）。
3. 禁止在 Widget 中直接调用 Repository / DataSource。
4. 禁止 Widget 之间通过回调链传递复杂状态（超过 2 层应使用状态管理）。

---

## Repository 模式（MUST）

1. 数据访问必须通过 Repository 接口封装，Domain 层定义接口，Data 层实现。
2. Repository 职责：
   - 聚合多个 DataSource（Remote + Local）。
   - 实现缓存策略（Cache First / Network First / Stale While Revalidate）。
   - 数据转换（DTO → Entity）。
3. 禁止在 Repository 中包含 UI 逻辑或状态管理逻辑。

```dart
// Domain 层定义接口
abstract class OrderRepository {
  Future<List<Order>> getOrders({required int page, int pageSize = 20});
  Future<Order> getOrderDetail(String orderId);
  Future<void> cancelOrder(String orderId);
}

// Data 层实现
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  final OrderLocalDataSource _local;

  OrderRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Order>> getOrders({required int page, int pageSize = 20}) async {
    try {
      final dtos = await _remote.fetchOrders(page: page, pageSize: pageSize);
      final orders = dtos.map((dto) => dto.toEntity()).toList();
      await _local.cacheOrders(orders);
      return orders;
    } catch (e) {
      return _local.getCachedOrders();
    }
  }
}
```

---

## 模块化（SHOULD）

1. 大型项目推荐按功能模块拆分为独立 Dart Package。
2. 公共模块（网络、存储、主题）提取为内部 Package，通过 `path` 依赖引用。
3. Monorepo 使用 Melos 管理多 Package 构建与版本。
4. 模块间通过公开接口（`export`）暴露 API，禁止直接引用其他模块的内部文件。
