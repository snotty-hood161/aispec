# rules/java-server/common/caching.md

## 文档目标
1. 定义 Java 服务端缓存使用规范，涵盖 Spring Cache 抽象、Redis 分布式缓存与本地进程内缓存。
2. 连接池配置参见 `common/performance.md`；配置管理参见 `common/configuration.md`。

---

## 缓存选型（MUST）

| 类型 | 适用场景 | 推荐方案 |
|------|---------|---------|
| **分布式缓存** | 多实例共享、数据一致性要求高 | Redis（Lettuce 客户端，Spring Boot 默认） |
| **本地缓存** | 单实例热点数据、极低延迟、允许短暂不一致 | Caffeine（推荐）、Guava Cache |

1. 项目必须明确缓存选型，禁止同类场景混用多套缓存方案。
2. 本地缓存仅用于读多写少且允许短暂不一致的场景（如配置项、枚举值、热点查询）。
3. 涉及跨实例一致性的数据必须使用分布式缓存（Redis）。
4. Redis 客户端推荐使用 Lettuce（Spring Boot 默认），如需 Redis 高级特性（分布式锁、限流）可引入 Redisson。
5. 禁止使用 Jedis（非线程安全的阻塞客户端），除非有明确的性能测试依据。

检查方式：架构评审
阻断级别：阻断合并

---

## Spring Cache 抽象（MUST）

1. 必须使用 Spring Cache 抽象（`@Cacheable`、`@CachePut`、`@CacheEvict`）管理缓存，禁止在业务代码中直接操作 `RedisTemplate`（复杂场景除外）。
2. 缓存管理器（`CacheManager`）必须在 `@Configuration` 中显式配置，指定序列化方式、TTL 等参数。
3. `@Cacheable` 必须显式指定 `cacheNames` 和 `key`，禁止依赖默认 key 生成策略。
4. 缓存 key 使用 SpEL 表达式时，必须保证 key 的唯一性（如 `#userId` 而非 `#user`）。
5. `@CacheEvict` 在写操作后执行，保证数据变更后缓存失效。

### 缓存配置示例

```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory factory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(30))
            .serializeValuesWith(
                SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()));
        return RedisCacheManager.builder(factory)
            .cacheDefaults(config)
            .build();
    }
}
```

---

## 缓存键设计（MUST）

1. 缓存键必须有统一前缀规范：`{服务名}:{业务域}:{资源标识}`，如 `order-svc:user:12345`。
2. 禁止使用用户输入直接拼接缓存键，必须做长度和字符校验，防止键注入和大键攻击。
3. 缓存键必须集中定义（如 `CacheKeyConstants` 常量类），禁止在业务代码中散写魔法字符串。
4. 键长度建议不超过 128 字节，避免 Redis 内存浪费和网络开销。

检查方式：代码审查
阻断级别：阻断合并

---

## TTL 与失效策略（MUST）

1. 所有缓存数据必须设置 TTL（过期时间），禁止永不过期的缓存（静态配置缓存除外，需注释说明）。
2. 同一业务域的缓存 TTL 应加随机偏移（如基础 TTL ± 10%），防止大量缓存同时过期（缓存雪崩）。
3. 数据变更时必须主动清除或更新对应缓存（`@CacheEvict` 或 `@CachePut`），禁止仅依赖 TTL 自然过期导致长时间脏数据。
4. 缓存失效策略选型：
   - **删除策略（Cache-Aside）**：写操作时先更新数据库，再删除缓存。适用于大多数场景。
   - **更新策略（Write-Through）**：写操作同时更新数据库和缓存。适用于读写比极高的场景。
5. 默认推荐 **Cache-Aside** 模式；选用其他模式须在设计文档中说明原因。

检查方式：代码审查
阻断级别：阻断合并

---

## 缓存穿透防护（MUST）

1. 查询不存在的数据时，禁止每次都穿透到数据库。
2. 防护方案（至少实施一种）：
   - **空值缓存**：查询结果为空时缓存空值（短 TTL，如 30s-60s），下次直接返回。
   - **布隆过滤器**：在缓存层前置布隆过滤器（Redisson 提供 `RBloomFilter`），快速判断数据是否存在。
3. 空值缓存的 TTL 必须显著短于正常数据 TTL，防止占用过多内存。

检查方式：代码审查
阻断级别：阻断合并

---

## 缓存击穿防护（MUST）

1. 热点键过期瞬间，禁止大量请求同时穿透到数据库。
2. 防护方案（至少实施一种）：
   - **分布式锁**：同一时刻只有一个请求回源查询数据库，其他请求等待结果。推荐使用 Redisson 的 `RLock`。
   - **逻辑过期**：缓存数据不设物理 TTL，在数据中嵌入逻辑过期时间；过期后由后台线程异步刷新，请求方仍返回旧数据。
3. 高热点数据（如首页推荐、排行榜）必须实施击穿防护。

检查方式：代码审查
阻断级别：阻断合并

---

## 缓存雪崩防护（MUST）

1. 禁止大量缓存使用相同 TTL，必须加随机偏移（参见 TTL 章节）。
2. Redis 不可用时，服务必须有降级策略，禁止所有请求直接打到数据库：
   - **本地缓存兜底**：短时间内从 Caffeine 本地缓存返回陈旧数据。
   - **限流保护数据库**：限制回源并发数，超出部分返回降级响应。
3. Redis 部署必须配置高可用（Sentinel 或 Cluster），避免单点故障。

检查方式：架构评审 + 故障注入测试
阻断级别：阻断合并

---

## 缓存与数据库一致性（MUST）

1. 默认采用 **Cache-Aside** 模式，操作顺序：
   - 读：先读缓存 → 未命中则读数据库 → 写入缓存 → 返回。
   - 写：先写数据库 → 成功后删除缓存。
2. 删除缓存失败时必须有补偿机制（如重试、消息队列异步删除），禁止静默忽略。
3. 对一致性要求高的场景（如金额、库存），禁止使用缓存作为数据源，必须直接读取数据库。
4. 分布式锁场景使用 Redis 锁时，必须设置锁超时且使用唯一标识防止误释放（推荐 Redisson `RLock`）。

检查方式：代码审查
阻断级别：阻断合并

---

## 缓存监控（SHOULD）

1. 缓存命中率、未命中率、回源次数纳入 Micrometer 指标监控。
2. 缓存命中率低于阈值（建议 < 80%）触发告警，排查缓存策略是否合理。
3. Redis 内存使用、连接数、慢命令纳入监控。
4. 大键（value > 10KB）和热键定期扫描，发现后优化。

检查方式：监控告警配置审查
阻断级别：告警记录
