import '../common/common.dart';

class VipController extends GetxController {
  final info = Rxn<VipInfo>();

  @override
  void onInit() {
    super.onInit();

    loadInfo();
  }

  Future<void> loadInfo() async {
    final dynamic response = await LJNetwork.get(ApiUrl.vipInfo);
    final Map<String, dynamic>? data = parseDataMap(response);
    if (data != null) info.value = VipInfo.fromJson(data);
  }

  Future<void> openVip() async {
    final VipInfo? current = info.value;
    if (current == null) return;

    final bool paid = await PaySheet.show(amount: current.price);
    if (!paid) return;

    EasyLoading.showSuccess(
      Get.l10n.vipSuccess,
    );
  }
}
