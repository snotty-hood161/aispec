# rules/flutter/common/baseline.md

## 技术基线

1. Flutter SDK 版本以项目根目录 `.fvmrc`（推荐使用 FVM）或 `pubspec.yaml` 中 `environment.flutter` 声明为准，推荐最新 stable channel。
2. Dart SDK 版本必须 ≥ 3.0，强制启用 Null Safety。
3. SDK 版本升级必须单独提交，附变更日志和兼容性验证结果。
4. 禁止使用 beta / dev / master channel 用于生产构建。

## 项目创建标准（MUST）

1. 新项目必须通过 `flutter create` 创建，禁止手动拼凑项目结构。
2. 项目必须在 `pubspec.yaml` 中明确声明 `environment` SDK 约束：

```yaml
environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.19.0"
```

3. 项目名使用 `lowercase_with_underscores`，禁止中文、空格、连字符。
4. 多 Package 项目（Monorepo）推荐使用 **Melos** 管理。

## 依赖管理（MUST）

1. 所有依赖版本必须在 `pubspec.yaml` 中明确约束，禁止使用 `any` 版本。
2. 推荐使用语义化版本约束：`^x.y.z`（兼容性升级），避免 `>=x.y.z <(x+1).0.0` 宽泛范围。
3. `pubspec.lock` 必须纳入版本控制（应用项目），确保构建可重复。
4. 第三方依赖引入必须经过团队评审，评估：
   - pub.dev 评分（Likes / Pub Points / Popularity）。
   - 维护状态（最后更新时间、Issue 响应速度）。
   - 许可证兼容性（MIT / BSD / Apache 2.0 优先）。
   - Null Safety 支持。
5. 禁止使用已废弃（deprecated）或长期未维护（> 12 个月无更新）的包。
6. 必须定期运行 `dart pub outdated` 检查过期依赖。

## 静态分析（MUST）

1. 项目根目录必须包含 `analysis_options.yaml`，启用严格分析模式：

```yaml
include: package:flutter_lints/flutter.yaml
# 或使用更严格的 very_good_analysis
# include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_return: error
    dead_code: warning
```

2. 推荐使用 `very_good_analysis` 或 `flutter_lints` 作为 lint 规则基线。
3. CI 流水线必须执行 `dart analyze --fatal-infos`，任何 info 级别以上问题阻断合并。
4. 推荐集成 `dart_code_metrics`（DCM）进行代码复杂度与质量度量。
5. 提交前必须运行 `dart format --set-exit-if-changed .` 确保格式统一。
