import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../models/product_models.dart';
import '../l10n_ext.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';
import 'app_card.dart';

/// 商品网格卡片：商品列表、搜索结果等网格场景统一使用。
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: LJNetworkImage(
                url: product.cover,
                radius: AppSpacing.radiusSm,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.body(colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${product.price.toStringAsFixed(2)}',
                style: AppTextStyle.headline(colors.price),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '¥${product.originPrice.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.small(colors.textHint).copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.salesCount(product.sales),
            style: AppTextStyle.small(colors.textHint),
          ),
        ],
      ),
    );
  }
}
