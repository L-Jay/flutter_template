import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lj_flutter_package/debug/lj_debug_config.dart';
import 'package:lj_flutter_package/utils/lj_wechat_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';

import 'common/common.dart';
import 'common/mock/mock_config.dart';
import 'generated/json/base/json_convert_content.dart';

class Bootstrap {
  /// EasyLoading.init() 在 MaterialApp build 时才挂载 overlay，
  /// 首帧前调用 show/showError 会触发 'overlayEntry != null' 断言。
  /// 用 overlayEntry 是否存在判断能否弹提示，替代手动的 uiReady 标记。
  static bool get loadingReady => EasyLoading.instance.overlayEntry != null;

  static Future<void> setup() async {
    _configCrashReport();
    _configThirdParty();
    await LJUtil.initInstance();
    await _configNetwork();
    _configRouter();
    _configLoading();
    _configServices();
    if (!kIsWeb) _configDebug();

    LJNetworkImage.defaultPlaceholderWidget = const SizedBox();
    LJNetworkImage.defaultErrorWidget = const SizedBox();
  }

  /// 全局异常捕获挂点：接崩溃上报 SDK 时，在两个回调里调用 SDK 的上报方法即可
  static void _configCrashReport() {
    // 捕获 Flutter 框架异常（build/layout/paint 等）
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      // TODO: 接入崩溃上报 SDK，如 bugly.reportError(details.exception, details.stack)
    };

    // 捕获异步未处理异常
    PlatformDispatcher.instance.onError = (error, stack) {
      // TODO: 接入崩溃上报 SDK
      return false; // 返回 false 交回系统默认处理，日志仍会打印
    };
  }

  static void _configThirdParty() {
    if (kIsWeb) return;
    WechatUtil.register(
      appId: WECHAT_APP_ID,
      universalLink: universal_link,
      check: false,
      errorCallback: (LJError error) {
        EasyLoading.showError(error.errorMessage);
      },
    );
  }

  static void _configDebug() {
    final String? savedCode = LanguageService.to.locale.value?.languageCode;
    final String code =
        (savedCode ?? Get.deviceLocale?.languageCode) == 'en' ? 'en' : 'zh';
    LJDebugConfig.configList = [
      {
        'title': lookupAppLocalizations(Locale(code)).envProduction,
        'baseUrl': ApiUrl.baseUrl,
      },
    ];

    LJDebugConfig.serviceChangeCallback = (map) async {
      ApiUrl.baseUrl = map['baseUrl'] ?? '';
      LJNetwork.baseUrl = ApiUrl.baseUrl;

      // 切换环境重新登录
      if (UserService.to.isLogin.value) {
        UserService.to.logout();
      }
    };
  }

  static Future<void> _configNetwork() async {
    LJNetwork.baseUrl = ApiUrl.baseUrl;
    LJNetwork.codeKey = 'code';
    LJNetwork.successCode = 200;
    LJNetwork.messageKey = 'message';
    LJNetwork.headers.addAll({
      'source': kIsWeb ? 'WEB' : (GetPlatform.isAndroid ? 'ANDROID' : 'IOS'),
      'version': LJUtil.packageInfo.version,
      'build': LJUtil.packageInfo.buildNumber,
    });

    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await LJUtil.deviceInfo.webBrowserInfo;

      LJNetwork.headers.addAll({
        'systemVersion': webBrowserInfo.userAgent ?? '',
        'systemName': webBrowserInfo.browserName.name,
        'device': webBrowserInfo.userAgent ?? '',
      });
    } else if (GetPlatform.isAndroid) {
      Map<String, String> androidInfo = {
        'systemVersion': LJUtil.androidDeviceInfo.version.baseOS ?? "",
        'systemName': LJUtil.androidDeviceInfo.brand,
        'deviceId': LJUtil.androidDeviceInfo.id,
        'device': LJUtil.androidDeviceInfo.model,
      };
      LJNetwork.headers.addAll(androidInfo);
    } else if (GetPlatform.isIOS) {
      Map<String, String> iosInfo = {
        'systemVersion': LJUtil.iosDeviceInfo.systemVersion,
        'systemName': LJUtil.iosDeviceInfo.systemName,
        'deviceId': LJUtil.iosDeviceInfo.identifierForVendor ?? "",
        'device': LJUtil.iosDeviceInfo.utsname.machine,
      };
      LJNetwork.headers.addAll(iosInfo);
    }

    // json解析
    LJNetwork.jsonParse = <T>(data) {
      return JsonConvert.fromJsonAsT<T>(data) as T;
    };

    // 请求不再全局弹 loading：页面用 PageStateView / 骨架屏表达加载状态，
    // 拦截器只负责参数清洗与签名
    LJNetwork.handleRequestParams =
        (String path, Map<String, dynamic>? requestParams) {
          var params = <String, dynamic>{};
          if (requestParams?.isNotEmpty == true) {
            requestParams!.removeWhere((key, value) => value == null);
            params.addAll(requestParams);
          }
          var timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          params.addAll({'timestamp': timestamp});

          return _signParams(params);
        };

    // 拦截所有报错
    LJNetwork.handleAllFailureCallBack = (error) async {
      // 登录过期：先用 refresh_token 续期，失败再退出登录
      if (error.errorCode == 200112 && UserService.to.isLogin.value) {
        bool refreshed = await UserService.to.refreshToken();
        if (!refreshed) UserService.to.logout();
        return;
      }

      if (loadingReady) {
        EasyLoading.showError(error.errorMessage);
      }
    };

    await _configMock();
  }

  /// 统一注册 mock：全部实现在 MockConfig 中，非 debug 环境内部直接跳过
  static Future<void> _configMock() => MockConfig.setup();

  static Map<String, dynamic> _signParams(Map<String, dynamic> params) {
    List<String> sortedKeys = params.keys.toList()..sort();
    var list = ['sign_key=ABCDEFG'];
    for (var key in sortedKeys) {
      var value = params[key];
      if (value is List || value is Map) {
        list.add('$key=');
      } else {
        list.add('$key=$value');
      }
    }

    var string = list.join('&');
    var urlEncode = Uri.encodeComponent(string);
    var digest = md5.convert(utf8.encode(urlEncode));
    var sign = digest.toString().toUpperCase();
    params.addAll({"sign": sign});

    return params;
  }

  static void _configServices() {
    Get.put(ConfigService());
    Get.put(ThemeService());
    Get.put(LanguageService());
    // PushService 需先于 UserService 注册，用户信息拉取后可直接绑定推送别名
    Get.put(PushService());
    Get.put(UserService());
    Get.put(CartService());
  }

  static void _configRouter() {
    RouterManager.routerType = RouterType.get;
    RouterManager.rootPageName = Routers.splash;
    RouterManager.routes = Routers.pages;
    RouterManager.verifyLoginPageList = Routers.verifyLoginPageList;
    RouterManager.noAnimationPageList = [Routers.root];
    // fullscreen 页面：从底部弹出（登录页）
    RouterManager.fullscreenPageList = [Routers.login];
    RouterManager.loginPageName = Routers.login;
    RouterManager.getLoginStatus = () {
      return UserService.to.isLogin.value;
    };
    RouterManager.globalPopCallback = () {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
    };
  }

  static void _configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.light
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.black
      ..indicatorColor = Colors.black
      ..textColor = Colors.black
      ..maskColor = Colors.black54
      ..userInteractions = true
      ..dismissOnTap = false;
  }
}
