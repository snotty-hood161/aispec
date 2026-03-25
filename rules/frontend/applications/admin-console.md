# rules/frontend/applications/admin-console.md

## 文档目标
1. 定义后台管理项目的结构、选型锁定与业务复杂度约束。

## 技术栈锁定（MUST，V1）
1. 框架：`Vue3 + TypeScript + Vite`
2. UI 库：`Element Plus`
3. CSS：`Tailwind CSS`（必须执行）
4. 状态管理：`Pinia`
5. 状态持久化：`pinia-plugin-persistedstate`
6. 路由：`Vue Router`
7. 请求层：`Axios`（统一拦截器与错误码映射）
8. 富文本编辑器：`Tiptap`
9. 图表：`ECharts`
10. `MUST`：同类库禁止并存，不得新增第二套 UI 库或状态管理库。

## 项目结构引用（MUST）
1. 后台管理结构规则以 `rules/frontend/project-structure/admin-console.md` 为准。
2. 通用结构边界仍需遵守 `rules/frontend/common/project-structure.md`。

## 业务规则
1. `MUST`：权限点在 `permission/` 统一定义，页面禁止写散落权限字符串。
2. `MUST`：列表查询参数统一模型（分页、排序、筛选），禁止页面自定义字段名。
3. `MUST`：高风险操作必须二次确认并记录审计信息。
4. `SHOULD`：复杂表单与表格抽象为业务组件，禁止复制粘贴页面实现。

## 性能与稳定性
1. `MUST`：大列表必须支持分页或虚拟滚动，禁止无边界全量渲染。
2. `MUST`：接口异常必须可见化（错误提示 + 重试入口）。
3. `MUST`：`Axios` 请求必须统一超时、鉴权、重试与错误处理策略。
4. `SHOULD`：慢查询、失败率、导入导出耗时纳入监控。

## 配套模板
1. Tailwind CSS + Element Plus 组合约束 → `rules/templates/frontend/tailwind-element-plus.md`
2. 权限点命名规范 → `rules/templates/frontend/permission-naming.md`
3. ProTable 表格组件标准模板 → `rules/templates/frontend/pro-table.md`
4. Tiptap 富文本编辑器标准封装 → `rules/templates/frontend/tiptap-editor.md`
