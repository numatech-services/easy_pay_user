import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/controller/account/change_password_controller.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final formKey = GlobalKey<FormState>();

  // ── Force du mot de passe ──
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.red;

  // Récupère le flag depuis les arguments de navigation
  final bool _isWeak = Get.arguments?['isWeak'] == true;

  void _checkStrength(String val) {
    double s = 0;
    if (val.length >= 8) s += 0.25;
    if (val.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (val.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (val.contains(RegExp(r'[\W_]'))) s += 0.25;

    setState(() {
      _strength = s;
      if (s <= 0.25) {
        _strengthLabel = 'Très faible';
        _strengthColor = Colors.red;
      } else if (s <= 0.5) {
        _strengthLabel = 'Faible';
        _strengthColor = Colors.orange;
      } else if (s <= 0.75) {
        _strengthLabel = 'Moyen';
        _strengthColor = Colors.amber;
      } else {
        _strengthLabel = 'Fort ✓';
        _strengthColor = Colors.green;
      }
    });
  }

  String? _validateNewPassword(dynamic value) {
    final String val = value?.toString() ?? '';
    if (val.isEmpty) return MyStrings.enterNewPass.tr;
    if (val.length < 8) return 'Minimum 8 caractères';
    if (!val.contains(RegExp(r'[A-Z]'))) return 'Ajoutez une majuscule';
    if (!val.contains(RegExp(r'[0-9]'))) return 'Ajoutez un chiffre';
    if (!val.contains(RegExp(r'[\W_]'))) return 'Ajoutez un caractère spécial';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      builder: (controller) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bannière d'avertissement si mot de passe faible ──
            if (_isWeak) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: Dimensions.space20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Votre mot de passe actuel est trop simple. '
                        'Veuillez en choisir un plus sécurisé.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Mot de passe actuel ──
            CustomTextField(
              animatedLabel: true,
              needOutlineBorder: true,
              labelText: MyStrings.currentPin,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              textInputType: TextInputType.text,
              onChanged: (_) {},
              validator: (value) => value.toString().isEmpty
                  ? MyStrings.enterCurrentPass.tr
                  : null,
              controller: controller.currentPassController,
              isShowSuffixIcon: true,
              isPassword: true,
            ),
            const SizedBox(height: Dimensions.space20),

            // ── Nouveau mot de passe ──
            CustomTextField(
              animatedLabel: true,
              needOutlineBorder: true,
              labelText: MyStrings.newPin.tr,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              textInputType: TextInputType.text,
              onChanged: (value) => _checkStrength(value),
              validator: _validateNewPassword,
              controller: controller.passController,
              isShowSuffixIcon: true,
              isPassword: true,
            ),

            // ── Barre de force ──
            if (controller.passController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _strength,
                  backgroundColor: Colors.grey.shade200,
                  color: _strengthColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _strengthLabel,
                style: TextStyle(
                  color: _strengthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: Dimensions.space20),

            // ── Confirmation ──
            CustomTextField(
              animatedLabel: true,
              needOutlineBorder: true,
              labelText: MyStrings.confirmPin.tr.toTitleCase().toString(),
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              textInputType: TextInputType.text,
              onChanged: (_) {},
              validator: (value) => controller.confirmPassController.text !=
                      controller.passController.text
                  ? MyStrings.kMatchPassError.tr
                  : null,
              controller: controller.confirmPassController,
              isShowSuffixIcon: true,
              isPassword: true,
            ),
            const SizedBox(height: Dimensions.space25),

            GradientRoundedButton(
              isLoading: controller.submitLoading,
              text: MyStrings.submit,
              press: () {
                if (formKey.currentState!.validate()) {
                  controller.changePassword();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
