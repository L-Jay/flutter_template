import 'package:lj_flutter_package/utils/lj_wechat_util.dart';

import '../common/common.dart';

class ProfileController extends GetxController {
  static const String _wechatBoundKey = 'wechatBound';

  final wechatBound = false.obs;

  final nicknameController = TextEditingController();
  final mobileController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    wechatBound.value = LJUtil.preferences.getBool(_wechatBoundKey) ?? false;
  }

  @override
  void onClose() {
    nicknameController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  // ---------- 头像 ----------

  /// 相机/相册选图后更新头像（AvatarWidget 回调）
  Future<void> updateAvatar(String? localPath) {
    return UserService.to.updateAvatar(localPath);
  }

  // ---------- 昵称 ----------

  Future<void> saveNickname() async {
    final String text = nicknameController.text.trim();
    if (text.isEmpty) {
      EasyLoading.showToast(Get.l10n.nicknameEmpty);
      return;
    }

    await LJNetwork.post(ApiUrl.userUpdate, data: {'nickname': text});

    _updateUserInfo((info) => info.nickname = text);
    EasyLoading.showSuccess(Get.l10n.nicknameUpdated);
  }

  // ---------- 手机号 ----------

  Future<void> saveMobile() async {
    final String text = mobileController.text.trim();
    if (!RegExp(r'^1\d{10}$').hasMatch(text)) {
      EasyLoading.showToast(Get.l10n.invalidMobile);
      return;
    }

    await LJNetwork.post(ApiUrl.userUpdate, data: {'mobile': text});

    _updateUserInfo((info) => info.mobile = text);
    EasyLoading.showSuccess(Get.l10n.mobileUpdated);
  }

  // ---------- 微信绑定 ----------

  void toggleWechat() {
    if (wechatBound.value) {
      EasyLoading.showInfo(Get.l10n.wechatAlreadyBound);
      return;
    }

    DialogUtil.normal(
      text: Get.l10n.wechatBindTip,
      confirmTitle: Get.l10n.bindWechat,
      confirmCallback: bindWechat,
    );
  }

  Future<void> bindWechat() async {
    String? code;

    // 开启真实第三方后先走微信授权拿 code，未开启则保持 Mock 流程
    if (ENABLE_REAL_THIRD_PARTY) {
      try {
        if (!await WechatUtil.installed) {
          EasyLoading.showError(Get.l10n.wechatNotInstalled);
          return;
        }
        final Map<String, dynamic> auth = await WechatUtil.login();
        code = auth['code'] as String?;
      } catch (_) {
        EasyLoading.showError(Get.l10n.wechatLoginFailed);
        return;
      }

      if (code == null || code.isEmpty) {
        EasyLoading.showError(Get.l10n.wechatLoginFailed);
        return;
      }
    }

    await LJNetwork.post(
      ApiUrl.bindWechat,
      data: {if (code != null) 'code': code},
    );

    wechatBound.value = true;
    LJUtil.preferences.setBool(_wechatBoundKey, true);
    EasyLoading.showSuccess(Get.l10n.wechatBindSuccess);
  }

  /// 手机号脱敏展示
  String maskedMobile(String? mobile) {
    if (mobile == null || mobile.length != 11) return mobile ?? '';

    return '${mobile.substring(0, 3)}****${mobile.substring(7)}';
  }

  /// 本地即时更新用户信息（mock 下服务端不落库，页面直接刷新）
  void _updateUserInfo(void Function(UserInfoData info) updater) {
    final UserInfoData info = UserService.to.userInfoData.value;
    updater(info);
    UserService.to.userInfoData.refresh();
  }
}
