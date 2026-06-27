import 'package:get/get.dart';
import '../../../data/providers/donor_provider.dart';
import '../../../data/repositories/donor_repository.dart';
import '../controllers/doner_request_controller.dart';

class DonerRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DonorProvider>(() => DonorProvider());
    Get.lazyPut<DonorRepository>(() => DonorRepository(Get.find<DonorProvider>()));
    Get.lazyPut<DonateController>(
      () => DonateController(donorRepository: Get.find<DonorRepository>()),
    );
  }
}
