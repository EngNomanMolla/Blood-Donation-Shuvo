import 'package:get/get.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../controllers/initial_recharge_controller.dart';

class InitialRechargeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    Get.lazyPut<WalletRepository>(() => WalletRepository(Get.find<WalletProvider>()));
    Get.lazyPut<InitialRechargeController>(
      () => InitialRechargeController(walletRepository: Get.find<WalletRepository>()),
    );
  }
}
