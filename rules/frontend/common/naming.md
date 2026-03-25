# rules/frontend/common/naming.md

## 文档目标
1. 统一命名规范，提升可读性与跨应用协作效率。
2. 降低重构与跨端迁移时的理解成本。

## 通用命名规则（MUST）
1. 变量、函数使用 `camelCase`。
2. 类型、接口、组件使用 `PascalCase`。
3. 常量使用 `UPPER_SNAKE_CASE`。
4. 目录与普通文件使用 `kebab-case`。
5. 命名必须语义化，禁止 `temp`、`data2`、`newList` 这类弱语义命名。
检查方式：人工审查 + 静态扫描  
阻断级别：阻断合并

## Vue 与组合函数命名（MUST）
1. 组合函数统一 `useXxx` 前缀。
2. 事件处理函数统一 `onXxx` 前缀。
3. 组件目录模式下，入口文件统一 `index.vue` 或 `index.ts`。
检查方式：人工审查  
阻断级别：告警记录

## 资源命名（MUST）
1. 图标与图片文件名使用 `kebab-case`。
2. 禁止中文、空格、无语义缩写命名。
3. 小程序图标仅允许位图资源（`png/jpg/jpeg/webp`），禁止 `svg`。
检查方式：静态扫描 + 人工审查  
阻断级别：阻断合并

## Token 命名规则（MUST）
1. Token 使用语义化命名，不使用业务名或页面名。
2. 命名采用小写 `kebab-case`。
3. 建议前缀分层：`--color-*`、`--space-*`、`--radius-*`、`--text-*`。
4. 新增样式值优先复用已有 token，缺失时先新增 token 再业务使用。
检查方式：人工审查  
阻断级别：告警记录

## tab-host 命名约束（适用时 MUST）
1. 采用 Tab 宿主页模式时，宿主页目录统一使用 `tab-host` 命名。
2. Tab 子视图命名使用业务语义名（如 `profile-tab`、`order-tab`），避免 `tab1/tab2`。
3. `tab-host` 仅作为页面容器，不承载业务细节逻辑。
检查方式：人工审查  
阻断级别：告警记录

## 配套模板
1. 文件命名检查 + 自动重命名脚本 + Token 冲突检查脚本 → `rules/templates/frontend/naming-toolkit.md`
