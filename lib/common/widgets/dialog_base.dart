import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'app_button.dart';

class DialogBase extends StatefulWidget {
  final String title;
  final Widget contentWidget;
  final bool showClose;

  final String? cancelTitle;
  final VoidCallback? cancelCallback;

  final String? confirmTitle;
  final VoidCallback? confirmCallback;

  ///点击确认是否响应dismiss,默认响应
  final bool confirmDismiss;

  const DialogBase({
    super.key,
    required this.title,
    required this.contentWidget,
    this.showClose = true,

    this.cancelTitle,
    this.cancelCallback,

    this.confirmTitle,
    this.confirmCallback,

    ///点击确认是否响应dismiss,默认响应
    this.confirmDismiss = true,
  });

  @override
  State<DialogBase> createState() => _DialogBaseState();
}

class _DialogBaseState extends State<DialogBase> {
  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    bool hasButton =
        widget.cancelTitle?.isNotEmpty == true ||
        widget.confirmTitle?.isNotEmpty == true;

    return Container(
      width: 320,
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: Get.mediaQuery.size.height - 200,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(child: widget.contentWidget),
              ),
            ),
            if (hasButton) _buildBottomButton(),
            if (!hasButton) const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final AppColors colors = context.colors;

    return Stack(
      children: [
        Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(widget.title, style: AppTextStyle.headline(colors.textPrimary)),
        ),
        if (widget.showClose)
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () => SmartDialog.dismiss(),
              icon: Icon(Icons.close, color: colors.textHint),
            ),
          ),
      ],
    );
  }

  Padding _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.confirmTitle?.isNotEmpty == true)
            AppButton(
              width: 140,
              height: 40,
              type: AppButtonType.secondary,
              title: widget.confirmTitle!,
              onPressed: () {
                if (widget.confirmDismiss) {
                  SmartDialog.dismiss();
                }
                widget.confirmCallback?.call();
              },
            ),
          if (widget.cancelTitle?.isNotEmpty == true &&
              widget.confirmTitle?.isNotEmpty == true)
            const Spacer(),
          if (widget.cancelTitle?.isNotEmpty == true)
            AppButton(
              width: 140,
              height: 40,
              title: widget.cancelTitle!,
              onPressed: () {
                SmartDialog.dismiss();
                widget.cancelCallback?.call();
              },
            ),
        ],
      ),
    );
  }
}
