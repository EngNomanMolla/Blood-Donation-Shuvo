import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/donor_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/donor_repository.dart';
import '../controllers/assisted_registration_controller.dart';

class AssistedRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthProvider>()));
    Get.lazyPut<DonorProvider>(() => DonorProvider());
    Get.lazyPut<DonorRepository>(() => DonorRepository(Get.find<DonorProvider>()));
    Get.lazyPut<AssistedRegistrationController>(
      () => AssistedRegistrationController(
        authRepository: Get.find<AuthRepository>(),
        donorRepository: Get.find<DonorRepository>(),
      ),
    );
  }
}
