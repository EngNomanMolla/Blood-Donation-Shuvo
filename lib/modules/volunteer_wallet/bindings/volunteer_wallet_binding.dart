import 'package:get/get.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../controllers/volunteer_wallet_controller.dart';

class VolunteerWalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    Get.lazyPut<WalletRepository>(() => WalletRepository(Get.find<WalletProvider>()));
    Get.lazyPut<VolunteerWalletController>(
      () => VolunteerWalletController(walletRepository: Get.find<WalletRepository>()),
    );
  }
}
