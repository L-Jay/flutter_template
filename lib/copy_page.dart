import 'common/common.dart';
import 'copy_controller.dart';

class CopyPage extends GetView<CopyController> {
  const CopyPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CopyController());
    return Scaffold(
      appBar: AppBar(),
      body: const Placeholder(),
    );
  }
}
