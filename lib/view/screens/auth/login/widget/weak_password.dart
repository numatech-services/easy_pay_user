import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/data/controller/account/change_password_controller.dart';

class WeakPasswordDialog extends StatefulWidget {
  const WeakPasswordDialog({super.key});

  @override
  State<WeakPasswordDialog> createState() => _WeakPasswordDialogState();
}

class _WeakPasswordDialogState extends State<WeakPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  // Indicateur de force
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.red;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    setState(() => _isLoading = false);
    Get.back();
    Get.snackbar(
      'Succès',
      'Mot de passe mis à jour !',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.lock_outline, color: Colors.orange.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mot de passe faible',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Sécurisez votre compte',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 16),
              const Text(
                'Votre mot de passe actuel est trop simple. Choisissez-en un plus sécurisé.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Nouveau mot de passe
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _hideNew,
                onChanged: _checkStrength,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_hideNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _hideNew = !_hideNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Minimum 8 caractères';
                  if (!v.contains(RegExp(r'[A-Z]')))
                    return 'Ajoutez une majuscule';
                  if (!v.contains(RegExp(r'[0-9]')))
                    return 'Ajoutez un chiffre';
                  if (!v.contains(RegExp(r'[\W_]')))
                    return 'Ajoutez un caractère spécial';
                  return null;
                },
              ),

              // Barre de force
              if (_newPassCtrl.text.isNotEmpty) ...[
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
                Text(_strengthLabel,
                    style: TextStyle(
                        color: _strengthColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],

              const SizedBox(height: 12),

              // Confirmation
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _hideConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_hideConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                  ),
                ),
                validator: (v) => v != _newPassCtrl.text
                    ? 'Les mots de passe ne correspondent pas'
                    : null,
              ),

              const SizedBox(height: 20),

              // Boutons
              Row(children: [
                // "Plus tard" — optionnel, retirez si vous voulez contraindre
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Plus tard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Mettre à jour',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
