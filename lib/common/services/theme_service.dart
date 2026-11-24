import '../common.dart';

/// 主题模式全局服务：浅色 / 深色 / 跟随系统，持久化到本地。
class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  static const String _key = 'themeMode';

  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();

    final String? saved = LJUtil.preferences.getString(_key);
    themeMode.value = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  void setMode(ThemeMode mode) {
    themeMode.value = mode;
    LJUtil.preferences.setString(_key, mode.name);
  }
}
