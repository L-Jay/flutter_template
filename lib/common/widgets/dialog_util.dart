import '../common.dart';

extension DialogUtil on DialogBase {
  static void show({
    String? title,
    required Widget contentWidget,
    String? cancelTitle,
    VoidCallback? cancelCallback,
    String? confirmTitle,
    VoidCallback? confirmCallback,
  }) {
    SmartDialog.show(
      tag: 'show',
      alignment: Alignment.center,
      clickMaskDismiss: false,
      builder: (context) {
        return DialogBase(
          title: title ?? context.l10n.tip,
          contentWidget: contentWidget,
          cancelTitle: cancelTitle ?? context.l10n.cancel,
          cancelCallback: cancelCallback,
          confirmTitle: confirmTitle ?? context.l10n.confirm,
          confirmCallback: confirmCallback,
        );
      },
    );
  }

  static void normal({
    String? title,
    required String text,
    String? cancelTitle,
    VoidCallback? cancelCallback,
    String? confirmTitle,
    VoidCallback? confirmCallback,
  }) {
    SmartDialog.show(
      tag: 'normal',
      alignment: Alignment.center,
      clickMaskDismiss: false,
      builder: (context) {
        return DialogBase(
          title: title ?? context.l10n.tip,
          contentWidget: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context.colors.textSecondary),
          ),
          cancelTitle: cancelTitle ?? context.l10n.cancel,
          cancelCallback: cancelCallback,
          confirmTitle: confirmTitle ?? context.l10n.confirm,
          confirmCallback: confirmCallback,
        );
      },
    );
  }

  static void text({
    String? title,
    required String text,
  }) {
    SmartDialog.show(
      alignment: Alignment.center,
      clickMaskDismiss: false,
      builder: (context) {
        return DialogBase(
          title: title ?? context.l10n.tip,
          contentWidget: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context.colors.textSecondary),
          ),
          cancelTitle: null,
          confirmTitle: null,
        );
      },
    );
  }

  static void singleButton({
    String? title,
    required String text,
    String? confirmTitle,
    VoidCallback? confirmCallback,
  }) {
    SmartDialog.show(
      alignment: Alignment.center,
      clickMaskDismiss: false,
      builder: (context) {
        return DialogBase(
          title: title ?? context.l10n.tip,
          contentWidget: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context.colors.textSecondary),
          ),
          cancelTitle: null,
          confirmTitle: confirmTitle ?? context.l10n.confirm,
          confirmCallback: confirmCallback,
        );
      },
    );
  }
}
