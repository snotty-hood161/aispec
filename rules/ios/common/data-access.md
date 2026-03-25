# rules/ios/common/data-access.md

## 文档目标
1. 定义 iOS 应用的数据访问规范，覆盖本地持久化、网络请求、文件管理等。

---

## 本地持久化（MUST）

### SwiftData / Core Data
1. 新项目推荐使用 **SwiftData**（iOS 17+），旧项目维护使用 Core Data。
2. Model 定义使用 `@Model` 宏（SwiftData）或 `NSManagedObject` 子类（Core Data）。
3. 数据库访问必须在后台线程执行，通过 `ModelActor` 或 `NSManagedObjectContext.perform`。
4. 数据库 Schema 变更必须提供 Migration。

```swift
@Model
final class UserEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var email: String
    var updatedAt: Date

    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.updatedAt = Date()
    }
}
```

### UserDefaults
1. UserDefaults 仅用于轻量级非敏感配置（主题偏好、首次启动标记等）。
2. 禁止使用 UserDefaults 存储敏感信息或大量数据。
3. Key 使用常量定义，禁止硬编码字符串。
4. 推荐使用 `@AppStorage`（SwiftUI）简化绑定。

---

## 网络请求（MUST）

1. 使用 **URLSession** 作为网络层基础，推荐封装统一的 `NetworkClient`。
2. 网络层必须支持 `async/await`。
3. 请求/响应模型使用 `Codable` 协议序列化。
4. 超时配置必须显式设置（连接 10s、资源请求 30s）。
5. 大文件上传/下载使用 `URLSessionUploadTask` / `URLSessionDownloadTask`。

```swift
final class NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var urlRequest = try endpoint.asURLRequest()
        urlRequest.timeoutInterval = 30

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(underlying: URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.server(httpCode: httpResponse.statusCode, message: "请求失败")
        }
        return try decoder.decode(T.self, from: data)
    }
}
```

---

## Repository 模式（MUST）

1. 所有数据访问必须通过 Repository 层封装，View/ViewModel 禁止直接访问 API 或数据库。
2. Repository 负责协调本地与远程数据源，对上层屏蔽数据来源。
3. Repository 协议定义在 Domain Layer，实现在 Data Layer。
4. 缓存策略在 Repository 内部实现。

```swift
protocol UserRepository {
    func getUser(id: Int) async throws -> User
    func saveUser(_ user: User) async throws
}

final class UserRepositoryImpl: UserRepository {
    private let api: UserAPI
    private let modelContext: ModelContext
    private let mapper: UserMapper

    func getUser(id: Int) async throws -> User {
        if let cached = try? await fetchLocalUser(id: id) {
            return cached
        }
        let dto = try await api.fetchUser(id: id)
        let entity = mapper.toEntity(dto)
        modelContext.insert(entity)
        try modelContext.save()
        return mapper.toDomain(entity)
    }
}
```

---

## 文件管理（MUST）

1. 文件操作使用 `FileManager`，存储路径使用系统推荐目录。
2. 用户数据存储在 `documentsDirectory`，缓存存储在 `cachesDirectory`，临时文件存储在 `temporaryDirectory`。
3. 文件路径禁止硬编码，必须通过 `FileManager.default.urls(for:in:)` 获取。
4. 大文件读写在后台线程执行。

---

## 禁止事项

1. 禁止在主线程执行数据库查询或网络请求。
2. 禁止在 Repository 中直接操作 UI。
3. 禁止使用 UserDefaults 存储大量数据（> 100KB）。
4. 禁止在 Codable Model 中使用 `Any` 类型。
