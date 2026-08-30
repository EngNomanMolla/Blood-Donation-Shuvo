import 'package:blood_donation/data/providers/call_provider.dart';
import 'package:blood_donation/data/repositories/call_repository.dart';
import 'package:blood_donation/modules/call/controllers/call_controller.dart';
import 'package:get/get.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallProvider>(() => CallProvider());
    Get.lazyPut<CallRepository>(() => CallRepository(Get.find<CallProvider>()));
    Get.lazyPut<CallController>(() => CallController(callRepository: Get.find<CallRepository>()));
  }
}
