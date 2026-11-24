import 'package:flutter_template/common/models/config_model.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../api_url.dart';

class ConfigService extends GetxService {
  static ConfigService get to => Get.find();

  final openSoundEffect = true.obs;

  final configDataInfo = ConfigData().obs;

  @override
  void onInit() {
    super.onInit();

    openSoundEffect.value =
        LJUtil.preferences.getBool('openSoundEffect') ?? true;
    ever(
      openSoundEffect,
      (value) => LJUtil.preferences.setBool('openSoundEffect', value),
    );

    fetchConfig();
  }

  Future<void> fetchConfig() async {
    // 已有配置就直接复用，拿不到时再由调用方重新请求
    if (configDataInfo.value.protocolUrl?.isNotEmpty == true) return;

    ConfigModel model = await LJNetwork.get<ConfigModel>(ApiUrl.config);
    if (model.data != null) {
      configDataInfo.value = model.data!;
    }
  }
}
