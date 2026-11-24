import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../l10n_ext.dart';
import '../widgets/dialog_util.dart';

/// 权限申请封装：统一拒绝提示。
class PermissionUtil {
  static Future<bool> camera() async {
    return _request(
      LJPermissionUtils.checkCamera,
      (context) => context.l10n.permCamera,
    );
  }

  static Future<bool> photos() async {
    return _request(
      LJPermissionUtils.checkPhotos,
      (context) => context.l10n.permPhotos,
    );
  }

  static Future<bool> microphone() async {
    return _request(
      LJPermissionUtils.checkMicrophone,
      (context) => context.l10n.permMicrophone,
    );
  }

  static Future<bool> storage() async {
    return _request(
      LJPermissionUtils.checkStorage,
      (context) => context.l10n.permStorage,
    );
  }

  static Future<bool> _request(
    Future<bool> Function() request,
    String Function(BuildContext) nameOf,
  ) async {
    final bool granted = await request();
    if (!granted) {
      final BuildContext context = Get.context!;
      DialogUtil.normal(
        title: context.l10n.permissionTitle,
        text: context.l10n.permissionDenied(nameOf(context)),
        cancelTitle: null,
      );
    }
    return granted;
  }
}
