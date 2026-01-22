import 'package:get/get.dart';
import 'package:viserpay/data/controller/isic/isic_activation_controller.dart';

class IsicActivationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IsicActivationController());
  }
}
