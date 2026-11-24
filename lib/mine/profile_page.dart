import 'package:flutter/services.dart';

import '../common/common.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ProfileController());

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _buildAvatarRow(context),
          const SizedBox(height: AppSpacing.md),
          _buildCard(
            context,
            rows: [
              _buildRow(
                context,
                title: context.l10n.nickname,
                builder: (colors) => Obx(() {
                  return Text(
                    UserService.to.userInfoData.value.nickname ?? context.l10n.notSet,
                    style: AppTextStyle.body(colors.textSecondary),
                  );
                }),
                onTap: () => _editNickname(context),
              ),
              _buildDivider(context),
              _buildRow(
                context,
                title: context.l10n.mobile,
                builder: (colors) => Obx(() {
                  return Text(
                    controller.maskedMobile(
                      UserService.to.userInfoData.value.mobile,
                    ),
                    style: AppTextStyle.body(colors.textSecondary),
                  );
                }),
                onTap: () => _changeMobile(context),
              ),
              _buildDivider(context),
              _buildRow(
                context,
                title: context.l10n.wechatAccount,
                builder: (colors) => Obx(() {
                  return Text(
                    controller.wechatBound.value ? context.l10n.bound : context.l10n.notBound,
                    style: AppTextStyle.body(
                      controller.wechatBound.value
                          ? colors.brand
                          : colors.textHint,
                    ),
                  );
                }),
                onTap: controller.toggleWechat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editNickname(BuildContext context) {
    controller.nicknameController.text =
        UserService.to.userInfoData.value.nickname ?? '';

    DialogUtil.show(
      title: context.l10n.editNickname,
      contentWidget: _buildInput(
        context,
        controller: controller.nicknameController,
        hint: context.l10n.nicknameHint,
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
      ),
      confirmTitle: context.l10n.save,
      confirmCallback: controller.saveNickname,
    );
  }

  void _changeMobile(BuildContext context) {
    controller.mobileController.clear();

    DialogUtil.show(
      title: context.l10n.changeMobile,
      contentWidget: _buildInput(
        context,
        controller: controller.mobileController,
        hint: context.l10n.newMobileHint,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
      ),
      confirmTitle: context.l10n.change,
      confirmCallback: controller.saveMobile,
    );
  }

  /// 弹窗内的输入框：上下等距内边距 + 垂直居中，避免默认 TextField 过矮/文字偏上
  Widget _buildInput(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: colors.divider),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlignVertical: TextAlignVertical.center,
        style: AppTextStyle.body(colors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          // 主题默认 filled，弹窗内需要去掉填充色，只保留外层描边
          filled: false,
          // 上下 13 的 contentPadding：输入框约 46 高，文字自然垂直居中
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyle.body(colors.textHint),
        ),
      ),
    );
  }

  Widget _buildAvatarRow(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.avatar,
              style: AppTextStyle.body(colors.textPrimary),
            ),
          ),
          Obx(() {
            return AvatarWidget(
              size: 52,
              imageUrl: UserService.to.userInfoData.value.avatar ?? '',
              borderWidth: 0,
              showCamera: true,
              crop: true,
              pickFinish: controller.updateAvatar,
            );
          }),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right_rounded, size: 18, color: colors.textHint),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required List<Widget> rows,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: rows),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String title,
    required Widget Function(AppColors colors) builder,
    required VoidCallback onTap,
  }) {
    final AppColors colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            Text(title, style: AppTextStyle.body(colors.textPrimary)),
            const Spacer(),
            builder(colors),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, size: 18, color: colors.textHint),
            const SizedBox(width: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return const Divider(height: 1, indent: AppSpacing.lg);
  }
}
