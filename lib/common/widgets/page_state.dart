import 'package:flutter/material.dart';

import '../l10n_ext.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';
import 'app_button.dart';

enum PageStateType { loading, empty, error }

/// 页面级状态占位：加载中 / 空数据 / 加载失败。
class PageStateView extends StatelessWidget {
  const PageStateView({
    super.key,
    this.type = PageStateType.loading,
    this.message = '',
    this.onRetry,
  });

  final PageStateType type;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    if (type == PageStateType.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.brand),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message.isEmpty ? context.l10n.loading : message,
              style: AppTextStyle.caption(colors.textSecondary),
            ),
          ],
        ),
      );
    }

    final bool isEmpty = type == PageStateType.empty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEmpty ? Icons.inbox_outlined : Icons.error_outline,
              size: 48,
              color: colors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message.isNotEmpty
                  ? message
                  : (isEmpty ? context.l10n.empty : context.l10n.loadFailed),
              textAlign: TextAlign.center,
              style: AppTextStyle.body(colors.textSecondary),
            ),
            if (!isEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                title: context.l10n.retry,
                width: 120,
                height: 40,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
