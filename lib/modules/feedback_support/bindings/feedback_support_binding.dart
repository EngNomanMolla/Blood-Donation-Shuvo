import 'package:get/get.dart';
import '../controllers/feedback_support_controller.dart';

class FeedbackSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedbackSupportController>(
      () => FeedbackSupportController(),
    );
  }
}
