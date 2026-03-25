# rules/react-native/common/device-adaptation.md

## 文档目标
1. 定义 React Native 应用的设备适配规范，覆盖屏幕适配、安全区域、权限管理、深链接。

---

## 屏幕适配（MUST）

1. 布局必须使用 Flexbox 比例布局，禁止使用固定像素值指定容器宽高（小型固定元素除外）。
2. 禁止通过硬编码设备型号 / 分辨率判断布局，必须使用 `useWindowDimensions` 或 `Dimensions` API 动态获取。
3. 推荐使用响应式工具库（`react-native-responsive-screen` / `react-native-size-matters`）处理不同屏幕尺寸。
4. 横竖屏切换时布局必须正确适配（或明确锁定屏幕方向并在配置中声明）。
5. 折叠屏设备推荐响应屏幕尺寸变化事件（`Dimensions.addEventListener('change')`）。
6. 字体大小推荐使用 `sp`（scalable pixel）策略，支持系统字体缩放，但设置 `maxFontSizeMultiplier` 防止布局溢出：

```tsx
<Text maxFontSizeMultiplier={1.5} style={styles.title}>
  标题文本
</Text>
```

7. 禁止使用 `Platform.OS === 'ios'` / `Platform.OS === 'android'` 判断屏幕尺寸（应使用断点判断设备类型）。

---

## 安全区域（MUST）

1. 所有页面必须使用 `SafeAreaView`（推荐 **react-native-safe-area-context** 的 `SafeAreaView`）处理刘海屏 / 圆角 / 底部横条。
2. 禁止在安全区域外放置可交互元素（按钮、输入框、链接）。
3. 状态栏样式必须根据页面背景色动态切换（亮色背景用深色状态栏，深色背景用亮色状态栏）。
4. 底部 Tab 栏必须考虑 iPhone 底部安全区域（Home Indicator），添加相应 padding。
5. 推荐使用 `useSafeAreaInsets()` Hook 获取各方向安全区域尺寸：

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const MyScreen = () => {
  const insets = useSafeAreaInsets();
  return (
    <View style={{ paddingTop: insets.top, paddingBottom: insets.bottom }}>
      {/* 内容 */}
    </View>
  );
};
```

6. Android 必须正确处理状态栏透明 / 沉浸式模式。
7. 全屏页面（如图片查看器、视频播放器）需单独处理安全区域。

---

## 权限管理（MUST）

1. 权限请求必须使用 **react-native-permissions** 或 **expo-permissions** 统一管理。
2. 权限请求遵循以下原则：
   - **按需请求**：仅在用户触发相关功能时请求权限，禁止应用启动时批量请求。
   - **说明用途**：请求前必须展示权限用途说明弹窗，获得用户理解后再触发系统权限弹窗。
   - **优雅降级**：用户拒绝权限后，相关功能展示引导提示而非崩溃或空白。
3. 权限被永久拒绝后，引导用户跳转到系统设置页面开启：

```typescript
import { openSettings, check, request, PERMISSIONS, RESULTS } from 'react-native-permissions';

async function requestCameraPermission(): Promise<boolean> {
  const permission = Platform.select({
    ios: PERMISSIONS.IOS.CAMERA,
    android: PERMISSIONS.ANDROID.CAMERA,
  })!;

  const status = await check(permission);

  switch (status) {
    case RESULTS.GRANTED:
      return true;
    case RESULTS.DENIED:
      const result = await request(permission);
      return result === RESULTS.GRANTED;
    case RESULTS.BLOCKED:
      Alert.alert('需要相机权限', '请在系统设置中开启相机权限', [
        { text: '取消', style: 'cancel' },
        { text: '去设置', onPress: openSettings },
      ]);
      return false;
    default:
      return false;
  }
}
```

4. iOS `Info.plist` 和 Android `AndroidManifest.xml` 中必须声明所有使用的权限，权限说明文案必须准确。
5. 禁止申请未使用的权限（应用商店审核会拒绝）。

---

## 深链接（Deep Linking）（MUST）

1. 必须支持深链接（Universal Links / App Links / Custom URL Scheme），使用 **React Navigation** 的深链接配置。
2. 深链接 URL 结构定义：

```typescript
const linking: LinkingOptions<RootStackParamList> = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Home: 'home',
      Profile: 'profile/:userId',
      OrderDetail: 'order/:orderId',
    },
  },
};
```

3. 深链接参数必须经过校验和净化，防止注入攻击。
4. 未认证用户通过深链接进入需要登录的页面时，必须先引导登录再跳转目标页面。
5. iOS 必须配置 `apple-app-site-association` 文件，Android 必须配置 `assetlinks.json`。
6. 推送通知点击跳转必须通过深链接实现，禁止在通知处理器中硬编码导航逻辑。

---

## 键盘适配（MUST）

1. 包含输入框的页面必须使用 `KeyboardAvoidingView` 处理键盘弹出遮挡问题：
   - iOS 使用 `behavior="padding"`。
   - Android 使用 `android:windowSoftInputMode="adjustResize"`（在 `AndroidManifest.xml` 中配置）。
2. 推荐使用 **react-native-keyboard-aware-scroll-view** 处理表单页面的键盘适配。
3. 长表单页面推荐使用 `ScrollView` 包裹，确保所有输入框可滚动到可见区域。
4. 键盘收起时必须恢复原始布局，禁止出现空白区域。

---

## 网络状态感知（MUST）

1. 必须使用 **@react-native-community/netinfo** 监听网络状态变化。
2. 断网时必须向用户展示离线提示（Banner / Toast），恢复网络后自动重试。
3. 弱网环境下推荐显示加载超时提示和重试按钮。
4. 离线模式下的操作推荐缓存到本地，恢复网络后自动同步。

---

## 多语言与本地化（SHOULD）

1. 推荐使用 **i18next** + **react-i18next** 实现多语言支持。
2. 所有用户可见文案必须通过翻译函数 `t()` 引用，禁止硬编码中文字符串。
3. 日期 / 时间 / 货币格式必须根据用户 Locale 显示。
4. RTL（从右到左）布局推荐在设计阶段考虑，使用 `I18nManager.isRTL` 适配。

---

## 禁止事项

1. 禁止通过硬编码设备型号 / 分辨率判断布局。
2. 禁止使用 `Platform.OS` 判断屏幕尺寸。
3. 禁止在安全区域外放置可交互元素。
4. 禁止应用启动时批量请求所有权限。
5. 禁止深链接参数未经校验直接使用。
6. 禁止申请未使用的权限。
7. 禁止忽略键盘弹出对布局的影响。
