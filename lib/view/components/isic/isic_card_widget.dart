import 'package:flutter/material.dart';
import 'package:viserpay/data/model/isic/isic_card_model.dart';
import 'package:viserpay/view/components/isic/animated_hologram_widget.dart';

class IsicCardWidget extends StatelessWidget {
  final IsicCardModel cardData;
  final String imageUrl;
  final bool isExpired;
  final bool isBackSide;

  const IsicCardWidget({
    Key? key,
    required this.cardData,
    required this.imageUrl,
    this.isExpired = false,
    this.isBackSide = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32;
    final cardHeight = cardWidth / 1.586; // Ratio carte bancaire

    return Container(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        children: [
          // Image de fond de la carte
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColorFiltered(
              colorFilter: isExpired
                  ? const ColorFilter.matrix([
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]) // Noir et blanc si expiré
                  : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.credit_card,
                                size: 64, color: Colors.grey),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.credit_card,
                            size: 64, color: Colors.grey),
                      ),
                    ),
            ),
          ),

          // Hologramme animé (seulement si carte valide et recto)
          if (!isExpired && !isBackSide)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const AnimatedHologramWidget(),
              ),
            ),

          // Overlay sombre si expiré
          if (isExpired)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
