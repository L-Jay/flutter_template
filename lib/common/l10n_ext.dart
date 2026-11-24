import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../l10n/app_localizations.dart';

/// 页面/组件内一行取多语言：`context.l10n.xxx`
extension L10nBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Controller 等无 BuildContext 场景：`Get.l10n.xxx`
extension L10nGet on GetInterface {
  AppLocalizations get l10n => AppLocalizations.of(Get.context!);
}
