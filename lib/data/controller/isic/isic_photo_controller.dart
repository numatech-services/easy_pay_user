import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viserpay/data/services/isic_card_service.dart';

class IsicPhotoController extends GetxController {
  // État
  final isLoading = false.obs;
  final isSuccess = false.obs;
  final errorMessage = ''.obs;
  final Rxn<String> selectedImage = Rxn<String>();

  // Services
  final _picker = ImagePicker();
  late final IsicCardService _cardService;

  @override
  void onInit() {
    super.onInit();
    _cardService = Get.find<IsicCardService>();
  }

  /// Sélectionner une image
  Future<void> pickImage(ImageSource source) async {
    try {
      errorMessage.value = '';

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Vérifier la taille du fichier (max 5 MB)
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          errorMessage.value = 'La photo est trop volumineuse (max 5 MB)';
          return;
        }

        selectedImage.value = pickedFile.path;

        Get.snackbar(
          'Photo sélectionnée',
          'Vous pouvez maintenant l\'uploader',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          icon: const Icon(Icons.check_circle, color: Colors.orange),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la sélection de l\'image';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Uploader la photo
  Future<void> uploadPhoto() async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Veuillez sélectionner une photo';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _cardService.uploadPhoto(selectedImage.value!);

      if (success) {
        isSuccess.value = true;

        Get.snackbar(
          'Succès',
          'Photo uploadée avec succès',
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          icon: const Icon(Icons.check_circle, color: Colors.orange),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Attendre 2 secondes avant de revenir
        await Future.delayed(const Duration(seconds: 2));
      } else {
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      errorMessage.value = _formatErrorMessage(e.toString());

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Effacer l'image sélectionnée
  void clearImage() {
    selectedImage.value = null;
    errorMessage.value = '';
  }

  /// Formater les messages d'erreur
  String _formatErrorMessage(String error) {
    if (error.contains('already uploaded') || error.contains('400')) {
      return 'Une photo a déjà été uploadée pour cette carte';
    } else if (error.contains('Invalid image') || error.contains('format')) {
      return 'Format d\'image invalide. Utilisez JPG ou PNG';
    } else if (error.contains('too large')) {
      return 'La photo est trop volumineuse (max 5 MB)';
    } else if (error.contains('network') || error.contains('timeout')) {
      return 'Erreur de connexion. Vérifiez votre connexion Internet';
    } else if (error.contains('403')) {
      return 'Vous n\'êtes pas autorisé à uploader cette photo';
    } else if (error.contains('404')) {
      return 'Carte non trouvée';
    } else if (error.contains('410')) {
      return 'Cette carte a été annulée';
    } else {
      return 'Une erreur est survenue lors de l\'upload';
    }
  }
}
