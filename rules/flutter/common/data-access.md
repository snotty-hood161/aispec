# rules/flutter/common/data-access.md

## 文档目标
1. 定义 Flutter 应用的数据访问规范，覆盖网络请求、本地存储、文件管理。

---

## 网络请求（MUST）

1. 必须使用统一的 HTTP 客户端封装，推荐 **dio**。
2. 禁止在业务代码中直接使用 `http` 包或 `HttpClient`。
3. HTTP 客户端必须统一配置：
   - `baseUrl`：按环境切换。
   - `connectTimeout` / `receiveTimeout`：推荐 15 秒 / 30 秒。
   - `interceptors`：Token 注入、日志、错误映射、重试。
4. Token 刷新必须通过 Interceptor 自动处理，支持并发请求排队等待刷新完成。
5. 所有请求 / 响应使用类型化 DTO（Data Transfer Object），禁止直接操作 `Map<String, dynamic>`。

```dart
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.interceptors.addAll([
      AuthInterceptor(_tokenStorage),
      LogInterceptor(requestBody: true, responseBody: true),
      ErrorMappingInterceptor(),
    ]);
  }

  Future<T> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return fromJson(response.data['data']);
  }
}
```

---

## 本地数据库（MUST — 有离线需求时）

1. 推荐使用 **Drift**（类型安全、编译时检查）或 **Isar**（NoSQL、高性能）。
2. 数据库 Schema 变更必须通过版本化迁移实现，禁止直接修改旧版 Schema。
3. 数据库操作必须在后台 Isolate 中执行，禁止在主 Isolate 中执行复杂查询。
4. 查询必须参数化，禁止字符串拼接 SQL（防注入）。
5. 大量数据写入使用批量操作（batch / transaction），禁止循环单条插入。

---

## 键值存储（MUST）

1. 非敏感配置项使用 `shared_preferences`。
2. 敏感数据（Token / 密钥）必须使用 `flutter_secure_storage`（参见 security.md）。
3. 键名使用常量定义，集中管理：

```dart
abstract class StorageKeys {
  static const themeMode = 'app_theme_mode';
  static const locale = 'app_locale';
  static const onboardingCompleted = 'onboarding_completed';
}
```

---

## 文件管理（SHOULD）

1. 临时文件存储在 `getTemporaryDirectory()`，应用数据存储在 `getApplicationDocumentsDirectory()`。
2. 图片缓存使用 `cached_network_image` 或 `CacheManager`，设置缓存大小上限。
3. 文件下载使用流式写入，禁止全量加载到内存。
4. 上传大文件支持分片上传和断点续传。

---

## 数据序列化（MUST）

1. JSON 序列化必须使用代码生成方案（**json_serializable** + **json_annotation**），禁止手写 `fromJson` / `toJson`。
2. 所有网络 DTO 类必须标注 `@JsonSerializable()`。
3. 枚举值序列化使用 `@JsonEnum(valueField: 'value')`，禁止依赖 index。
4. 日期字段统一使用 ISO 8601 格式，配合 `DateTime.parse` / `.toIso8601String()`。

```dart
@JsonSerializable()
class OrderDto {
  final String id;
  final String title;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final OrderStatus status;

  const OrderDto({required this.id, required this.title, required this.createdAt, required this.status});

  factory OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);

  Order toEntity() => Order(id: id, title: title, createdAt: createdAt, status: status);
}
```

---

## 禁止事项

1. 禁止在 Widget 层直接调用 HTTP Client / Database。
2. 禁止使用 `Map<String, dynamic>` 作为业务数据结构在层间传递。
3. 禁止在主 Isolate 中执行 JSON 大文件解析（使用 `compute()` 或 Isolate）。
4. 禁止在 `SharedPreferences` 中存储大量数据（> 1MB），应使用数据库。
