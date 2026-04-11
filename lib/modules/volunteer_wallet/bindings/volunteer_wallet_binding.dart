import 'package:get/get.dart';
import '../controllers/volunteer_wallet_controller.dart';

class VolunteerWalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VolunteerWalletController>(
      () => VolunteerWalletController(),
    );
  }
}
