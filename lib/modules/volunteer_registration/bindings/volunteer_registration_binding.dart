import 'package:get/get.dart';
import '../../../data/providers/donor_provider.dart';
import '../../../data/repositories/donor_repository.dart';
import '../controllers/volunteer_registration_controller.dart';

class VolunteerRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DonorProvider>(() => DonorProvider());
    Get.lazyPut<DonorRepository>(() => DonorRepository(Get.find<DonorProvider>()));
    Get.lazyPut<VolunteerRegistrationController>(
      () => VolunteerRegistrationController(donorRepository: Get.find<DonorRepository>()),
    );
  }
}
