# rules/frontend/applications/wechat-h5.md

## 文档目标
1. 定义公众号 H5 目标端规则（基于 `uni-app`）与微信生态约束。
2. 本文件描述的是“目标端规则”，可用于独立应用，也可用于同一应用的 H5 构建目标。

## 技术栈锁定（MUST，V1）
1. 框架：`uni-app + Vue3 + TypeScript`
2. UI 方案：`uview-plus`
3. 原子化样式：`UnoCSS`（使用 Tailwind 风格语法）
4. 状态管理：`Pinia`
5. 状态持久化：`pinia-plugin-persistedstate`（存储适配到 `uni.setStorage`）
6. 请求层：统一封装 `uni.request`（禁止在 uni-app 端直接使用 Axios）
7. 微信能力：`weixin-js-sdk`（仅 H5 端启用，必须封装在适配层）
8. 富文本展示：`rich-text`（可配合 `u-parse`）
9. `MUST`：同类库禁止并存，避免活动页长期失控。
10. `MUST`：禁止引入 `Taro` 相关依赖（如 `@tarojs/*`）。

## 项目结构引用（MUST）
1. 公众号 H5 结构规则以 `rules/frontend/project-structure/wechat-h5.md` 为准。
2. 通用结构边界仍需遵守 `rules/frontend/common/project-structure.md`。

## 应用边界规则
1. `MUST`：同一应用如果还需要微信小程序目标，可继续使用同一 `uni-app` 项目多端编译。
2. `MUST`：不同应用（如员工端与 C 端）必须拆分成不同项目，不得混在同一业务代码中。
3. `SHOULD`：多 Tab 同页场景优先采用 `tab-host` 宿主页模式，避免无必要路由切换。

## 微信生态规则
1. `MUST`：微信授权流程统一在 `platform/h5/wechat` 封装，页面禁止直连 JSSDK。
2. `MUST`：分享、支付、拉起等能力必须有失败回退与错误提示。
3. `MUST`：处理授权拒绝、签名过期、弱网超时三类核心异常。
4. `SHOULD`：活动页面放 `scenes/`，活动结束后可单独归档下线。
5. `SHOULD`：主题色、间距、字号优先使用 token，不新增页面级硬编码样式值。

## 性能与兼容
1. `MUST`：首屏资源做体积预算，超过预算需评审。
2. `MUST`：至少覆盖 iOS/Android + 主流微信版本兼容验证。
3. `MUST`：`UnoCSS` 原子类必须纳入构建产物检查，防止动态类名丢失样式。
4. `SHOULD`：关键路径支持骨架屏或降级占位，避免白屏感知。

## 配套模板
1. 微信授权与分享流程 → `rules/templates/frontend/wechat-auth-share-flow.md`
2. uni.request 标准封装 → `rules/templates/frontend/uni-request-wrapper.md`
3. 机型兼容测试清单 + 活动目录归档规则 → `rules/templates/frontend/wechat-h5-toolkit.md`
