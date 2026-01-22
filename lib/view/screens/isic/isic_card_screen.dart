import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/data/controller/isic/isic_card_controller.dart';
import 'package:viserpay/data/services/screenshot_blocker.dart';
import 'package:viserpay/view/components/isic/card_flip_widget.dart';
import 'package:viserpay/view/components/isic/isic_card_widget.dart';
import 'package:viserpay/view/components/isic/timestamp_widget.dart';

class IsicCardScreen extends StatefulWidget {
  const IsicCardScreen({Key? key}) : super(key: key);

  @override
  State<IsicCardScreen> createState() => _IsicCardScreenState();
}

class _IsicCardScreenState extends State<IsicCardScreen> {
  @override
  void initState() {
    super.initState();
    ScreenshotBlocker.enableScreenshotBlock();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  void dispose() {
    ScreenshotBlocker.disableScreenshotBlock();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IsicCardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Ma Carte ISIC'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () => Get.toNamed(RouteHelper.isicHistoryScreen),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 2,
              value: 0.5,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.loadCardData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.cardData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Aucune carte trouvée',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Activez votre carte ISIC',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      Get.toNamed(RouteHelper.isicActivationScreen),
                  icon: const Icon(Icons.add_card),
                  label: const Text('Activer ma carte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadCardData(),
          color: Colors.green,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Timestamp Widget
                TimestampWidget(
                  isValid: controller.isCardValid,
                  cardStatus: controller.cardData.value!.status,
                ),

                const SizedBox(height: 24),

                // Carte ISIC avec animation flip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CardFlipWidget(
                    frontCard: IsicCardWidget(
                      cardData: controller.cardData.value!,
                      imageUrl: controller.frontImageUrl.value,
                      isExpired: !controller.isCardValid,
                    ),
                    backCard: IsicCardWidget(
                      cardData: controller.cardData.value!,
                      imageUrl: controller.backImageUrl.value,
                      isExpired: !controller.isCardValid,
                      isBackSide: true,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Indicateur flip
                Center(
                  child: Text(
                    'Appuyez sur la carte pour voir le verso',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Informations de la carte
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              const Text(
                                'Informations de la carte',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Numéro',
                            controller.cardData.value!.cardNumber,
                          ),
                          _buildInfoRow(
                            'Statut',
                            controller.cardData.value!.status,
                            valueColor: controller.isCardValid
                                ? Colors.green
                                : Colors.red,
                          ),
                          _buildInfoRow(
                            'Valide jusqu\'au',
                            controller
                                .formatDate(controller.cardData.value!.validTo),
                          ),
                          _buildInfoRow(
                            'Dernière mise à jour',
                            controller.formatDate(
                                controller.cardData.value!.lastModifiedOn),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions rapides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt,
                              color: Colors.orange),
                          title: const Text('Mettre à jour ma photo'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Get.toNamed(RouteHelper.isicPhotoScreen),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading:
                              const Icon(Icons.fullscreen, color: Colors.blue),
                          title: const Text('Voir en plein écran'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Get.toNamed(
                            RouteHelper.isicCardDetailScreen,
                            arguments: controller.cardData.value,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading:
                              const Icon(Icons.download, color: Colors.purple),
                          title: const Text('Télécharger la carte'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => controller.downloadCard(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Message pour carte expirée
                if (!controller.isCardValid)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Carte expirée',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Votre carte ISIC a expiré. Renouvelez-la pour continuer à bénéficier des avantages.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
