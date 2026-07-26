import 'package:get/get.dart';
import 'package:blood_donation/data/providers/auth_provider.dart';
import 'package:blood_donation/data/repositories/auth_repository.dart';
import '../controllers/sign_in_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthProvider>()));
    Get.lazyPut<SignInController>(
      () => SignInController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
