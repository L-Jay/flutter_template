import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lj_flutter_package/utils/lj_alipay_util.dart';
import 'package:lj_flutter_package/utils/lj_wechat_util.dart';

import '../constants.dart';
import '../l10n_ext.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// 微信支付参数（由后端统一下单接口返回）
class WechatPayParams {
  const WechatPayParams({
    required this.appId,
    required this.partnerId,
    required this.prepayId,
    required this.packageValue,
    required this.nonceStr,
    required this.timestamp,
    required this.sign,
  });

  final String appId;
  final String partnerId;
  final String prepayId;
  final String packageValue;
  final String nonceStr;
  final int timestamp;
  final String sign;
}

/// 支付渠道
enum PayChannel {
  wechat(Icons.chat_bubble_rounded),
  alipay(Icons.account_balance_wallet_rounded);

  const PayChannel(this.icon);

  final IconData icon;

  String label(BuildContext context) {
    switch (this) {
      case PayChannel.wechat:
        return context.l10n.payWechat;
      case PayChannel.alipay:
        return context.l10n.payAlipay;
    }
  }

  /// 渠道品牌色（随主题取色，避免裸 Color 值）
  Color color(AppColors colors) {
    switch (this) {
      case PayChannel.wechat:
        return colors.wechat;
      case PayChannel.alipay:
        return colors.alipay;
    }
  }
}

/// 底部收银台弹窗：选择支付渠道后发起支付。
///
/// 默认模拟支付；传入真实参数并开启 [ENABLE_REAL_THIRD_PARTY] 后调用
/// `WechatUtil` / `AlipayUtil`。
///
/// ```dart
/// final bool paid = await PaySheet.show(amount: 99.9);
/// if (paid) { /* 支付成功后的订单逻辑 */ }
/// ```
class PaySheet {
  static const String _tag = 'paySheet';

  /// 弹出收银台；返回 true 表示支付成功。
  ///
  /// 传入 [wechat] / [alipayOrder] 且开启 [ENABLE_REAL_THIRD_PARTY] 时走真实
  /// 微信、支付宝 SDK，否则按 Mock 模拟支付（方便模板演示）。
  static Future<bool> show({
    required double amount,
    WechatPayParams? wechat,
    String? alipayOrder,
  }) async {
    final dynamic result = await SmartDialog.show<bool>(
      tag: _tag,
      alignment: Alignment.bottomCenter,
      clickMaskDismiss: false,
      builder: (_) => _PaySheetView(
        amount: amount,
        wechat: wechat,
        alipayOrder: alipayOrder,
      ),
    );
    return result == true;
  }

  static Future<void> dismiss() => SmartDialog.dismiss(tag: _tag);
}

class _PaySheetView extends StatefulWidget {
  const _PaySheetView({
    required this.amount,
    this.wechat,
    this.alipayOrder,
  });

  final double amount;
  final WechatPayParams? wechat;
  final String? alipayOrder;

  @override
  State<_PaySheetView> createState() => _PaySheetViewState();
}

class _PaySheetViewState extends State<_PaySheetView> {
  PayChannel _selected = PayChannel.wechat;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  '¥${widget.amount.toStringAsFixed(2)}',
                  style: AppTextStyle.display(colors.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (PayChannel channel in PayChannel.values) ...[
                _buildChannelRow(context, channel),
                if (channel != PayChannel.values.last)
                  const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                title: context.l10n.confirmPay,
                height: 46,
                onPressed: _pay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final AppColors colors = context.colors;

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(context.l10n.cashier, style: AppTextStyle.headline(colors.textPrimary)),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: () => SmartDialog.dismiss(tag: 'paySheet', result: false),
            child: Icon(Icons.close_rounded, color: colors.textHint),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelRow(BuildContext context, PayChannel channel) {
    final AppColors colors = context.colors;
    final bool selected = _selected == channel;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected = channel),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: selected ? colors.brand : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: channel.color(colors),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(channel.icon, size: 20, color: colors.surface),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                channel.label(context),
                style: AppTextStyle.body(colors.textPrimary),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? colors.brand : colors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  /// 真实支付参数齐全时调用微信/支付宝 SDK，否则模拟支付
  Future<void> _pay() async {
    final bool real = ENABLE_REAL_THIRD_PARTY &&
        (_selected == PayChannel.wechat
            ? widget.wechat != null
            : widget.alipayOrder != null);

    EasyLoading.show(status: context.l10n.paying);
    try {
      if (real) {
        await _payByChannel();
      } else {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    } catch (_) {
      EasyLoading.showError(context.l10n.payFailed);
      return;
    }
    EasyLoading.dismiss();

    SmartDialog.dismiss(tag: 'paySheet', result: true);
  }

  Future<void> _payByChannel() async {
    if (_selected == PayChannel.wechat) {
      final WechatPayParams params = widget.wechat!;
      if (!await WechatUtil.installed) throw Exception('wechat not installed');

      await WechatUtil.pay(
        appId: params.appId,
        partnerId: params.partnerId,
        prepayId: params.prepayId,
        packageValue: params.packageValue,
        nonceStr: params.nonceStr,
        timestamp: params.timestamp,
        sign: params.sign,
      ).timeout(const Duration(seconds: 60));
    } else {
      await AlipayUtil.pay(
        widget.alipayOrder!,
        debug: kDebugMode,
      ).timeout(const Duration(seconds: 60));
    }
  }
}
