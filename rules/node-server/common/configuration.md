# rules/node-server/common/configuration.md

## 配置文件组织

### MUST
1. 配置必须按环境分离，禁止所有环境共用同一份配置。推荐文件组织：
   ```text
   configs/
   ├── .env.example          # 配置模板（纳入版本控制）
   ├── .env.development      # 开发环境
   ├── .env.staging          # 预发布环境
   └── .env.production       # 生产环境（仅在部署环境存在，不纳入版本控制）
   ```
2. `.env` 文件（含真实凭据的）禁止纳入版本控制，必须在 `.gitignore` 中排除。
3. 项目必须提供 `.env.example` 模板文件，包含所有必需配置项的键名和说明，纳入版本控制。
4. 配置项命名使用 `UPPER_SNAKE_CASE`，按功能域分组加前缀（如 `DB_HOST`、`REDIS_URL`、`JWT_SECRET`）。

### SHOULD
1. 推荐将复杂配置（如微服务端口映射、CORS 白名单列表）使用 YAML 文件管理。
2. 推荐使用 `dotenv-expand` 支持配置项引用（如 `DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}`）。

检查方式：代码审查 + CI 检查
阻断级别：阻断合并

---

## NestJS ConfigModule（MUST）

1. NestJS 项目必须使用 `@nestjs/config` 的 `ConfigModule.forRoot()` 加载配置，注册为全局模块。
2. 必须定义类型安全的配置 Schema（推荐使用 `joi` 或 `zod` 校验），启动时校验所有必需配置项，缺失则快速失败。
3. 配置必须通过 `ConfigService.get<T>()` 获取，禁止在业务代码中直接读取 `process.env`。
4. 敏感配置（数据库密码、JWT 密钥、API Key）必须通过环境变量注入，禁止硬编码在代码或配置文件中。
5. 配置必须按领域拆分为独立的配置命名空间（namespace），如 `database`、`redis`、`jwt`、`app`：
   ```typescript
   // config/database.config.ts
   export default registerAs('database', () => ({
     host: process.env.DB_HOST,
     port: parseInt(process.env.DB_PORT, 10),
     // ...
   }));
   ```

### SHOULD
1. 推荐使用 `@nestjs/config` 的 `load` 选项加载多个配置命名空间。
2. 推荐为每个配置命名空间定义 TypeScript 接口，通过泛型获取强类型支持。

检查方式：启动校验 + 代码审查
阻断级别：阻断启动

---

## Express/Fastify 配置管理（MUST）

1. 必须使用 `dotenv` 加载环境变量，在应用启动最早阶段调用 `config()`。
2. 必须封装统一的配置访问层（如 `config.ts`），禁止在业务代码中散布 `process.env.XXX`。
3. 配置访问层必须包含类型定义和默认值，缺失必需配置时快速失败并输出明确错误信息。
4. 配置对象导出后必须 `Object.freeze()`，禁止运行时修改配置值。

---

## 类型安全配置（MUST）

1. 所有配置项必须有对应的 TypeScript 类型定义，禁止使用 `string` 或 `any` 类型。
2. 数值型配置必须在加载时转换类型并校验范围（如端口号必须在 1-65535 之间）。
3. 枚举型配置必须校验为合法值（如 `NODE_ENV` 只允许 `development`、`staging`、`production`）。
4. 连接串类配置推荐拆分为独立字段（host、port、user、password、database），再组合为连接串。

### SHOULD
1. 推荐使用 `zod` 定义配置 Schema，同时获得校验和类型推导：
   ```typescript
   const envSchema = z.object({
     NODE_ENV: z.enum(['development', 'staging', 'production']),
     PORT: z.coerce.number().int().min(1).max(65535).default(3000),
     DB_HOST: z.string().min(1),
     // ...
   });
   ```
2. 推荐在 CI 中使用 `.env.example` 校验所有必需配置项已声明。

检查方式：启动校验 + TypeScript 编译
阻断级别：阻断启动

---

## 密钥与凭据管理（MUST）

1. 生产环境密钥必须通过密钥管理服务（如 Vault、AWS Secrets Manager、K8s Secrets）注入，禁止明文存储在配置文件中。
2. 日志和错误信息中禁止打印完整的密钥、连接串、令牌；如需记录，必须脱敏（如仅显示前 4 位 + `***`）。
3. JWT 密钥必须定期轮换，应用必须支持同时验证新旧密钥的过渡期。
4. API Key、Webhook Secret 等第三方凭据必须独立存储，禁止与业务配置混放。

### SHOULD
1. 推荐使用 `@nestjs/config` 的 `cache` 选项缓存配置读取结果，避免频繁解析。
2. 推荐在应用启动时输出配置加载摘要日志（仅记录非敏感项和脱敏后的敏感项）。

检查方式：安全审查 + 密钥轮换演练
阻断级别：阻断部署
