import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_style.dart';

enum AppButtonType { primary, secondary, text }

/// 全局统一按钮。
///
/// - [AppButtonType.primary]：品牌色实心
/// - [AppButtonType.secondary]：白底描边
/// - [AppButtonType.text]：纯文字
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.width = double.infinity,
    this.height = 48,
    this.loading = false,
    this.icon,
  });

  final String title;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final double width;
  final double height;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool disabled = onPressed == null || loading;

    Color background;
    Color foreground;
    Border? border;

    switch (type) {
      case AppButtonType.primary:
        background = colors.brand;
        foreground = Colors.white;
        border = null;
        break;
      case AppButtonType.secondary:
        background = colors.surface;
        foreground = colors.textPrimary;
        border = Border.all(color: colors.divider);
        break;
      case AppButtonType.text:
        background = Colors.transparent;
        foreground = colors.brand;
        border = null;
        break;
    }

    Widget child;
    if (loading) {
      child = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(title, style: AppTextStyle.button(foreground)),
        ],
      );
    } else {
      child = Text(title, style: AppTextStyle.button(foreground));
    }

    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: disabled ? null : onPressed,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: border,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
