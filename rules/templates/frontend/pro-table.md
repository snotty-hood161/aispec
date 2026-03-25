# ProTable 表格组件标准模板

## 文档目标
1. 定义后台管理项目中 Element Plus 表格的标准化封装方案（Schema-Driven Table）。
2. 与 Schema-Driven Forms 同理：用数据描述列定义，禁止逐列手写模板。
3. 技术栈锁定参见 `applications/admin-console.md`。

---

## 目录结构（MUST）

```
src/
  components/
    ProTable/
      index.vue           # ProTable 主组件
      types.ts            # 列定义、配置类型
      useProTable.ts      # 表格逻辑 composable
      renderers/
        index.ts          # 渲染器注册表
        EnumRenderer.vue  # 枚举值渲染（状态标签等）
        DateRenderer.vue  # 日期时间格式化
        CurrencyRenderer.vue # 金额格式化
```

---

## 一、类型定义（`types.ts`）

```ts
// components/ProTable/types.ts

/** 列定义 */
export interface ProTableColumn<T = Record<string, unknown>> {
  /** 字段名（对应数据对象的 key） */
  prop: keyof T & string
  /** 列标题 */
  label: string
  /** 列宽（px），不设则自适应 */
  width?: number
  /** 最小列宽 */
  minWidth?: number
  /** 是否支持排序 */
  sortable?: boolean | 'custom'
  /** 是否固定列 */
  fixed?: 'left' | 'right'
  /** 内置渲染器名称 */
  renderer?: 'enum' | 'date' | 'datetime' | 'currency' | 'image' | 'link'
  /** 枚举映射（renderer 为 enum 时必填） */
  enumMap?: Record<string | number, { label: string; type?: 'success' | 'warning' | 'danger' | 'info' }>
  /** 自定义插槽名称（优先级高于 renderer） */
  slotName?: string
  /** 是否在搜索栏显示 */
  searchable?: boolean
  /** 搜索控件类型 */
  searchType?: 'input' | 'select' | 'date' | 'daterange'
  /** 搜索字段默认值 */
  searchDefault?: unknown
  /** 是否隐藏该列（用于搜索条件但不展示） */
  hidden?: boolean
  /** 对齐方式 */
  align?: 'left' | 'center' | 'right'
}

/** 分页参数 */
export interface Pagination {
  page: number
  pageSize: number
  total: number
}

/** 表格请求函数签名 */
export type TableRequestFn<T> = (params: {
  page: number
  pageSize: number
  sort?: { prop: string; order: 'ascending' | 'descending' }
  filters: Record<string, unknown>
}) => Promise<{ list: T[]; total: number }>

/** ProTable 配置 */
export interface ProTableConfig<T = Record<string, unknown>> {
  /** 列定义 */
  columns: ProTableColumn<T>[]
  /** 数据请求函数 */
  requestFn: TableRequestFn<T>
  /** 行唯一标识字段，默认 'id' */
  rowKey?: string
  /** 是否显示序号列 */
  showIndex?: boolean
  /** 是否显示选择列 */
  showSelection?: boolean
  /** 每页条数选项 */
  pageSizes?: number[]
  /** 默认每页条数 */
  defaultPageSize?: number
  /** 是否立即加载 */
  immediate?: boolean
}
```

---

## 二、核心 Composable（`useProTable.ts`）

```ts
// components/ProTable/useProTable.ts

import { ref, reactive, onMounted } from 'vue'
import type { Pagination, TableRequestFn } from './types'

/**
 * 表格逻辑封装
 * 统一管理分页、搜索、排序、加载状态
 */
export function useProTable<T>(requestFn: TableRequestFn<T>, options?: {
  defaultPageSize?: number
  immediate?: boolean
}) {
  const { defaultPageSize = 20, immediate = true } = options ?? {}

  /** 表格数据 */
  const tableData = ref<T[]>([]) as ReturnType<typeof ref<T[]>>
  /** 加载状态 */
  const loading = ref(false)
  /** 空态标记 */
  const isEmpty = ref(false)
  /** 是否加载出错 */
  const isError = ref(false)

  /** 分页 */
  const pagination = reactive<Pagination>({
    page: 1,
    pageSize: defaultPageSize,
    total: 0,
  })

  /** 排序 */
  const currentSort = ref<{ prop: string; order: 'ascending' | 'descending' } | undefined>()

  /** 搜索条件 */
  const filters = reactive<Record<string, unknown>>({})

  /** 选中行 */
  const selectedRows = ref<T[]>([])

  /** 加载数据 */
  async function fetchData(): Promise<void> {
    loading.value = true
    isError.value = false
    try {
      const result = await requestFn({
        page: pagination.page,
        pageSize: pagination.pageSize,
        sort: currentSort.value,
        filters: { ...filters },
      })
      tableData.value = result.list as T[]
      pagination.total = result.total
      isEmpty.value = result.list.length === 0
    } catch {
      isError.value = true
      tableData.value = []
      pagination.total = 0
    } finally {
      loading.value = false
    }
  }

  /** 搜索（重置到第一页） */
  function search(): void {
    pagination.page = 1
    fetchData()
  }

  /** 重置搜索条件 */
  function resetFilters(): void {
    Object.keys(filters).forEach((key) => {
      filters[key] = undefined
    })
    search()
  }

  /** 分页变更 */
  function handlePageChange(page: number): void {
    pagination.page = page
    fetchData()
  }

  /** 每页条数变更 */
  function handleSizeChange(size: number): void {
    pagination.pageSize = size
    pagination.page = 1
    fetchData()
  }

  /** 排序变更 */
  function handleSortChange(sort: { prop: string; order: 'ascending' | 'descending' | null }): void {
    currentSort.value = sort.order ? { prop: sort.prop, order: sort.order } : undefined
    fetchData()
  }

  /** 选择变更 */
  function handleSelectionChange(rows: T[]): void {
    selectedRows.value = rows
  }

  /** 刷新当前页 */
  function refresh(): void {
    fetchData()
  }

  if (immediate) {
    onMounted(() => fetchData())
  }

  return {
    tableData,
    loading,
    isEmpty,
    isError,
    pagination,
    filters,
    selectedRows,
    search,
    resetFilters,
    refresh,
    handlePageChange,
    handleSizeChange,
    handleSortChange,
    handleSelectionChange,
  }
}
```

---

## 三、ProTable 组件（`index.vue`）

```vue
<!-- components/ProTable/index.vue -->
<template>
  <!-- 搜索栏 -->
  <div v-if="searchColumns.length > 0" class="mb-4 flex flex-wrap items-end gap-4">
    <template v-for="col in searchColumns" :key="col.prop">
      <!-- 输入框 -->
      <el-input
        v-if="col.searchType === 'input' || !col.searchType"
        v-model="filters[col.prop]"
        :placeholder="`请输入${col.label}`"
        clearable
        class="w-[200px]"
      />
      <!-- 下拉框 -->
      <el-select
        v-else-if="col.searchType === 'select'"
        v-model="filters[col.prop]"
        :placeholder="`请选择${col.label}`"
        clearable
        class="w-[200px]"
      >
        <el-option
          v-for="(item, key) in col.enumMap"
          :key="key"
          :label="item.label"
          :value="key"
        />
      </el-select>
      <!-- 日期选择 -->
      <el-date-picker
        v-else-if="col.searchType === 'date'"
        v-model="filters[col.prop]"
        type="date"
        :placeholder="`请选择${col.label}`"
        value-format="YYYY-MM-DD"
        class="w-[200px]"
      />
      <!-- 日期范围 -->
      <el-date-picker
        v-else-if="col.searchType === 'daterange'"
        v-model="filters[col.prop]"
        type="daterange"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        value-format="YYYY-MM-DD"
        class="w-[340px]"
      />
    </template>
    <el-button type="primary" @click="search">查询</el-button>
    <el-button @click="resetFilters">重置</el-button>
  </div>

  <!-- 操作栏插槽 -->
  <div v-if="$slots.toolbar" class="mb-4 flex items-center justify-between">
    <slot name="toolbar" :selected-rows="selectedRows" />
  </div>

  <!-- 表格 -->
  <el-table
    v-loading="loading"
    :data="tableData"
    :row-key="rowKey"
    border
    stripe
    @sort-change="handleSortChange"
    @selection-change="handleSelectionChange"
  >
    <!-- 选择列 -->
    <el-table-column v-if="showSelection" type="selection" width="50" align="center" />
    <!-- 序号列 -->
    <el-table-column v-if="showIndex" type="index" label="序号" width="60" align="center" />

    <!-- 数据列 -->
    <template v-for="col in visibleColumns" :key="col.prop">
      <!-- 自定义插槽列 -->
      <el-table-column
        v-if="col.slotName"
        :prop="col.prop"
        :label="col.label"
        :width="col.width"
        :min-width="col.minWidth"
        :sortable="col.sortable"
        :fixed="col.fixed"
        :align="col.align ?? 'left'"
      >
        <template #default="scope">
          <slot :name="col.slotName" v-bind="scope" />
        </template>
      </el-table-column>
      <!-- 渲染器列 -->
      <el-table-column
        v-else
        :prop="col.prop"
        :label="col.label"
        :width="col.width"
        :min-width="col.minWidth"
        :sortable="col.sortable"
        :fixed="col.fixed"
        :align="col.align ?? 'left'"
      >
        <template v-if="col.renderer" #default="{ row }">
          <!-- 枚举渲染 -->
          <template v-if="col.renderer === 'enum' && col.enumMap">
            <el-tag
              :type="col.enumMap[row[col.prop]]?.type ?? 'info'"
              size="small"
            >
              {{ col.enumMap[row[col.prop]]?.label ?? row[col.prop] }}
            </el-tag>
          </template>
          <!-- 日期渲染 -->
          <template v-else-if="col.renderer === 'date'">
            {{ formatDate(row[col.prop]) }}
          </template>
          <!-- 日期时间渲染 -->
          <template v-else-if="col.renderer === 'datetime'">
            {{ formatDatetime(row[col.prop]) }}
          </template>
          <!-- 金额渲染 -->
          <template v-else-if="col.renderer === 'currency'">
            ¥{{ formatCurrency(row[col.prop]) }}
          </template>
        </template>
      </el-table-column>
    </template>

    <!-- 操作列插槽 -->
    <el-table-column
      v-if="$slots.actions"
      label="操作"
      :width="actionsWidth"
      fixed="right"
      align="center"
    >
      <template #default="scope">
        <slot name="actions" v-bind="scope" />
      </template>
    </el-table-column>

    <!-- 空态 -->
    <template #empty>
      <div v-if="isError" class="py-8 text-center">
        <p class="text-gray-400">加载失败</p>
        <el-button type="primary" link @click="refresh">点击重试</el-button>
      </div>
      <div v-else class="py-8 text-center text-gray-400">暂无数据</div>
    </template>
  </el-table>

  <!-- 分页 -->
  <div class="mt-4 flex justify-end">
    <el-pagination
      v-model:current-page="pagination.page"
      v-model:page-size="pagination.pageSize"
      :page-sizes="pageSizes"
      :total="pagination.total"
      layout="total, sizes, prev, pager, next, jumper"
      @current-change="handlePageChange"
      @size-change="handleSizeChange"
    />
  </div>
</template>

<script setup lang="ts" generic="T extends Record<string, any>">
import { computed } from 'vue'
import type { ProTableColumn, TableRequestFn } from './types'
import { useProTable } from './useProTable'

/** Props */
const props = withDefaults(defineProps<{
  columns: ProTableColumn<T>[]
  requestFn: TableRequestFn<T>
  rowKey?: string
  showIndex?: boolean
  showSelection?: boolean
  pageSizes?: number[]
  defaultPageSize?: number
  immediate?: boolean
  actionsWidth?: number
}>(), {
  rowKey: 'id',
  showIndex: false,
  showSelection: false,
  pageSizes: () => [10, 20, 50, 100],
  defaultPageSize: 20,
  immediate: true,
  actionsWidth: 200,
})

const {
  tableData,
  loading,
  isEmpty,
  isError,
  pagination,
  filters,
  selectedRows,
  search,
  resetFilters,
  refresh,
  handlePageChange,
  handleSizeChange,
  handleSortChange,
  handleSelectionChange,
} = useProTable<T>(props.requestFn, {
  defaultPageSize: props.defaultPageSize,
  immediate: props.immediate,
})

/** 可见列（过滤 hidden） */
const visibleColumns = computed(() => props.columns.filter((col) => !col.hidden))

/** 搜索列 */
const searchColumns = computed(() => props.columns.filter((col) => col.searchable))

/** 日期格式化 */
function formatDate(val: string | number): string {
  if (!val) return '-'
  return new Date(val).toLocaleDateString('zh-CN')
}

/** 日期时间格式化 */
function formatDatetime(val: string | number): string {
  if (!val) return '-'
  return new Date(val).toLocaleString('zh-CN')
}

/** 金额格式化 */
function formatCurrency(val: number): string {
  if (val == null) return '-'
  return val.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

/** 暴露方法给父组件 */
defineExpose({ refresh, search, resetFilters, selectedRows })
</script>
```

---

## 四、页面使用示例

```vue
<!-- views/order/list.vue -->
<template>
  <ProTable
    ref="tableRef"
    :columns="columns"
    :request-fn="fetchOrders"
    show-index
    show-selection
  >
    <!-- 工具栏 -->
    <template #toolbar="{ selectedRows }">
      <el-button type="primary" @click="handleCreate">新增订单</el-button>
      <el-button
        :disabled="selectedRows.length === 0"
        @click="handleBatchExport(selectedRows)"
      >
        批量导出（{{ selectedRows.length }}）
      </el-button>
    </template>

    <!-- 操作列 -->
    <template #actions="{ row }">
      <el-button type="primary" link @click="handleView(row)">查看</el-button>
      <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
      <el-popconfirm title="确认删除？" @confirm="handleDelete(row)">
        <template #reference>
          <el-button type="danger" link>删除</el-button>
        </template>
      </el-popconfirm>
    </template>
  </ProTable>
</template>

<script setup lang="ts">
import ProTable from '@/components/ProTable/index.vue'
import type { ProTableColumn } from '@/components/ProTable/types'
import { getOrderList } from '@/services/modules/order'

/** 订单数据类型 */
interface OrderRow {
  id: string
  orderNo: string
  status: number
  amount: number
  createdAt: string
}

/** 订单状态枚举映射 */
const ORDER_STATUS_MAP = {
  0: { label: '待支付', type: 'warning' as const },
  1: { label: '已支付', type: 'success' as const },
  2: { label: '已取消', type: 'info' as const },
  3: { label: '已退款', type: 'danger' as const },
}

/** 列定义 — 声明式配置，禁止逐列手写模板 */
const columns: ProTableColumn<OrderRow>[] = [
  {
    prop: 'orderNo',
    label: '订单号',
    width: 200,
    searchable: true,
    searchType: 'input',
  },
  {
    prop: 'status',
    label: '订单状态',
    width: 120,
    renderer: 'enum',
    enumMap: ORDER_STATUS_MAP,
    searchable: true,
    searchType: 'select',
  },
  {
    prop: 'amount',
    label: '金额',
    width: 120,
    renderer: 'currency',
    sortable: 'custom',
    align: 'right',
  },
  {
    prop: 'createdAt',
    label: '创建时间',
    width: 180,
    renderer: 'datetime',
    sortable: 'custom',
    searchable: true,
    searchType: 'daterange',
  },
]

/** 请求函数 — 对接 services 层 */
const fetchOrders = getOrderList

/** 以下为页面操作逻辑 */
function handleCreate(): void { /* 新增 */ }
function handleView(row: OrderRow): void { /* 查看 */ }
function handleEdit(row: OrderRow): void { /* 编辑 */ }
function handleDelete(row: OrderRow): void { /* 删除 */ }
function handleBatchExport(rows: OrderRow[]): void { /* 批量导出 */ }
</script>
```

---

## 五、约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 后台管理表格统一使用 ProTable 组件，禁止页面内直接写 `<el-table>` + 分页 + 搜索组合 |
| 2 | MUST | 列定义使用声明式 `columns` 配置，禁止在模板中逐列手写 `<el-table-column>` |
| 3 | MUST | 数据请求通过 `requestFn` 注入，ProTable 内部不直接调用接口 |
| 4 | MUST | 枚举值使用 `enumMap` 统一映射，禁止在模板中 `v-if` 逐个判断状态 |
| 5 | MUST | 表格必须包含空态（暂无数据）和异常态（加载失败 + 重试），禁止空白展示 |
| 6 | MUST | 分页参数（page/pageSize）由 ProTable 内部管理，页面不手动维护分页变量 |
| 7 | SHOULD | 操作列和工具栏通过插槽扩展，保持 ProTable 组件通用性 |
| 8 | SHOULD | 大数据量表格（1000+ 行）开启虚拟滚动或强制分页，禁止全量渲染 |

检查方式：代码审查
阻断级别：MUST 条款阻断合并
