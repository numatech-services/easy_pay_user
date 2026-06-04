import 'package:get/get.dart';
import 'package:viserpay/data/controller/isic/isic_photo_controller.dart';

class IsicPhotoUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IsicPhotoController());
  }
}
