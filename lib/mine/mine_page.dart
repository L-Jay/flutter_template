import '../common/common.dart';
import 'mine_controller.dart';

class MinePage extends GetView<MineController> {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MineController());

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabMine)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          _buildUserCard(context),
          const SizedBox(height: AppSpacing.md),
          _buildOrderCard(context),
          const SizedBox(height: AppSpacing.md),
          _buildFunctionCard(context),
          const SizedBox(height: AppSpacing.xl),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    final AppColors colors = context.colors;

    return Obx(() {
      final bool isLogin = UserService.to.isLogin.value;
      final UserInfoData userInfo = UserService.to.userInfoData.value;

      return AppCard(
        onTap: controller.openProfile,
        child: Row(
          children: [
            AvatarWidget(
              size: 56,
              imageUrl: userInfo.avatar ?? '',
              borderWidth: 0,
              showCamera: isLogin,
              crop: true,
              pickFinish: controller.updateAvatar,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLogin
                        ? (userInfo.nickname ?? context.l10n.mineGuestName)
                        : context.l10n.mineTapLogin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.title(colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isLogin
                        ? (userInfo.mobile ?? '')
                        : context.l10n.mineLoginHint,
                    style: AppTextStyle.caption(colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textHint,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOrderCard(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                context.l10n.myOrders,
                style: AppTextStyle.headline(colors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.openOrder(),
                child: Row(
                  children: [
                    Text(
                      context.l10n.all,
                      style: AppTextStyle.caption(colors.textSecondary),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.textHint,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: controller.orderEntries.map((entry) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.openOrder(entry['status']!),
                child: Column(
                  children: [
                    Icon(
                      _orderIcon(entry['icon']!),
                      size: 26,
                      color: colors.brand,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _orderStatusLabel(context, entry['status']!),
                      style: AppTextStyle.caption(colors.textSecondary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCard(BuildContext context) {
    final List<Map<String, dynamic>> entries = [
      {'icon': Icons.notifications_none_rounded, 'title': context.l10n.messageCenter, 'onTap': controller.openMessage},
      {'icon': Icons.favorite_border_rounded, 'title': context.l10n.myFavorites, 'onTap': controller.openFavorites},
      {'icon': Icons.shopping_cart_outlined, 'title': context.l10n.cartTitle, 'onTap': controller.openCart},
      {'icon': Icons.info_outline_rounded, 'title': context.l10n.aboutUs, 'onTap': controller.openAbout},
      {'icon': Icons.settings_outlined, 'title': context.l10n.settingsTitle, 'onTap': controller.openSetting},
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            _buildFunctionRow(context, entries[i]),
            if (i != entries.length - 1)
              const Divider(height: 1, indent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildFunctionRow(BuildContext context, Map<String, dynamic> entry) {
    final AppColors colors = context.colors;

    return InkWell(
      onTap: entry['onTap'] as VoidCallback,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            Icon(
              entry['icon'] as IconData,
              size: 20,
              color: colors.brand,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                entry['title'] as String,
                style: AppTextStyle.body(colors.textPrimary),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.textHint,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Obx(() {
      if (!UserService.to.isLogin.value) return const SizedBox();

      return AppButton(
        title: context.l10n.logout,
        type: AppButtonType.secondary,
        height: 44,
        onPressed: controller.logout,
      );
    });
  }

  String _orderStatusLabel(BuildContext context, String status) {
    switch (status) {
      case 'pay':
        return context.l10n.orderStatusPending;
      case 'send':
        return context.l10n.orderStatusToShip;
      case 'receive':
        return context.l10n.orderStatusToReceive;
      case 'done':
        return context.l10n.orderStatusDone;
      default:
        return context.l10n.all;
    }
  }

  IconData _orderIcon(String name) {
    switch (name) {
      case 'pay':
        return Icons.account_balance_wallet_outlined;
      case 'send':
        return Icons.inventory_2_outlined;
      case 'receive':
        return Icons.local_shipping_outlined;
      case 'done':
        return Icons.task_alt_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}
