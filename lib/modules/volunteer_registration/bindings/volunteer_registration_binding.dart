import 'package:get/get.dart';
import '../controllers/volunteer_registration_controller.dart';

class VolunteerRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VolunteerRegistrationController>(
      () => VolunteerRegistrationController(),
    );
  }
}
