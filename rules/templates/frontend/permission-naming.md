# 权限点命名规范模板

## 文档目标
1. 定义后台管理项目权限标识的统一命名规则，确保权限点可读、可审计、可检索。
2. 业务规则约束参见 `applications/admin-console.md` 第 4 章。

---

## 命名格式（MUST）

```
{模块}:{资源}:{操作}
```

### 三段式说明

| 段 | 含义 | 命名风格 | 示例 |
|----|------|----------|------|
| **模块** | 业务模块名称 | `kebab-case` | `order`、`user-center`、`content` |
| **资源** | 模块内的具体资源 | `kebab-case` | `list`、`detail`、`export`、`config` |
| **操作** | 对资源执行的动作 | 固定动词集合 | `view`、`create`、`edit`、`delete` |

### 标准操作动词集合（MUST）

| 动词 | 含义 | 说明 |
|------|------|------|
| `view` | 查看 | 页面/数据的只读访问 |
| `create` | 新建 | 创建新记录 |
| `edit` | 编辑 | 修改已有记录 |
| `delete` | 删除 | 删除记录（含软删除） |
| `export` | 导出 | 数据导出（Excel/CSV 等） |
| `import` | 导入 | 数据导入 |
| `audit` | 审核 | 审批/审核操作 |
| `config` | 配置 | 系统或业务配置修改 |

1. 禁止自定义操作动词，如需扩展必须在权限配置文件头部声明并附注释。
2. 禁止在业务代码中使用魔法字符串引用权限点，必须通过常量引用。

---

## 文件组织（MUST）

```
src/
  permission/
    index.ts          # 统一导出
    modules/
      order.ts        # 订单模块权限
      user-center.ts  # 用户中心权限
      content.ts      # 内容管理权限
```

### 单模块文件示例

```ts
// src/permission/modules/order.ts

/** 订单模块权限点 */
export const ORDER_PERMISSIONS = {
  /** 查看订单列表 */
  LIST_VIEW: 'order:list:view',
  /** 查看订单详情 */
  DETAIL_VIEW: 'order:detail:view',
  /** 创建订单 */
  CREATE: 'order:order:create',
  /** 编辑订单 */
  EDIT: 'order:order:edit',
  /** 删除订单 */
  DELETE: 'order:order:delete',
  /** 导出订单 */
  EXPORT: 'order:list:export',
  /** 审核订单 */
  AUDIT: 'order:order:audit',
} as const

/** 权限点类型（用于类型安全引用） */
export type OrderPermission = (typeof ORDER_PERMISSIONS)[keyof typeof ORDER_PERMISSIONS]
```

### 统一导出

```ts
// src/permission/index.ts

export { ORDER_PERMISSIONS } from './modules/order'
export { USER_CENTER_PERMISSIONS } from './modules/user-center'
export { CONTENT_PERMISSIONS } from './modules/content'

// 全量权限类型（用于通用权限校验函数参数类型）
export type Permission =
  | import('./modules/order').OrderPermission
  | import('./modules/user-center').UserCenterPermission
  | import('./modules/content').ContentPermission
```

---

## 使用方式（MUST）

### 路由权限守卫

```ts
// router/modules/order.ts
import { ORDER_PERMISSIONS } from '@/permission'

const orderRoutes = [
  {
    path: '/order/list',
    component: () => import('@/views/order/list.vue'),
    meta: {
      /** 需要查看订单列表权限 */
      permission: ORDER_PERMISSIONS.LIST_VIEW,
    },
  },
]
```

### 按钮级权限控制

```vue
<template>
  <!-- 使用自定义指令 -->
  <el-button v-permission="ORDER_PERMISSIONS.EXPORT">导出</el-button>

  <!-- 或使用 v-if + composable -->
  <el-button v-if="hasPermission(ORDER_PERMISSIONS.DELETE)">删除</el-button>
</template>

<script setup lang="ts">
import { ORDER_PERMISSIONS } from '@/permission'
import { usePermission } from '@/composables/usePermission'

const { hasPermission } = usePermission()
</script>
```

---

## 约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 权限点统一在 `permission/modules/` 下定义，禁止散落在页面或组件中 |
| 2 | MUST | 权限点命名格式为 `{模块}:{资源}:{操作}`，三段式，全小写 + `kebab-case` |
| 3 | MUST | 操作动词使用标准集合，扩展需在文件头部声明 |
| 4 | MUST | 页面和组件通过导入常量引用权限点，禁止硬编码字符串 |
| 5 | MUST | 每个权限常量必须有中文注释说明用途 |
| 6 | SHOULD | 权限点与服务端返回的标识保持一致，由服务端统一分配 |
| 7 | SHOULD | CI 增加检查脚本，扫描代码中是否存在未通过常量引用的权限字符串 |

检查方式：代码审查 + CI 扫描
阻断级别：MUST 条款阻断合并，SHOULD 条款登记技术债
