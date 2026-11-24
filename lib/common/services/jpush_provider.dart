import 'package:flutter/foundation.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

import '../common.dart';

/// 极光 JPush 实现。
///
/// [JPUSH_APP_KEY] 为空时自动跳过初始化，模板可正常运行。
class JPushProvider implements PushProvider {
  final JPushFlutterInterface _jpush = JPush.newJPush();

  @override
  String? registrationId;

  @override
  bool get enabled => JPUSH_APP_KEY.isNotEmpty;

  @override
  Future<void> init({
    required Future<dynamic> Function(Map<String, dynamic> message) onNotificationTap,
  }) async {
    try {
      _jpush.setup(
        appKey: JPUSH_APP_KEY,
        channel: JPUSH_CHANNEL,
        production: !kDebugMode,
        debug: kDebugMode,
      );

      if (isIOS) {
        _jpush.applyPushAuthority(
          const NotificationSettingsIOS(sound: true, alert: true, badge: true),
        );
      }
      _jpush.addEventHandler(onOpenNotification: onNotificationTap);

      registrationId = await _jpush.getRegistrationID();
    } catch (e) {
      debugPrint('JPush init failed: $e');
    }
  }

  @override
  Future<void> bindAlias(String alias) async {
    if (!enabled) return;
    try {
      await _jpush.setAlias(alias);
    } catch (e) {
      debugPrint('JPush setAlias failed: $e');
    }
  }

  @override
  Future<void> unbindAlias() async {
    if (!enabled) return;
    try {
      await _jpush.deleteAlias();
    } catch (e) {
      debugPrint('JPush deleteAlias failed: $e');
    }
  }
}
