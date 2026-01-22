import 'package:get/get.dart';
import 'package:viserpay/data/controller/isic/isic_history_controller.dart';

class IsicHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IsicHistoryController());
  }
}
