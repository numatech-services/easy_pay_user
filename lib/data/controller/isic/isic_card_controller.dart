import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/isic_constants.dart';
import 'package:viserpay/data/model/isic/isic_card_model.dart';
import 'package:viserpay/data/services/isic_auth_service.dart';
import 'package:viserpay/data/services/isic_card_service.dart';

class IsicCardController extends GetxController {
  // Observables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final Rxn<IsicCardModel> cardData = Rxn<IsicCardModel>();
  final frontImageUrl = ''.obs;
  final backImageUrl = ''.obs;

  // Services
  late final IsicCardService _cardService;
  late final IsicAuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _cardService = Get.find<IsicCardService>();
    _authService = Get.find<IsicAuthService>();
    loadCardData();
  }

  bool get isCardValid {
    if (cardData.value == null) return false;
    return cardData.value!.status == IsicConstants.statusValid &&
        DateTime.parse(cardData.value!.validTo).isAfter(DateTime.now());
  }

  Future<void> loadCardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Vérifier le token
      // if (!await _authService.isAuthenticated()) {
      //   Get.offNamed(RouteHelper.isicActivationScreen);
      //   return;
      // }

      // Récupérer les données de la carte
      final data = await _cardService.getVirtualCard();
      cardData.value = data;

      // Charger les images
      if (data.images.isNotEmpty) {
        for (var image in data.images) {
          if (image.type == IsicConstants.imageTypeFront) {
            frontImageUrl.value = image.url;
          } else if (image.type == IsicConstants.imageTypeBack) {
            backImageUrl.value = image.url;
          }
        }
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement de la carte: $e';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> downloadCard() async {
    // Implémenter le téléchargement de la carte
    Get.snackbar(
      'Téléchargement',
      'Fonctionnalité en cours de développement',
      icon: const Icon(Icons.info_outline, color: Colors.blue),
    );
  }
}
