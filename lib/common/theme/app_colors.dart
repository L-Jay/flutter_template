import 'package:flutter/material.dart';

/// 全局颜色 token。
///
/// 通过 [ThemeExtension] 挂到 ThemeData 上，业务侧统一用
/// `context.colors.xxx` 取色，为后续主题切换预留能力。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brand;
  final Color brandLight;
  final Color brandDark;

  final Color bg;
  final Color surface;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  final Color divider;

  final Color success;
  final Color warning;
  final Color danger;
  final Color price;

  final Color barrier;

  /// 第三方支付/分享渠道品牌色
  final Color wechat;
  final Color alipay;
  final Color weibo;
  final Color qq;

  /// 卡片/浮层阴影色（含透明度）
  final Color shadow;

  const AppColors({
    required this.brand,
    required this.brandLight,
    required this.brandDark,
    required this.bg,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.success,
    required this.warning,
    required this.danger,
    required this.price,
    required this.barrier,
    required this.wechat,
    required this.alipay,
    required this.weibo,
    required this.qq,
    required this.shadow,
  });

  static const AppColors light = AppColors(
    brand: Color(0xFF2F6BFF),
    brandLight: Color(0xFFEAF1FF),
    brandDark: Color(0xFF1F4FD8),
    bg: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textHint: Color(0xFF9CA3AF),
    divider: Color(0xFFEEF1F6),
    success: Color(0xFF12B76A),
    warning: Color(0xFFF79009),
    danger: Color(0xFFF04438),
    price: Color(0xFFFF4D4F),
    barrier: Color(0x80000000),
    wechat: Color(0xFF07C160),
    alipay: Color(0xFF1677FF),
    weibo: Color(0xFFE6162D),
    qq: Color(0xFF12B7F5),
    shadow: Color(0x0A111827),
  );

  static const AppColors dark = AppColors(
    brand: Color(0xFF2F6BFF),
    brandLight: Color(0xFF1B2740),
    brandDark: Color(0xFF1F4FD8),
    bg: Color(0xFF0E1116),
    surface: Color(0xFF171B22),
    textPrimary: Color(0xFFF5F7FA),
    textSecondary: Color(0xFFA0A8B8),
    textHint: Color(0xFF6B7280),
    divider: Color(0xFF232A35),
    success: Color(0xFF12B76A),
    warning: Color(0xFFF79009),
    danger: Color(0xFFF04438),
    price: Color(0xFFFF4D4F),
    barrier: Color(0x80000000),
    wechat: Color(0xFF07C160),
    alipay: Color(0xFF1677FF),
    weibo: Color(0xFFE6162D),
    qq: Color(0xFF12B7F5),
    shadow: Color(0x33000000),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? light;
  }

  @override
  AppColors copyWith({
    Color? brand,
    Color? brandLight,
    Color? brandDark,
    Color? bg,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? success,
    Color? warning,
    Color? danger,
    Color? price,
    Color? barrier,
    Color? wechat,
    Color? alipay,
    Color? weibo,
    Color? qq,
    Color? shadow,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      brandLight: brandLight ?? this.brandLight,
      brandDark: brandDark ?? this.brandDark,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      price: price ?? this.price,
      barrier: barrier ?? this.barrier,
      wechat: wechat ?? this.wechat,
      alipay: alipay ?? this.alipay,
      weibo: weibo ?? this.weibo,
      qq: qq ?? this.qq,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandLight: Color.lerp(brandLight, other.brandLight, t)!,
      brandDark: Color.lerp(brandDark, other.brandDark, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      price: Color.lerp(price, other.price, t)!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
      wechat: Color.lerp(wechat, other.wechat, t)!,
      alipay: Color.lerp(alipay, other.alipay, t)!,
      weibo: Color.lerp(weibo, other.weibo, t)!,
      qq: Color.lerp(qq, other.qq, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}
