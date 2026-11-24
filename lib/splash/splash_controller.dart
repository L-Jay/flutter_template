import '../common/common.dart';

class SplashController extends GetxController {
  /// 与启动进度条动画时长保持一致
  static const Duration minSplashDuration = Duration(milliseconds: 900);

  @override
  Future<void> onReady() async {
    super.onReady();

    await Future.delayed(minSplashDuration);
    RouterManager.replaceNamed(Routers.root);
  }
}
