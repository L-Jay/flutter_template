import 'package:lj_flutter_package/utils/lj_wechat_util.dart';

import '../common/common.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  /// 是否同意协议
  final isAgreeCheck = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    codeController.dispose();
    super.onClose();
  }

  void toggleAgreeCheck() {
    isAgreeCheck.value = !isAgreeCheck.value;
  }

  /// 发送验证码；测试环境后端可能在 data 中回传验证码，有值则直接提示便于联调
  Future<bool> fetchCode() async {
    try {
      final dynamic response = await LJNetwork.post(
        ApiUrl.phoneCode,
        data: {'loginMobile': phoneController.text},
      );
      final dynamic code = response is Map ? response['data'] : null;
      EasyLoading.showSuccess(
        code == null || code.toString().isEmpty
            ? Get.l10n.codeSent
            : Get.l10n.codeSentWithCode(code.toString()),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 微信一键登录
  ///
  /// 演示环境直接走 Mock 接口；开启 [ENABLE_REAL_THIRD_PARTY] 后调用
  /// `WechatUtil.login()` 获取授权 code，再由后端换取 token。
  Future<void> loginByWechat() async {
    if (!ENABLE_REAL_THIRD_PARTY) {
      await _wechatLogin('mock_wechat_code');
      return;
    }

    try {
      if (!await WechatUtil.installed) {
        EasyLoading.showError(Get.l10n.wechatNotInstalled);
        return;
      }

      final Map<String, dynamic> auth = await WechatUtil.login();
      final String? code = auth['code'] as String?;
      if (code == null || code.isEmpty) {
        EasyLoading.showError(Get.l10n.wechatLoginFailed);
        return;
      }

      await _wechatLogin(code);
    } catch (_) {
      EasyLoading.showError(Get.l10n.wechatLoginFailed);
    }
  }

  Future<void> _wechatLogin(String code) async {
    try {
      final data = await LJNetwork.post(
        ApiUrl.wechatLogin,
        data: {'code': code},
      );
      UserService.to.token = data['data']['token'];
      RouterManager.pop(true);
    } catch (e) {
      // 错误提示已由 LJNetwork.handleAllFailureCallBack 全局处理
    }
  }

  /// 登录
  Future<void> doLogin() async {
    if (!isAgreeCheck.value) {
      EasyLoading.showError(Get.l10n.agreeRequired);
      return;
    }
    if (!phoneController.text.verifyPhone()) {
      EasyLoading.showError(Get.l10n.invalidMobile);
      return;
    }
    if (codeController.text.length < 4) {
      EasyLoading.showError(Get.l10n.invalidCode);
      return;
    }

    try {
      final data = await LJNetwork.post(
        ApiUrl.mobileLogin,
        data: {'phone': phoneController.text, 'code': codeController.text},
      );
      UserService.to.token = data['data']['token'];
      RouterManager.pop(true);
    } catch (e) {
      // 错误提示已由 LJNetwork.handleAllFailureCallBack 全局处理
    }
  }
}
