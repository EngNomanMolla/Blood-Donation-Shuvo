import 'package:get/get.dart';
import '../../../data/providers/home_provider.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controllers/home_controller.dart';
import '../../more/controllers/more_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeProvider>(() => HomeProvider());
    Get.lazyPut<HomeRepository>(() => HomeRepository(Get.find<HomeProvider>()));
    Get.lazyPut<ProfileProvider>(() => ProfileProvider());
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(provider: Get.find<ProfileProvider>()),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(
        homeRepository: Get.find<HomeRepository>(),
        profileRepository: Get.find<ProfileRepository>(),
      ),
    );
    Get.lazyPut<MoreController>(() => MoreController());
  }
}

