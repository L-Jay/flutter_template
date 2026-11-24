import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'common/common.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (isIOS || isAndroid) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  await Bootstrap.setup();
  runApp(const App());
  if (isIOS || isAndroid) {
    // 等 Flutter 首帧渲染后再移除原生闪屏，避免 setup 变慢时出现白屏
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FlutterNativeSplash.remove(),
    );
  }
}
