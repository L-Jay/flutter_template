import '../common/common.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    final AppColors colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 与原生闪屏同图，避免切换时跳变
          Image.asset('assets/images/splash.png', fit: BoxFit.cover),
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            bottom: 48 + MediaQuery.of(context).viewPadding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LJ Template',
                  style: AppTextStyle.title(colors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: SplashController.minSplashDuration,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 3,
                        backgroundColor: colors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.brand),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
