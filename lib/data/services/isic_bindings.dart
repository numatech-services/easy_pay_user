import 'package:get/get.dart';
import 'package:viserpay/data/controller/isic/isic_history_controller.dart';
import 'package:viserpay/data/controller/isic/isic_photo_controller.dart';
import 'package:viserpay/data/controller/isic/isic_activation_controller.dart';
import 'package:viserpay/data/controller/isic/isic_card_controller.dart';
import 'package:viserpay/data/services/isic_auth_service.dart';
import 'package:viserpay/data/services/isic_cache_service.dart';
import 'package:viserpay/data/services/isic_card_service.dart';
import 'package:viserpay/data/services/isic_token_manager.dart';

class IsicCardBinding extends Bindings {
  @override
  void dependencies() {
    // Services (singleton)
    Get.lazyPut<IsicTokenManager>(() => IsicTokenManager(), fenix: true);
    Get.lazyPut<IsicCacheService>(() => IsicCacheService(), fenix: true);
    Get.lazyPut<IsicAuthService>(() => IsicAuthService(), fenix: true);
    Get.lazyPut<IsicCardService>(() => IsicCardService(), fenix: true);

    // Controller
    Get.lazyPut(() => IsicCardController());
  }
}
