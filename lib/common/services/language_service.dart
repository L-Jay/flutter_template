import '../common.dart';

/// 语言全局服务：`null` 表示跟随系统，切换后持久化到本地。
class LanguageService extends GetxService {
  static LanguageService get to => Get.find();

  static const String _key = 'locale';

  final locale = Rxn<Locale>();

  @override
  void onInit() {
    super.onInit();

    final String? code = LJUtil.preferences.getString(_key);
    if (code != null && (code == 'zh' || code == 'en')) {
      locale.value = Locale(code);
    }
  }

  void setLocale(String? code) {
    if (code == null || (code != 'zh' && code != 'en')) {
      locale.value = null;
      // GetMaterialApp 内部优先使用 Get.locale，需同步置空才能回到跟随系统
      Get.locale = null;
      LJUtil.preferences.remove(_key);
      return;
    }

    locale.value = Locale(code);
    // GetMaterialApp 内部优先使用 Get.locale，不同步会导致切换后要重启才生效
    Get.locale = Locale(code);
    LJUtil.preferences.setString(_key, code);
  }
}
