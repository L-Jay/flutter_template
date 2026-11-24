import '../common/common.dart';
import 'feed_detail_controller.dart';

class FeedDetailPage extends GetView<FeedDetailController> {
  const FeedDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => FeedDetailController());

    final Map<String, dynamic> arguments = context.argumentMap ?? {};
    controller.init(arguments['id']?.toString());

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.detailTitle)),
      body: Obx(() {
        final FeedItem? item = controller.feed.value;
        if (item == null) {
          return const PageStateView(type: PageStateType.loading);
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAuthor(context, item),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.content,
                      style: AppTextStyle.body(context.colors.textPrimary),
                    ),
                    if (item.cover.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      LJNetworkImage(
                        url: item.cover,
                        width: double.infinity,
                        height: 220,
                        radius: AppSpacing.radiusMd,
                        fit: BoxFit.cover,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _buildActions(context, item),
                    const SizedBox(height: AppSpacing.lg),
                    _buildComments(context),
                  ],
                ),
              ),
            ),
            _buildInputBar(context),
          ],
        );
      }),
    );
  }

  Widget _buildAuthor(BuildContext context, FeedItem item) {
    final AppColors colors = context.colors;

    return Row(
      children: [
        LJNetworkImage(
          url: item.avatar,
          width: 40,
          height: 40,
          radius: 20,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.author,
                style: AppTextStyle.body(colors.textPrimary).copyWith(
                  fontWeight: medium,
                ),
              ),
              const SizedBox(height: 2),
              Text(item.time, style: AppTextStyle.small(colors.textHint)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, FeedItem item) {
    final AppColors colors = context.colors;

    return Row(
      children: [
        _actionItem(
          context,
          icon: item.liked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: item.liked ? colors.danger : colors.textSecondary,
          label: '${item.likes}',
          onTap: controller.toggleLike,
        ),
        const SizedBox(width: AppSpacing.xl),
        _actionItem(
          context,
          icon: item.favorited
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          color: item.favorited ? colors.warning : colors.textSecondary,
          label: item.favorited ? context.l10n.feedFavorited : context.l10n.feedFavorite,
          onTap: controller.toggleFavorite,
        ),
        const SizedBox(width: AppSpacing.xl),
        _actionItem(
          context,
          icon: Icons.share_outlined,
          color: colors.textSecondary,
          label: context.l10n.share,
          onTap: controller.share,
        ),
      ],
    );
  }

  Widget _actionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyle.caption(color)),
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context) {
    final AppColors colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.comments,
              style: AppTextStyle.headline(colors.textPrimary),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.openComments,
              child: Text(
                context.l10n.viewAll,
                style: AppTextStyle.caption(colors.brand),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(() {
          if (controller.comments.isEmpty) {
            return Text(
              context.l10n.feedNoComments,
              style: AppTextStyle.caption(colors.textHint),
            );
          }

          return Column(
            children: controller.comments.map((comment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LJNetworkImage(
                      url: comment.avatar,
                      width: 28,
                      height: 28,
                      radius: 14,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.author,
                            style: AppTextStyle.caption(colors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comment.content,
                            style: AppTextStyle.body(colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final AppColors colors = context.colors;

    return BottomContainer(
      height: 64,
      color: colors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: TextField(
                controller: controller.inputController,
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyle.body(colors.textPrimary),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: context.l10n.feedCommentHint,
                  hintStyle: AppTextStyle.body(colors.textHint),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            title: context.l10n.send,
            width: 76,
            height: 40,
            onPressed: controller.sendComment,
          ),
        ],
      ),
    );
  }
}
