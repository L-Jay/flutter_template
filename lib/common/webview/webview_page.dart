import 'package:lj_flutter_package/ui_component/lj_webview_page.dart';

import '../common.dart';

/// 路由参数：`{'url': xxx, 'title': xxx}`
class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = context.argumentMap ?? {};

    return LJWebViewPage(
      url: arguments['url']?.toString() ?? '',
      title: arguments['title']?.toString(),
    );
  }
}
