import '../common/common.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.aboutUs)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.brand,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Icon(
                Icons.mobile_friendly_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              LJUtil.packageInfo.appName,
              style: AppTextStyle.title(colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.versionText(LJUtil.packageInfo.version),
              style: AppTextStyle.caption(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.aboutUs,
                    style: AppTextStyle.headline(colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.aboutUsDesc,
                    style: AppTextStyle.body(colors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '© 2026 LJ Template',
              style: AppTextStyle.small(colors.textHint),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
