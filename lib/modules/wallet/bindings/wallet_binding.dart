import 'package:get/get.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileProvider>()) {
      Get.lazyPut<ProfileProvider>(() => ProfileProvider());
    }
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(() => ProfileRepository(provider: Get.find<ProfileProvider>()));
    }
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    Get.lazyPut<WalletRepository>(() => WalletRepository(Get.find<WalletProvider>()));
    Get.lazyPut<WalletController>(
      () => WalletController(walletRepository: Get.find<WalletRepository>()),
    );
  }
}
