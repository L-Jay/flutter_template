import '../common/common.dart';

/// 通用详情页：通过路由参数渲染静态内容
class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Map<String, dynamic> arguments = context.argumentMap ?? {};
    final String title = arguments['title']?.toString() ?? context.l10n.detailTitle;
    final String cover = arguments['cover']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [
          if (cover.isNotEmpty)
            LJNetworkImage(
              url: cover,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.title(colors.textPrimary)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.detailSampleContent(title),
                  style: AppTextStyle.body(colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.detailSampleDesc,
                  style: AppTextStyle.body(colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
