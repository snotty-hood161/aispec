---
name: ios-coding-guide
description: iOS 移动端编码规范引导。当 AI 编写 Swift/ObjC iOS 应用代码时触发，根据 UI 框架（SwiftUI/UIKit）自动加载对应的规则文件子集来约束代码输出。也可用于指导人类开发者遵循规范。
workflow: _templates/coding-guide-workflow.md
---

# iOS 编码引导

在编写 Swift/ObjC iOS 应用代码时，按编码场景自动加载对应规范，约束代码输出。

## 域参数

- **domain**: ios
- **baseline_files**: `baseline.md`, `forbidden.md`
- **scenario_map**: `references/coding-scenario-map.md`
- **rules_index**: `rules/ios/index.md`
- **max_load**: 6
- **context**: UI 框架（SwiftUI / UIKit）

## 跨域联动

| 触发条件 | 联动 Skill |
|---------|-----------|
| 远程 API 调用 | `$frontend-backend-coding-guide` |

## 资源
1. 场景路由表：`references/coding-scenario-map.md`
2. 规则索引：`rules/ios/index.md`
