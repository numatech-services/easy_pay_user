import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:viserpay/data/services/isic_auth_service.dart';
import 'package:viserpay/data/services/isic_token_manager.dart';

class IsicActivationController extends GetxController {
  // Form
  final formKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  // État
  final isLoading = false.obs;
  final isSuccess = false.obs;
  final errorMessage = ''.obs;

  // Services
  late final IsicAuthService _authService;
  late final IsicTokenManager _tokenManager;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<IsicAuthService>();
    _tokenManager = Get.find<IsicTokenManager>();
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    fullNameController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }

  /// Sélectionner la date de naissance
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // ~18 ans
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF22BB44),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      dateOfBirthController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  /// Activer la carte
  Future<void> activateCard() async {
    // Valider le formulaire
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Vérifier qu'on a au moins le nom ou la date de naissance
    if (fullNameController.text.isEmpty && dateOfBirthController.text.isEmpty) {
      errorMessage.value = 'Veuillez renseigner le nom ou la date de naissance';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Récupérer la config cliente
      final config = _tokenManager.getClientConfig();
      if (config['client_id'] == null || config['client_secret'] == null) {
        throw Exception(
            'Configuration manquante. Veuillez réinstaller l\'application.');
      }

      // Convertir la date si nécessaire
      String? dateOfBirth;
      if (dateOfBirthController.text.isNotEmpty) {
        final parts = dateOfBirthController.text.split('/');
        if (parts.length == 3) {
          dateOfBirth = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      // Étape 1: Autoriser la carte
      final code = await _authService.authorizeCard(
        clientId: config['client_id']!,
        cardNumber: cardNumberController.text.trim().toUpperCase(),
        personName: fullNameController.text.isNotEmpty
            ? fullNameController.text.trim()
            : null,
        dateOfBirth: dateOfBirth,
      );

      // Étape 2: Échanger le code contre les tokens
      final success = await _authService.exchangeCodeForTokens(
        code: code,
        clientId: config['client_id']!,
        clientSecret: config['client_secret']!,
        redirectUri: config['redirect_uri']!,
      );

      if (success) {
        isSuccess.value = true;

        // Afficher snackbar de succès
        Get.snackbar(
          'Succès',
          'Votre carte ISIC a été activée avec succès',
          backgroundColor: const Color(0xFF22BB44).withOpacity(0.1),
          colorText: const Color(0xFF22BB44),
          icon: const Icon(Icons.check_circle, color: Color(0xFF22BB44)),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Attendre 2 secondes avant de naviguer
        await Future.delayed(const Duration(seconds: 2));
      } else {
        throw Exception('Échec de l\'activation');
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

  /// Formater les messages d'erreur
  String _formatErrorMessage(String error) {
    if (error.contains('Card not found') || error.contains('404')) {
      return 'Carte non trouvée. Vérifiez le numéro saisi.';
    } else if (error.contains('Invalid credentials') ||
        error.contains('Authorization failed')) {
      return 'Informations incorrectes. Vérifiez le nom ou la date de naissance.';
    } else if (error.contains('expired') || error.contains('410')) {
      return 'Cette carte a expiré ou a été annulée.';
    } else if (error.contains('network') || error.contains('timeout')) {
      return 'Erreur de connexion. Vérifiez votre connexion Internet.';
    } else if (error.contains('Configuration manquante')) {
      return error;
    } else {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}

// ============================================
// FORMATTER - Uppercase
// ============================================

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
