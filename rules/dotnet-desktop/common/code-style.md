# rules/dotnet-desktop/common/code-style.md

## 命名与组织
1. 命名空间与目录结构保持一致，禁止手动修改 `<RootNamespace>` 导致命名空间与物理路径不匹配。
2. 类名、方法名、属性名使用 PascalCase；参数名、局部变量使用 camelCase；私有字段使用 `_camelCase`。
3. 接口名以 `I` 前缀（如 `IUserService`），禁止使用 `Impl` 后缀命名实现类。
4. 异步方法必须以 `Async` 后缀命名（如 `LoadDataAsync`）。
5. 文件命名必须体现职责，一个文件一个顶级类型，禁止 `Util.cs`、`Common.cs`、`Misc.cs` 等模糊命名。
6. XAML 文件与对应的 Code-Behind 或 ViewModel 文件命名一致（如 `MainWindow.xaml` + `MainWindowViewModel.cs`）。
7. 常量使用 PascalCase，禁止使用 `ALL_UPPER_CASE`。

## 注释规范

### MUST
1. 注释语言统一使用中文；与外部开源库交互的接口适配文件允许使用英文。
2. 所有公开的类型、方法、属性、接口必须有 XML 文档注释（`/// <summary>`）。
3. 非公开但逻辑复杂的方法（超过 30 行或包含复杂分支）必须添加中文注释。
4. 复杂业务逻辑、非直觉的条件判断、临时方案（workaround）必须行内注释说明背景。
5. 禁止无意义注释，注释必须提供代码本身未表达的信息。
6. ViewModel 中的命令和属性必须注释说明对应的 UI 行为和业务含义。

### SHOULD
1. TODO/FIXME 注释必须附带责任人和预计回收时间。
2. 注释随代码同步更新，禁止过期注释残留。

检查方式：Roslyn 分析器 + 人工审查
阻断级别：阻断合并

## 调试代码清理

### MUST
1. 禁止将 `Console.WriteLine`、`Debug.WriteLine`、`Trace.WriteLine` 等调试打印提交到主分支；所有日志输出必须通过项目统一的日志组件（参见 `common/observability.md`）。
2. 禁止将 `Debugger.Break()`、`Debugger.Launch()` 等调试指令提交到主分支。
3. 禁止将 `MessageBox.Show` 用于调试目的提交到主分支（正式用户提示除外）。
4. 开发环境允许临时使用调试手段，但提交前必须清理。

检查方式：Roslyn 分析器 + CI 阻断
阻断级别：阻断合并

## XAML 代码规范
1. XAML 中禁止内联复杂逻辑（如多行 Converter 或大段 Trigger），必须提取到独立的 ValueConverter 或 Style 资源。
2. 样式和模板必须定义在资源字典中（`ResourceDictionary`），禁止在控件内联重复定义。
3. 硬编码字符串（按钮文字、提示信息等）必须提取到资源文件，便于本地化。
4. 颜色、字体、间距等视觉常量必须定义为资源（`StaticResource` / `DynamicResource`），禁止在 XAML 中散写魔法值。
5. 数据绑定表达式必须有 `FallbackValue` 或 `TargetNullValue`，防止设计时和运行时出现绑定错误。
