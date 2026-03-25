# Tiptap 富文本编辑器标准封装模板

## 文档目标
1. 定义后台管理项目中 Tiptap 编辑器的标准封装方案。
2. 统一工具栏配置、图片上传、内容序列化和 XSS 防护。
3. 技术栈锁定参见 `applications/admin-console.md`（富文本编辑器：Tiptap）。

---

## 目录结构（MUST）

```
src/
  components/
    RichEditor/
      index.vue           # 编辑器主组件
      types.ts            # 类型定义
      toolbar.ts          # 工具栏配置
      extensions.ts       # Tiptap 扩展注册
      ImageUpload.vue     # 图片上传弹窗
      sanitize.ts         # XSS 过滤
```

---

## 一、类型定义（`types.ts`）

```ts
// components/RichEditor/types.ts

/** 工具栏按钮标识 */
export type ToolbarItem =
  | 'bold'
  | 'italic'
  | 'underline'
  | 'strike'
  | 'heading'
  | 'bulletList'
  | 'orderedList'
  | 'blockquote'
  | 'codeBlock'
  | 'link'
  | 'image'
  | 'table'
  | 'horizontalRule'
  | 'undo'
  | 'redo'
  | 'divider'

/** 编辑器配置 */
export interface RichEditorConfig {
  /** 工具栏按钮列表，divider 为分隔符 */
  toolbar?: ToolbarItem[]
  /** 占位文字 */
  placeholder?: string
  /** 最大字符数（0 为不限制） */
  maxLength?: number
  /** 编辑器最小高度（px） */
  minHeight?: number
  /** 是否只读 */
  readonly?: boolean
  /** 图片上传函数（返回图片 URL） */
  uploadImage?: (file: File) => Promise<string>
}

/** 默认工具栏 */
export const DEFAULT_TOOLBAR: ToolbarItem[] = [
  'bold', 'italic', 'underline', 'strike',
  'divider',
  'heading',
  'divider',
  'bulletList', 'orderedList', 'blockquote',
  'divider',
  'link', 'image', 'table',
  'divider',
  'horizontalRule', 'codeBlock',
  'divider',
  'undo', 'redo',
]
```

---

## 二、扩展注册（`extensions.ts`）

```ts
// components/RichEditor/extensions.ts

import StarterKit from '@tiptap/starter-kit'
import Underline from '@tiptap/extension-underline'
import Link from '@tiptap/extension-link'
import Image from '@tiptap/extension-image'
import Table from '@tiptap/extension-table'
import TableRow from '@tiptap/extension-table-row'
import TableCell from '@tiptap/extension-table-cell'
import TableHeader from '@tiptap/extension-table-header'
import Placeholder from '@tiptap/extension-placeholder'
import CharacterCount from '@tiptap/extension-character-count'
import type { Extensions } from '@tiptap/core'

/** 根据配置生成扩展列表 */
export function createExtensions(options: {
  placeholder?: string
  maxLength?: number
}): Extensions {
  const { placeholder = '请输入内容...', maxLength = 0 } = options

  return [
    StarterKit.configure({
      /** 使用 StarterKit 内置的 heading，限制 h1-h4 */
      heading: { levels: [1, 2, 3, 4] },
    }),
    Underline,
    Link.configure({
      /** 链接在新标签页打开 */
      openOnClick: false,
      HTMLAttributes: { target: '_blank', rel: 'noopener noreferrer' },
    }),
    Image.configure({
      /** 禁止内联图片，强制块级展示 */
      inline: false,
      /** 允许设置图片宽高 */
      allowBase64: false,
    }),
    Table.configure({ resizable: true }),
    TableRow,
    TableCell,
    TableHeader,
    Placeholder.configure({ placeholder }),
    ...(maxLength > 0
      ? [CharacterCount.configure({ limit: maxLength })]
      : []),
  ]
}
```

---

## 三、XSS 过滤（`sanitize.ts`）

```ts
// components/RichEditor/sanitize.ts

import sanitizeHtml from 'sanitize-html'

/** 允许的 HTML 标签白名单 */
const ALLOWED_TAGS = [
  'p', 'br', 'strong', 'em', 'u', 's', 'del',
  'h1', 'h2', 'h3', 'h4',
  'ul', 'ol', 'li',
  'blockquote', 'pre', 'code',
  'a', 'img',
  'table', 'thead', 'tbody', 'tr', 'th', 'td',
  'hr', 'div', 'span',
]

/** 允许的属性白名单 */
const ALLOWED_ATTRIBUTES: Record<string, string[]> = {
  a: ['href', 'target', 'rel'],
  img: ['src', 'alt', 'width', 'height'],
  td: ['colspan', 'rowspan'],
  th: ['colspan', 'rowspan'],
  '*': ['class', 'style'],
}

/**
 * 过滤 HTML 内容，防止 XSS 攻击
 * 编辑器内部不过滤（保持编辑体验），展示时必须过滤
 */
export function sanitizeContent(html: string): string {
  return sanitizeHtml(html, {
    allowedTags: ALLOWED_TAGS,
    allowedAttributes: ALLOWED_ATTRIBUTES,
    /** 过滤 javascript: 协议 */
    allowedSchemes: ['http', 'https', 'mailto'],
    /** 移除空标签 */
    exclusiveFilter: (frame) => {
      return !frame.text.trim() && ['p', 'div', 'span'].includes(frame.tag)
    },
  })
}
```

---

## 四、编辑器主组件（`index.vue`）

```vue
<!-- components/RichEditor/index.vue -->
<template>
  <div class="rich-editor" :class="{ 'is-readonly': config.readonly }">
    <!-- 工具栏 -->
    <div v-if="!config.readonly && editor" class="rich-editor__toolbar flex flex-wrap items-center gap-1 border-b border-gray-200 px-2 py-1">
      <template v-for="(item, index) in toolbarItems" :key="index">
        <!-- 分隔符 -->
        <div v-if="item === 'divider'" class="mx-1 h-5 w-px bg-gray-200" />

        <!-- 加粗 -->
        <el-button
          v-else-if="item === 'bold'"
          :class="{ 'is-active': editor.isActive('bold') }"
          text
          size="small"
          @click="editor.chain().focus().toggleBold().run()"
        >B</el-button>

        <!-- 斜体 -->
        <el-button
          v-else-if="item === 'italic'"
          :class="{ 'is-active': editor.isActive('italic') }"
          text
          size="small"
          @click="editor.chain().focus().toggleItalic().run()"
        >I</el-button>

        <!-- 下划线 -->
        <el-button
          v-else-if="item === 'underline'"
          :class="{ 'is-active': editor.isActive('underline') }"
          text
          size="small"
          @click="editor.chain().focus().toggleUnderline().run()"
        >U</el-button>

        <!-- 删除线 -->
        <el-button
          v-else-if="item === 'strike'"
          :class="{ 'is-active': editor.isActive('strike') }"
          text
          size="small"
          @click="editor.chain().focus().toggleStrike().run()"
        >S</el-button>

        <!-- 标题 -->
        <el-dropdown v-else-if="item === 'heading'" trigger="click" @command="setHeading">
          <el-button text size="small">标题</el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item :command="1">标题 1</el-dropdown-item>
              <el-dropdown-item :command="2">标题 2</el-dropdown-item>
              <el-dropdown-item :command="3">标题 3</el-dropdown-item>
              <el-dropdown-item :command="4">标题 4</el-dropdown-item>
              <el-dropdown-item :command="0">正文</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>

        <!-- 无序列表 -->
        <el-button
          v-else-if="item === 'bulletList'"
          :class="{ 'is-active': editor.isActive('bulletList') }"
          text
          size="small"
          @click="editor.chain().focus().toggleBulletList().run()"
        >无序</el-button>

        <!-- 有序列表 -->
        <el-button
          v-else-if="item === 'orderedList'"
          :class="{ 'is-active': editor.isActive('orderedList') }"
          text
          size="small"
          @click="editor.chain().focus().toggleOrderedList().run()"
        >有序</el-button>

        <!-- 引用 -->
        <el-button
          v-else-if="item === 'blockquote'"
          :class="{ 'is-active': editor.isActive('blockquote') }"
          text
          size="small"
          @click="editor.chain().focus().toggleBlockquote().run()"
        >引用</el-button>

        <!-- 代码块 -->
        <el-button
          v-else-if="item === 'codeBlock'"
          :class="{ 'is-active': editor.isActive('codeBlock') }"
          text
          size="small"
          @click="editor.chain().focus().toggleCodeBlock().run()"
        >代码</el-button>

        <!-- 链接 -->
        <el-button
          v-else-if="item === 'link'"
          :class="{ 'is-active': editor.isActive('link') }"
          text
          size="small"
          @click="handleLink"
        >链接</el-button>

        <!-- 图片 -->
        <el-button
          v-else-if="item === 'image'"
          text
          size="small"
          @click="showImageUpload = true"
        >图片</el-button>

        <!-- 表格 -->
        <el-button
          v-else-if="item === 'table'"
          text
          size="small"
          @click="editor.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run()"
        >表格</el-button>

        <!-- 分割线 -->
        <el-button
          v-else-if="item === 'horizontalRule'"
          text
          size="small"
          @click="editor.chain().focus().setHorizontalRule().run()"
        >分割</el-button>

        <!-- 撤销 -->
        <el-button
          v-else-if="item === 'undo'"
          :disabled="!editor.can().undo()"
          text
          size="small"
          @click="editor.chain().focus().undo().run()"
        >撤销</el-button>

        <!-- 重做 -->
        <el-button
          v-else-if="item === 'redo'"
          :disabled="!editor.can().redo()"
          text
          size="small"
          @click="editor.chain().focus().redo().run()"
        >重做</el-button>
      </template>
    </div>

    <!-- 编辑区域 -->
    <editor-content
      :editor="editor"
      class="rich-editor__content"
      :style="{ minHeight: `${config.minHeight ?? 300}px` }"
    />

    <!-- 字数统计 -->
    <div v-if="config.maxLength && editor" class="rich-editor__footer flex justify-end border-t border-gray-200 px-3 py-1 text-xs text-gray-400">
      {{ editor.storage.characterCount.characters() }} / {{ config.maxLength }}
    </div>

    <!-- 图片上传弹窗 -->
    <ImageUpload
      v-if="showImageUpload"
      :upload-fn="config.uploadImage"
      @confirm="handleImageInsert"
      @cancel="showImageUpload = false"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onBeforeUnmount, computed } from 'vue'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import { createExtensions } from './extensions'
import { DEFAULT_TOOLBAR } from './types'
import type { RichEditorConfig, ToolbarItem } from './types'
import ImageUpload from './ImageUpload.vue'

/** Props */
const props = withDefaults(defineProps<{
  /** v-model 绑定的 HTML 内容 */
  modelValue?: string
  /** 编辑器配置 */
  config?: RichEditorConfig
}>(), {
  modelValue: '',
  config: () => ({}),
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

/** 图片上传弹窗 */
const showImageUpload = ref(false)

/** 工具栏配置 */
const toolbarItems = computed<ToolbarItem[]>(() => props.config.toolbar ?? DEFAULT_TOOLBAR)

/** 初始化编辑器 */
const editor = useEditor({
  content: props.modelValue,
  extensions: createExtensions({
    placeholder: props.config.placeholder,
    maxLength: props.config.maxLength,
  }),
  editable: !props.config.readonly,
  onUpdate: ({ editor: e }) => {
    emit('update:modelValue', e.getHTML())
  },
})

/** 外部 modelValue 变化时同步到编辑器（避免光标跳转） */
watch(() => props.modelValue, (newVal) => {
  if (editor.value && newVal !== editor.value.getHTML()) {
    editor.value.commands.setContent(newVal, false)
  }
})

/** 设置标题级别 */
function setHeading(level: number): void {
  if (!editor.value) return
  if (level === 0) {
    editor.value.chain().focus().setParagraph().run()
  } else {
    editor.value.chain().focus().toggleHeading({ level: level as 1 | 2 | 3 | 4 }).run()
  }
}

/** 插入/编辑链接 */
function handleLink(): void {
  if (!editor.value) return
  const previousUrl = editor.value.getAttributes('link').href as string | undefined
  const url = window.prompt('请输入链接地址', previousUrl ?? 'https://')

  if (url === null) return
  if (url === '') {
    editor.value.chain().focus().extendMarkRange('link').unsetLink().run()
    return
  }
  editor.value.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
}

/** 插入图片 */
function handleImageInsert(url: string): void {
  if (!editor.value || !url) return
  editor.value.chain().focus().setImage({ src: url }).run()
  showImageUpload.value = false
}

onBeforeUnmount(() => {
  editor.value?.destroy()
})
</script>

<style scoped>
.rich-editor {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  overflow: hidden;
}

.rich-editor.is-readonly {
  border-color: transparent;
}

.rich-editor__toolbar .is-active {
  background-color: #ecf5ff;
  color: #409eff;
}

.rich-editor__content :deep(.tiptap) {
  padding: 12px 16px;
  outline: none;
}

.rich-editor__content :deep(.tiptap p.is-editor-empty:first-child::before) {
  content: attr(data-placeholder);
  color: #c0c4cc;
  pointer-events: none;
  float: left;
  height: 0;
}
</style>
```

---

## 五、图片上传组件（`ImageUpload.vue`）

```vue
<!-- components/RichEditor/ImageUpload.vue -->
<template>
  <el-dialog title="插入图片" :model-value="true" width="480px" @close="emit('cancel')">
    <el-tabs v-model="activeTab">
      <!-- 上传本地图片 -->
      <el-tab-pane label="本地上传" name="upload">
        <el-upload
          :auto-upload="false"
          :show-file-list="false"
          accept="image/png,image/jpeg,image/gif,image/webp"
          :on-change="handleFileChange"
        >
          <el-button type="primary">选择图片</el-button>
        </el-upload>
        <p v-if="selectedFile" class="mt-2 text-sm text-gray-500">
          已选择：{{ selectedFile.name }}
        </p>
      </el-tab-pane>

      <!-- 输入图片 URL -->
      <el-tab-pane label="图片链接" name="url">
        <el-input v-model="imageUrl" placeholder="请输入图片 URL（https://...）" />
      </el-tab-pane>
    </el-tabs>

    <template #footer>
      <el-button @click="emit('cancel')">取消</el-button>
      <el-button type="primary" :loading="uploading" @click="handleConfirm">确认</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import type { UploadFile } from 'element-plus'

const props = defineProps<{
  /** 图片上传函数 */
  uploadFn?: (file: File) => Promise<string>
}>()

const emit = defineEmits<{
  confirm: [url: string]
  cancel: []
}>()

const activeTab = ref<'upload' | 'url'>('upload')
const imageUrl = ref('')
const selectedFile = ref<File | null>(null)
const uploading = ref(false)

/** 文件选择 */
function handleFileChange(file: UploadFile): void {
  if (file.raw) {
    selectedFile.value = file.raw
  }
}

/** 确认插入 */
async function handleConfirm(): Promise<void> {
  if (activeTab.value === 'url') {
    /** URL 模式：直接使用输入的地址 */
    if (!imageUrl.value.trim()) {
      return
    }
    emit('confirm', imageUrl.value.trim())
    return
  }

  /** 上传模式：调用上传函数获取 URL */
  if (!selectedFile.value) {
    return
  }

  if (!props.uploadFn) {
    console.error('[RichEditor] 未配置 uploadImage 函数')
    return
  }

  uploading.value = true
  try {
    const url = await props.uploadFn(selectedFile.value)
    emit('confirm', url)
  } catch {
    /** 上传失败提示 */
    ElMessage.error('图片上传失败，请重试')
  } finally {
    uploading.value = false
  }
}
</script>
```

---

## 六、页面使用示例

### 编辑模式

```vue
<template>
  <RichEditor
    v-model="formData.content"
    :config="editorConfig"
  />
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import RichEditor from '@/components/RichEditor/index.vue'
import type { RichEditorConfig } from '@/components/RichEditor/types'
import { uploadFile } from '@/services/modules/upload'

const formData = reactive({
  content: '',
})

/** 编辑器配置 */
const editorConfig: RichEditorConfig = {
  placeholder: '请输入文章内容...',
  maxLength: 50000,
  minHeight: 400,
  /** 图片上传对接对象存储 */
  uploadImage: async (file: File) => {
    const url = await uploadFile(file, 'article-images')
    return url
  },
}
</script>
```

### 只读模式（详情页复用）

```vue
<template>
  <RichEditor
    :model-value="article.content"
    :config="{ readonly: true }"
  />
</template>
```

### 展示时 XSS 过滤（非编辑器场景，直接渲染 HTML）

```vue
<template>
  <!-- 不使用编辑器组件，直接展示 HTML 时必须过滤 -->
  <div v-html="safeContent" />
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { sanitizeContent } from '@/components/RichEditor/sanitize'

const props = defineProps<{ rawHtml: string }>()

/** 展示前必须过滤，防止 XSS -->
const safeContent = computed(() => sanitizeContent(props.rawHtml))
</script>
```

---

## 七、内容序列化约定（MUST）

| 项目 | 约定 |
|------|------|
| **存储格式** | HTML 字符串（Tiptap `editor.getHTML()`） |
| **数据库字段** | `TEXT` 或 `LONGTEXT`，不限制长度由业务层控制 |
| **前后端传输** | JSON 字段，值为 HTML 字符串 |
| **编辑时** | 不过滤（保持编辑体验，Tiptap 内部已做基本防护） |
| **展示时** | 必须通过 `sanitizeContent()` 过滤后再 `v-html` 渲染 |
| **搜索需求** | 服务端存储时额外提取纯文本字段用于全文检索 |

---

## 八、约束清单

| 编号 | 级别 | 规则 |
|------|------|------|
| 1 | MUST | 富文本编辑统一使用封装后的 RichEditor 组件，禁止页面内直接初始化 Tiptap |
| 2 | MUST | 图片上传必须对接对象存储服务，禁止使用 Base64 内联图片 |
| 3 | MUST | 展示富文本内容时必须经过 `sanitizeContent()` 过滤，防止 XSS |
| 4 | MUST | 工具栏配置通过 `config.toolbar` 声明式控制，禁止直接修改组件模板 |
| 5 | MUST | 内容序列化格式统一为 HTML，前后端保持一致 |
| 6 | MUST | 图片上传限制文件类型（`png/jpeg/gif/webp`）和大小（建议 ≤ 5MB） |
| 7 | SHOULD | 详情页复用 RichEditor 组件的只读模式，而非单独写展示组件 |
| 8 | SHOULD | 编辑器配置（工具栏、字数限制、占位文字）通过 props 传入，保持组件通用性 |

检查方式：代码审查
阻断级别：MUST 条款阻断合并
