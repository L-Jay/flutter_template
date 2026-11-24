import 'package:flutter_template/common/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('路由名统一以 / 开头', () {
    for (final name in Routers.pages.keys) {
      expect(name.startsWith('/'), isTrue, reason: '路由名不合法：$name');
    }
  });

  test('登录拦截配置的路由都已注册', () {
    for (final route in Routers.verifyLoginPageList) {
      expect(
        Routers.pages.containsKey(route),
        isTrue,
        reason: '$route 未注册到 Routers.pages',
      );
    }
  });
}
