# rules/frontend/common/tooling.md

## 文档目标
1. 统一工具链与 CI 约束，避免命令与平台绑定。
2. 以“脚本契约”替代“写死命令”，保障仓库可迁移性。

## 脚本契约（MUST）
1. 每个前端项目必须提供脚本：`lint`、`typecheck`、`test`、`build`。
2. 脚本实现可按项目自选（npm/pnpm/yarn/bun），但脚本名必须一致。
3. 文档与 CI 不得写死工具命令，只能调用脚本契约名。
检查方式：静态扫描 + 人工审查  
阻断级别：阻断合并

## CI 最低阻断标准（MUST）
1. `lint` 失败：阻断合并。
2. `typecheck` 失败：阻断合并。
3. `test` 失败：阻断合并。
4. 如需临时跳过，必须走例外申请并附回收时间。
检查方式：CI 阻断  
阻断级别：阻断合并

## 构建产物清理配置（MUST）

### 要求
1. 所有前端项目的构建配置必须开启以下两项清理，禁止依赖人工手动删除。
2. 此配置必须在项目初始化时完成，纳入项目模板/脚手架。

### 清理项

| 清理项 | 说明 |
|--------|------|
| **console 移除** | 移除 `console.log`、`console.debug`、`console.info`、`console.warn`；保留 `console.error` |
| **注释移除** | 移除产物中所有代码注释（含中文业务注释、license 注释） |
| **debugger 移除** | 移除所有 `debugger` 语句 |

### 各构建工具配置基线

**Vite 项目（后台管理 / Vue3 / uni-app HBuilderX 3.6+）**
```ts
// vite.config.ts
export default defineConfig({
  esbuild: {
    pure: ['console.log', 'console.debug', 'console.info', 'console.warn'],
    drop: ['debugger'],
    legalComments: 'none',
  },
})
```
- 使用 esbuild 内置能力，无需额外安装依赖。

**Webpack 5 项目**
```js
// webpack.config.js
const TerserPlugin = require('terser-webpack-plugin');
module.exports = {
  optimization: {
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            pure_funcs: ['console.log', 'console.debug', 'console.info', 'console.warn'],
            drop_debugger: true,
          },
          format: {
            comments: false,
          },
        },
      }),
    ],
  },
}
```
- `terser-webpack-plugin` 为 Webpack 5 内置，无需额外安装。

### 验证方式
1. `build` 脚本执行后，对产物做文本扫描，确认不含 `console.log`、`console.debug`、`console.info`、`console.warn` 和 `debugger`。
2. 建议在 CI 中增加产物扫描步骤（示例）：
```bash
# 扫描构建产物中是否残留 console（排除 console.error）
grep -rn 'console\.\(log\|debug\|info\|warn\)' dist/ && echo "FAIL: console not cleaned" && exit 1 || echo "PASS"
```

检查方式：构建配置审查 + CI 产物扫描
阻断级别：阻断合并

## 依赖与选型校验（MUST）
1. 核心依赖必须符合 `common/stack-baseline.md`。
2. 禁止引入禁用依赖（当前包含 `@tarojs/*`）。
3. 禁止同一项目并存两套同类核心库（UI、状态管理、请求入口）。
检查方式：静态扫描 + 人工审查  
阻断级别：阻断合并

## 应用端专项校验（MUST）
1. uni-app 项目请求入口必须为 `uni.request` 适配层，不得页面直调 Axios。
2. 小程序构建必须包含主包体积校验（大于 `2MB` 则必须分包）。
3. 小程序资源扫描必须校验图标格式（禁止 `svg`）。
检查方式：静态扫描 + CI 阻断  
阻断级别：阻断合并

## 建议校验（SHOULD）
1. 增加目录边界与循环依赖检查脚本。
2. 增加 token 引用一致性检查。
3. 增加 `UnoCSS/Tailwind` 动态类名丢失检测。
检查方式：静态扫描  
阻断级别：告警记录

## 配套模板
1. 依赖准入检查脚本 + 脚手架依赖清单 → `rules/templates/frontend/dependency-management.md`
2. 小程序包体积校验 + 资源格式检查脚本 → `rules/templates/frontend/miniprogram-ci-checks.md`
