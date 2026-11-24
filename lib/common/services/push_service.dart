import 'package:flutter/foundation.dart';

import '../common.dart';

/// 推送服务：业务侧统一入口，具体厂商由 [PushProvider] 实现。
///
/// 换厂商时只需要：
/// 1. 新增 `XxxProvider implements PushProvider`
/// 2. 修改下方 [createProvider] 的返回值
class PushService extends GetxService {
  static PushService get to => Get.find();

  /// 替换推送厂商时只改这里
  PushProvider createProvider() => JPushProvider();

  late final PushProvider _provider = createProvider();

  bool get enabled => _provider.enabled;

  /// 设备注册 ID，可用于服务端定向推送
  String? get registrationId => _provider.registrationId;

  @override
  void onInit() {
    super.onInit();
    if (enabled && !kIsWeb) _init();
  }

  Future<void> _init() async {
    await _provider.init(onNotificationTap: _onOpenNotification);

    // 冷启动时若已登录，补一次别名绑定
    final UserInfoData info = UserService.to.userInfoData.value;
    if (UserService.to.isLogin.value && info.uid != null) {
      bindAlias(info.uid!);
    }
  }

  /// 绑定用户别名：服务端可按别名推送，退出登录时解除
  Future<void> bindAlias(int uid) => _provider.bindAlias('$uid');

  Future<void> unbindAlias() => _provider.unbindAlias();

  /// 点击通知默认进入消息列表，业务可按 message['extras'] 自定义跳转
  Future<void> _onOpenNotification(Map<String, dynamic> message) async {
    if (Get.context == null) return;

    RouterManager.pushNamed(Routers.message);
  }
}
