import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/data/repo/account/change_password_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutter/material.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordRepo changePasswordRepo;

  ChangePasswordController({required this.changePasswordRepo});

  List<String> errors = [];
  String? currentPass, password, confirmPass;
  bool isLoading = false;
  TextEditingController currentPassController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode currentPassFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPassFocusNode = FocusNode();

  addError({required String error}) {
    if (!errors.contains(error)) {
      errors.add(error);
      update();
    }
  }

  removeError({required String error}) {
    if (errors.contains(error)) {
      errors.remove(error);
      update();
    }
  }

  bool submitLoading = false;
  changePassword() async {
    String currentPass = currentPassController.text.toString();
    String password = passController.text.toString();

    submitLoading = true;
    update();
    bool b = await changePasswordRepo.changePassword(currentPass, password);

    if (b) {
      await changePasswordRepo.apiClient.storePasscode(passController.text);
      currentPassController.clear();
      passController.clear();
      confirmPassController.clear();

      Get.offAllNamed(RouteHelper.bottomNavBar);
      await Future.delayed(const Duration(milliseconds: 500));

      Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: Colors.green.shade600, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mot de passe changé',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre mot de passe a été mis à jour avec succès.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('OK',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
    submitLoading = false;
    update();
  }

  void clearData() {
    isLoading = false;
    errors.clear();
    currentPassController.text = '';
    passController.text = '';
    confirmPassController.text = '';
  }
}
