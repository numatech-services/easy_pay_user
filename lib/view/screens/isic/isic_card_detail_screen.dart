
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:viserpay/data/model/isic/isic_card_model.dart';
import 'package:viserpay/view/components/isic/animated_hologram_widget.dart';

// ============================================
// ÉCRAN DÉTAIL CARTE (Plein écran)
// ============================================

class IsicCardDetailScreen extends StatefulWidget {
  const IsicCardDetailScreen({Key? key}) : super(key: key);

  @override
  State<IsicCardDetailScreen> createState() => _IsicCardDetailScreenState();
}

class _IsicCardDetailScreenState extends State<IsicCardDetailScreen> {
  bool _showFront = true;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Mode plein écran
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IsicCardModel? cardData = Get.arguments as IsicCardModel?;
    
    if (cardData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Données de carte manquantes'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final isExpired = !cardData.isValid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Carte en plein écran
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFront = !_showFront;
                });
              },
              child: Hero(
                tag: 'isic_card_${cardData.cardNumber}',
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _showFront = index == 0;
                    });
                  },
                  children: [
                    // Recto
                    _buildFullScreenCard(
                      cardData: cardData,
                      imageUrl: cardData.images
                          .firstWhere(
                            (img) => img.type == 'FRONT',
                            orElse: () => cardData.images.first,
                          )
                          .url,
                      isExpired: isExpired,
                      isBack: false,
                    ),
                    // Verso
                    _buildFullScreenCard(
                      cardData: cardData,
                      imageUrl: cardData.images
                          .firstWhere(
                            (img) => img.type == 'BACK',
                            orElse: () => cardData.images.first,
                          )
                          .url,
                      isExpired: isExpired,
                      isBack: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bouton fermer
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // Indicateur de page
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(0),
                const SizedBox(width: 8),
                _buildPageIndicator(1),
              ],
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swipe, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _showFront ? 'Glissez pour voir le verso' : 'Glissez pour voir le recto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _showFront ? index == 0 : index == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFullScreenCard({
    required IsicCardModel cardData,
    required String imageUrl,
    required bool isExpired,
    required bool isBack,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de la carte
            ColorFiltered(
              colorFilter: isExpired
                  ? const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ])
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.credit_card,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Hologramme animé (seulement si valide et recto)
            if (!isExpired && !isBack)
              const Positioned.fill(
                child: AnimatedHologramWidget(),
              ),

            // Badge expiré
            if (isExpired)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'EXPIRÉE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}