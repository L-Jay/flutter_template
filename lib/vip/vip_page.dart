import '../common/common.dart';
import 'vip_controller.dart';

class VipPage extends GetView<VipController> {
  const VipPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => VipController());

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.vipTitle)),
      body: Obx(() {
        final VipInfo? info = controller.info.value;
        if (info == null) return const PageStateView();

        final AppColors colors = context.colors;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            _buildHeader(context, info),
            const SizedBox(height: AppSpacing.xl),
            Text(context.l10n.vipBenefits, style: AppTextStyle.title(colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            _buildBenefits(context, info),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              title: context.l10n.vipJoin(_priceText(info.price)),
              onPressed: controller.openVip,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, VipInfo info) {
    final AppColors colors = context.colors;
    final double progress = info.nextGrowth <= 0
        ? 0
        : (info.growth / info.nextGrowth).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.brand, colors.brandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  info.level,
                  style: AppTextStyle.small(Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  info.levelName,
                  style: AppTextStyle.headline(Colors.white),
                ),
              ),
              Text(
                context.l10n.vipPoints(info.points),
                style: AppTextStyle.caption(Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.vipGrowth(info.growth, info.nextGrowth),
            style: AppTextStyle.small(Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.validUntil(info.expireDate),
            style: AppTextStyle.small(Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(BuildContext context, VipInfo info) {
    final AppColors colors = context.colors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: info.benefits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final VipBenefit benefit = info.benefits[index];

        return AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.brandLight,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Icon(
                  _benefitIcon(benefit.icon),
                  size: 20,
                  color: colors.brand,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                benefit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.caption(colors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                benefit.desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.small(colors.textHint),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _benefitIcon(String name) {
    switch (name) {
      case 'discount':
        return Icons.local_offer_outlined;
      case 'coupon':
        return Icons.confirmation_number_outlined;
      case 'freight':
        return Icons.local_shipping_outlined;
      case 'service':
        return Icons.support_agent_rounded;
      case 'points':
        return Icons.stars_outlined;
      case 'gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  String _priceText(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
