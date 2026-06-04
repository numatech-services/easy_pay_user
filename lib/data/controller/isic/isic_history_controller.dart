import 'package:get/get.dart';
import 'package:viserpay/data/model/isic/isic_card_model.dart';
import 'package:viserpay/data/services/isic_cache_service.dart';
import 'package:viserpay/data/services/isic_card_service.dart';

class IsicHistoryController extends GetxController {
  // État
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final RxList<IsicCardModel> cardHistory = <IsicCardModel>[].obs;

  // Services
  late final IsicCardService _cardService;
  late final IsicCacheService _cacheService;

  @override
  void onInit() {
    super.onInit();
    _cardService = Get.find<IsicCardService>();
    _cacheService = Get.find<IsicCacheService>();
    loadHistory();
  }

  /// Charger l'historique
  Future<void> loadHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Pour l'instant, on récupère uniquement la carte actuelle
      // Dans une vraie implémentation, il faudrait un endpoint API pour l'historique
      final currentCard = await _cardService.getVirtualCard();

      // Simuler un historique avec la carte actuelle et des données mockées
      cardHistory.value = [
        currentCard,
        // Ajouter ici d'autres cartes depuis l'API si disponible
      ];

      // Trier par date (plus récente en premier)
      cardHistory.sort((a, b) {
        final dateA = DateTime.parse(a.lastModifiedOn);
        final dateB = DateTime.parse(b.lastModifiedOn);
        return dateB.compareTo(dateA);
      });
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement de l\'historique: $e';

      // Essayer de charger depuis le cache
      final cachedCard = await _cacheService.getCachedCardData();
      if (cachedCard != null) {
        cardHistory.value = [cachedCard];
        errorMessage.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtrer par statut
  void filterByStatus(String status) {
    // Implémenter le filtrage si nécessaire
  }
}
