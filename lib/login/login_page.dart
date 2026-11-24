import 'package:flutter/services.dart';
import 'package:lj_flutter_package/ui_component/lj_send_code_button.dart';

import '../common/common.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LoginController());

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.loginTitle),
        // fullscreen 底部弹出模式：左上角用关闭按钮替代返回箭头
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: RouterManager.pop,
          icon: Icon(Icons.close_rounded, color: context.colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _inputItem(
                context,
                title: context.l10n.mobile,
                fieldController: controller.phoneController,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 20),
              _inputItem(
                context,
                title: context.l10n.verifyCode,
                fieldController: controller.codeController,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                trailing: SendCodeButton(
                  controller: controller.phoneController,
                  fontSize: 12,
                  isShowBorder: false,
                  disableColor: context.colors.textHint,
                  enableColor: context.colors.brand,
                  text: context.l10n.sendCode,
                  countdownText: (seconds) => context.l10n.resendIn(seconds),
                  sendCodeMethod: controller.fetchCode,
                ),
              ),
              const SizedBox(height: 36),
              _buildPrivacy(context),
              const SizedBox(height: 20),
              AppButton(
                title: context.l10n.loginTitle,
                height: 44,
                onPressed: controller.doLogin,
              ),
              const SizedBox(height: 12),
              AppButton(
                title: context.l10n.wechatLogin,
                type: AppButtonType.secondary,
                height: 44,
                icon: Icons.chat_bubble_rounded,
                onPressed: controller.loginByWechat,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacy(BuildContext context) {
    final AppColors colors = context.colors;

    return Row(
      children: [
        GestureDetector(
          onTap: controller.toggleAgreeCheck,
          child: Obx(
            () => Icon(
              controller.isAgreeCheck.value
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: controller.isAgreeCheck.value
                  ? colors.brand
                  : colors.textHint,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(context.l10n.agreePrefix, style: AppTextStyle.small(colors.textHint)),
              GestureDetector(
                onTap: () => RouterManager.pushNamed(
                  Routers.webview,
                  arguments: {
                    'url': 'https://www.baidu.com',
                    'title': context.l10n.userServiceAgreement,
                  },
                ),
                child: Text(
                  context.l10n.userServiceAgreement,
                  style: AppTextStyle.small(colors.textSecondary),
                ),
              ),
              Text(context.l10n.andWord, style: AppTextStyle.small(colors.textHint)),
              GestureDetector(
                onTap: () => RouterManager.pushNamed(
                  Routers.webview,
                  arguments: {
                    'url': 'https://www.baidu.com',
                    'title': context.l10n.privacyTerms,
                  },
                ),
                child: Text(
                  context.l10n.privacyTerms,
                  style: AppTextStyle.small(colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputItem(
    BuildContext context, {
    required String title,
    required TextEditingController fieldController,
    List<TextInputFormatter> formatters = const [],
    Widget? trailing,
  }) {
    final AppColors colors = context.colors;

    return Container(
      height: 46.5,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    title,
                    style: AppTextStyle.body(colors.textPrimary),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: TextField(
                      controller: fieldController,
                      inputFormatters: formatters,
                      keyboardType: TextInputType.text,
                      enableInteractiveSelection: false,
                      style: AppTextStyle.body(colors.textPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minHeight: 0),
                        hintStyle: AppTextStyle.body(colors.textHint),
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
