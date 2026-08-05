import 'package:get/get.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    Get.lazyPut<WalletRepository>(() => WalletRepository(Get.find<WalletProvider>()));
    Get.lazyPut<WalletController>(
      () => WalletController(walletRepository: Get.find<WalletRepository>()),
    );
  }
}
