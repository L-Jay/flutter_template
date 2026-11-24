import 'package:lj_flutter_package/widgets/double_pop_widget.dart';

import '../common/common.dart';
import 'bottom_navigation_controller.dart';

class BottomNavigationPage extends GetView<BottomNavigationController> {
  const BottomNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BottomNavigationController());

    return DoublePopWidget(
      firstCallBack: () {
        EasyLoading.showToast(context.l10n.tapAgainToExit);
      },
      child: Scaffold(
        body: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: controller.pages,
        ),
        bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context)),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        elevation: 0,
        currentIndex: controller.currentIndex.value,
        onTap: (index) => controller.currentIndex.value = index,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedItemColor: colors.brand,
        unselectedItemColor: colors.textHint,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: context.l10n.tabHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_outlined),
            activeIcon: const Icon(Icons.grid_view_rounded),
            label: context.l10n.tabProduct,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article_outlined),
            activeIcon: const Icon(Icons.article_rounded),
            label: context.l10n.tabContent,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: context.l10n.tabMine,
          ),
        ],
      ),
    );
  }
}
