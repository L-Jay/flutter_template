/// 推送厂商适配接口。
///
/// 模板默认使用极光（[JPushProvider]）。接入其他厂商时：
/// 1. 新增 `XxxProvider implements PushProvider`
/// 2. 在 [PushService] 中把工厂方法改为返回新实现
///
/// 业务层只依赖 [PushService] 的 `bindAlias / unbindAlias`，无需改动页面。
abstract class PushProvider {
  /// 是否配置了厂商密钥；为 false 时 [PushService] 跳过初始化
  bool get enabled;

  /// 设备注册 ID，可用于服务端定向推送
  String? get registrationId;

  /// 初始化 SDK，并在用户点击通知时回调业务
  Future<void> init({
    required Future<dynamic> Function(Map<String, dynamic> message) onNotificationTap,
  });

  /// 绑定用户别名，服务端可按别名推送
  Future<void> bindAlias(String alias);

  /// 解除用户别名
  Future<void> unbindAlias();
}
