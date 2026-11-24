import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'common/common.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildGetMaterialApp());
  }

  GetMaterialApp _buildGetMaterialApp() {
    final TransitionBuilder appBuilder = FlutterSmartDialog.init(
      builder: EasyLoading.init(),
    );

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService.to.themeMode.value,
      locale: LanguageService.to.locale.value,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routingCallback: (routing) {
        if (routing?.isBack == true) {
          EasyLoading.dismiss();
        }
      },
      initialRoute: RouterManager.rootPageName,
      unknownRoute: Routers.unknownPage,
      // 在web端防止直接输入网址进入需要登录的界面,使用onGenerateRoute进行拦截
      getPages: kIsWeb ? null : RouterManager.getPages,
      onGenerateRoute: kIsWeb ? RouterManager.onGenerateRoute : null,
      builder: (context, child) {
        return RefreshConfiguration(
          headerBuilder: () => WaterDropHeader(
            refresh: Text(context.l10n.refreshLoading),
            complete: Text(context.l10n.refreshComplete),
          ),
          footerBuilder: () => ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
            idleText: context.l10n.pullUpLoad,
            loadingText: context.l10n.loading,
            canLoadingText: context.l10n.releaseToLoadMore,
            failedText: context.l10n.loadFailed,
            noDataText: context.l10n.noMoreData,
          ),
          maxOverScrollExtent: 100,
          maxUnderScrollExtent: 0,
          enableScrollWhenRefreshCompleted: true,
          enableLoadingWhenFailed: true,
          hideFooterWhenNotFull: true,
          enableBallisticLoad: true,
          child: appBuilder(context, child),
        );
      },
    );
  }
}
