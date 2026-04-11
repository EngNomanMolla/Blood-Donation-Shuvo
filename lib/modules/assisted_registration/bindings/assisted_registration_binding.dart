import 'package:get/get.dart';
import '../controllers/assisted_registration_controller.dart';

class AssistedRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssistedRegistrationController>(
      () => AssistedRegistrationController(),
    );
  }
}
