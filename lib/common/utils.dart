import 'dart:async';
import 'dart:ui';

/// 节流
VoidCallback throttle(
  VoidCallback callback, [
  Duration duration = const Duration(seconds: 1),
]) {
  assert(duration > Duration.zero);
  Timer? throttle;
  return () {
    if (throttle?.isActive == true) {
      return;
    }
    callback.call();
    throttle = Timer(duration, () {});
  };
}

/// 从接口响应中取出 `data` 列表并转换为模型。
List<T> parseList<T>(
  dynamic response,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final dynamic data = response is Map ? response['data'] : null;
  if (data is! List) return [];

  return data
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

/// 从接口响应中取出 `data` 对象。
Map<String, dynamic>? parseDataMap(dynamic response) {
  final dynamic data = response is Map ? response['data'] : null;
  return data is Map ? Map<String, dynamic>.from(data) : null;
}
