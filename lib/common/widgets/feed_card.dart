import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../models/home_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';
import 'app_card.dart';

/// 首页 / 内容 Tab 共用的内容卡片。
class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLike,
    this.showCover = true,
  });

  final FeedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool showCover;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LJNetworkImage(
                url: item.avatar,
                width: 36,
                height: 36,
                radius: AppSpacing.radiusPill,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.body(colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.time,
                      style: AppTextStyle.small(colors.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body(colors.textPrimary),
          ),
          if (showCover && item.cover.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            LJNetworkImage(
              url: item.cover,
              width: double.infinity,
              height: 180,
              radius: AppSpacing.radiusSm,
              fit: BoxFit.cover,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _action(
                context,
                icon: item.liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                text: '${item.likes}',
                active: item.liked,
                onTap: onLike,
              ),
              const SizedBox(width: AppSpacing.xl),
              _action(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                text: '${item.comments}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool active = false,
    VoidCallback? onTap,
  }) {
    final AppColors colors = context.colors;
    final Color color = active ? colors.price : colors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTextStyle.caption(color)),
        ],
      ),
    );
  }
}
