import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lj_flutter_package/utils/lj_wechat_util.dart';

import '../constants.dart';
import '../l10n_ext.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import '../theme/app_spacing.dart';

/// 分享选项
enum ShareChannel {
  wechat(Icons.chat_bubble_rounded),
  moments(Icons.photo_camera_rounded),
  weibo(Icons.public_rounded),
  qq(Icons.chat_rounded),
  copyLink(Icons.link_rounded);

  const ShareChannel(this.icon);

  final IconData icon;

  String label(BuildContext context) {
    switch (this) {
      case ShareChannel.wechat:
        return context.l10n.shareWechat;
      case ShareChannel.moments:
        return context.l10n.shareMoments;
      case ShareChannel.weibo:
        return context.l10n.shareWeibo;
      case ShareChannel.qq:
        return context.l10n.shareQQ;
      case ShareChannel.copyLink:
        return context.l10n.shareCopyLink;
    }
  }

  /// 渠道品牌色（随主题取色，避免裸 Color 值）
  Color color(AppColors colors) {
    switch (this) {
      case ShareChannel.wechat:
        return colors.wechat;
      case ShareChannel.moments:
        return colors.wechat;
      case ShareChannel.weibo:
        return colors.weibo;
      case ShareChannel.qq:
        return colors.qq;
      case ShareChannel.copyLink:
        return colors.brand;
    }
  }
}

/// 底部分享弹窗：微信、朋友圈、微博、QQ、复制链接等主流选项。
///
/// 微信/朋友圈在开启 [ENABLE_REAL_THIRD_PARTY] 后调用 `WechatUtil` 分享，
/// 其余渠道与未开启时按 Mock 处理。
///
/// ```dart
/// await ShareSheet.show(title: '标题', url: 'https://example.com/x');
/// ```
class ShareSheet {
  static const String _tag = 'shareSheet';

  static Future<void> show({
    required String title,
    required String url,
  }) {
    return SmartDialog.show(
      tag: _tag,
      alignment: Alignment.bottomCenter,
      clickMaskDismiss: true,
      builder: (_) => _ShareSheetView(title: title, url: url),
    );
  }

  static Future<void> dismiss() => SmartDialog.dismiss(tag: _tag);
}

class _ShareSheetView extends StatelessWidget {
  const _ShareSheetView({required this.title, required this.url});

  final String title;
  final String url;

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
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(context.l10n.shareTo, style: AppTextStyle.headline(colors.textPrimary)),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => SmartDialog.dismiss(tag: 'shareSheet'),
                      child: Icon(Icons.close_rounded, color: colors.textHint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ShareChannel.values
                    .map((channel) => _buildChannelItem(context, channel))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.page),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelItem(BuildContext context, ShareChannel channel) {
    final AppColors colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleChannel(context, channel),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: channel.color(colors),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(channel.icon, size: 24, color: colors.surface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            channel.label(context),
            style: AppTextStyle.caption(colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChannel(BuildContext context, ShareChannel channel) async {
    SmartDialog.dismiss(tag: 'shareSheet');

    switch (channel) {
      case ShareChannel.copyLink:
        Clipboard.setData(ClipboardData(text: '$title\n$url'));
        EasyLoading.showSuccess(context.l10n.linkCopied);
        return;
      case ShareChannel.wechat:
        await _shareToWechat(context, timeline: false);
        return;
      case ShareChannel.moments:
        await _shareToWechat(context, timeline: true);
        return;
      case ShareChannel.weibo:
        EasyLoading.showSuccess(context.l10n.sharedToWeibo);
        return;
      case ShareChannel.qq:
        EasyLoading.showSuccess(context.l10n.sharedToQQ);
        return;
    }
  }

  /// 微信会话/朋友圈分享；未开启真实第三方或未安装微信时回退 Mock 提示
  Future<void> _shareToWechat(
    BuildContext context, {
    required bool timeline,
  }) async {
    final l10n = context.l10n;
    final String successTip =
        timeline ? l10n.sharedToMoments : l10n.sharedToWechat;

    if (!ENABLE_REAL_THIRD_PARTY) {
      EasyLoading.showSuccess(successTip);
      return;
    }

    try {
      if (!await WechatUtil.installed) {
        EasyLoading.showError(l10n.wechatNotInstalled);
        return;
      }
      await WechatUtil.shareWeb(
        url: url,
        title: title,
        session: !timeline,
      ).timeout(const Duration(seconds: 30));
      EasyLoading.showSuccess(successTip);
    } catch (_) {
      EasyLoading.showError(l10n.shareFailed);
    }
  }
}
