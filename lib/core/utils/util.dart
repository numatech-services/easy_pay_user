import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:intl/intl.dart' as intl;
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import '../../view/components/snack_bar/show_custom_snackbar.dart';
import 'my_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class MyUtils {
  static void vibrate() {
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  static splashScreen() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: MyColor.getPrimaryColor(),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: MyColor.getPrimaryColor(),
        systemNavigationBarIconBrightness: Brightness.light));
  }

  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy à HH:mm');
    return formatter.format(date);
  }

  String formatAmount(double amount, {String currency = ''}) {
    final NumberFormat formatter = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  double parseAmount(String amount) {
    final numericString = RegExp(r'[\d.]+').stringMatch(amount);
    if (numericString != null) {
      return double.tryParse(numericString) ?? 0.0;
    }
    return 0.0;
  }

  Future<bool> recordTransaction(String title, String msg, bool status,
      String idTrans, double amount) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('transactions').doc(idTrans).set({
        'title': title,
        'msg': msg,
        'status': status,
        'idTrans': idTrans,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Transaction enregistrée avec succès !');
      return true; // Succès
    } catch (e) {
      print(
          'Erreur lors de l\'enregistrement de la transaction===========================: $e');
      CustomSnackBar.error(errorList: ["$e"]);
      return false; // Échec
    }
  }

  void showSuccessDialog(
      BuildContext context, String title, String msg, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(RouteHelper.bottomNavBar);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
  }

  Future<void> generateAndSharePDF(Map<String, dynamic> details) async {
    final amount = parseAmount(details['amount'].toString());

    final date =
        DateTime.tryParse(details['date'].toString()) ?? DateTime.now();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Expéditeur :",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Nom"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("${details['senderName']}"),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Numéro ISIC"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("${details['senderISIC']}"),
                  ),
                ]),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Destinataire :",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Nom"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("${details['recipientName']}"),
                  ),
                ]),
                pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("Numéro ISIC"),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text("${details['recipientISIC']}"),
                  ),
                ]),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Montant : ${formatAmount(amount)} FCFA",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
            pw.Text(
              "Date d'envoi : ${formatDate(date)}",
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");

    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)], text: "Voici votre reçu d'envoi.");
  }

  String generateTransactionId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String randomString =
        List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();

    return randomString;
  }

  void validateAndUpdateAmount(TextEditingController controller, String value) {
    final validInput = RegExp(r'^\d*\.?\d*');
    final match = validInput.stringMatch(value);

    if (match != null) {
      controller.value = TextEditingValue(
        text: match,
        selection: TextSelection.collapsed(offset: match.length),
      );
    } else {
      CustomSnackBar.error(errorList: ["Chiffre n'est pas valide"]);
    }
  }

  void showLogoutWarning() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    child: Column(
                      children: [
                        const Text(
                          "Avertissement",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Vous avez été inactif pendant 5 minutes. Appuyez sur 'Ok' pour continuer à vous déconnecter.",
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed(RouteHelper.loginScreen);
                                },
                                child: const Text('Ok'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static allScreen() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: MyColor.colorWhite,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: MyColor.screenBgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: MyColor.colorWhite,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: MyColor.colorWhite,
      systemNavigationBarIconBrightness: Brightness.dark);

  static dynamic getShadow() {
    return [
      BoxShadow(
          blurRadius: 15.0,
          offset: const Offset(0, 25),
          color: Colors.grey.shade500.withOpacity(0.6),
          spreadRadius: -35.0),
    ];
  }

  static dynamic getShadow2({double blurRadius = 8}) {
    return [
      BoxShadow(
        color: MyColor.getShadowColor().withOpacity(0.3),
        blurRadius: blurRadius,
        spreadRadius: 3,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: MyColor.getShadowColor().withOpacity(0.3),
        spreadRadius: 1,
        blurRadius: blurRadius,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static dynamic getBottomSheetShadow() {
    return [
      BoxShadow(
        color: Colors.grey.shade400.withOpacity(0.08),
        spreadRadius: 3,
        blurRadius: 4,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(
        Localizations.localeOf(context).languageCode);
  }

  static dynamic getCardShadow() {
    return [
      BoxShadow(
        color: Colors.grey.shade400.withOpacity(0.05),
        spreadRadius: 2,
        blurRadius: 2,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static getOperationTitle(String value) {
    String number = value;
    RegExp regExp = RegExp(r'^(\d+)(\w+)$');
    Match? match = regExp.firstMatch(number);
    if (match != null) {
      String? num = match.group(1) ?? '';
      String? unit = match.group(2) ?? '';
      String title = '${MyStrings.last.tr} $num ${unit.capitalizeFirst}';
      return title.tr;
    } else {
      return value.tr;
    }
  }

  static String getChargeText(String charge) {
    String chargeText = "${MyStrings.inc.tr} $charge ${MyStrings.charge.tr}";
    return chargeText;
  }

  void showSchoolOfferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.school, color: Colors.pink),
                title: Text("ZCasch"),
                onTap: () async {
                  Navigator.pop(context);
                  // TODO: Ajouter action (ex: navigation ou appel)
                  await MyUtils.callUSSD("#144#");
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.wifi, color: Colors.pink),
                title: Text("Offre School"),
                onTap: () async {
                  Navigator.pop(context);
                  // TODO: Ajouter action (ex: navigation ou ouverture URL)
                  await MyUtils.callUSSD("#225#62#");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String maskSensitiveInformation(String input) {
    if (input.isEmpty) {
      return '';
    }

    final int maskLength = input.length ~/ 2; // Mask half of the characters.

    final String mask = '*' * maskLength;

    final String maskedInput = maskLength > 4
        ? input.replaceRange(5, maskLength, mask)
        : input.replaceRange(0, maskLength, mask);

    return maskedInput;
  }

  static List<FormModel> dynamicFormSelectValueFormatter(
      List<FormModel>? dynamicFormList) {
    List<FormModel> mainFormList = [];

    if (dynamicFormList != null && dynamicFormList.isNotEmpty) {
      mainFormList.clear();

      for (var element in dynamicFormList) {
        if (element.type == 'select') {
          bool? isEmpty = element.options?.isEmpty;
          bool empty = isEmpty ?? true;
          if (element.options != null && empty != true) {
            if (!element.options!.contains(MyStrings.selectOne)) {
              element.options?.insert(0, MyStrings.selectOne);
            }

            element.selectedValue = element.options?.first;
            mainFormList.add(element);
          }
        } else {
          mainFormList.add(element);
        }
      }
    }
    return mainFormList;
  }

  Future<bool> loadFeeIncludedStatus() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('fees_included') ?? false;
  }

  bool validatePinCode(String pin) {
    if (pin.length < 4) {
      MyUtils.vibrate();
      CustomSnackBar.error(errorList: [MyStrings.pinLengthErrorMessage]);
      return false;
    }
    if (pin.isEmpty) {
      MyUtils.vibrate();
      CustomSnackBar.error(errorList: [MyStrings.pinErrorMessage]);
      return false;
    }

    return true;
  }

  bool statusFeeIncluded = false;
  int payable = 0;
  Future<bool> balanceValidation({
    required int currentBalance,
    required int amount,
  }) async {
    try {
      payable = amount;

      if (amount > 0) {
        if (payable > currentBalance) {
          CustomSnackBar.error(errorList: [MyStrings.yourBalanceIsLow]);
          return false;
        } else {
          return true;
        }
      } else {
        CustomSnackBar.error(errorList: [MyStrings.enterValidAmount]);
        return false;
      }
    } catch (e) {
      CustomSnackBar.error(errorList: [MyStrings.enterValidAmount]);
      return false;
    }
  }

//permissons
  Future<PermissionStatus> isCameraPemissonGranted() async {
    if (await Permission.camera.isGranted) {
      return PermissionStatus.granted;
    } else {
      await Permission.camera.request().then((value) {
        return value;
      });
      return await Permission.camera.status;
    }
  }

  //
  static List<Widget> makeSloteWidget(
      {required List<Widget> widgets, bool showMoreWidget = false}) {
    List<Widget> pairs = [];
    for (int i = 0;
        i < (showMoreWidget ? widgets.length : (widgets.length / 2));
        i += 4) {
      Widget first = widgets[i];
      Widget? second =
          (i + 1 < widgets.length) ? widgets[i + 1] : const SizedBox();
      Widget? thrd =
          (i + 2 < widgets.length) ? widgets[i + 2] : const SizedBox();
      Widget? four =
          (i + 3 < widgets.length) ? widgets[i + 3] : const SizedBox();

      pairs.add(
        Column(
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: Dimensions.space15),
                  Expanded(child: second),
                  const SizedBox(width: Dimensions.space15),
                  Expanded(child: thrd),
                  const SizedBox(width: Dimensions.space15),
                  Expanded(child: four),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.space25 - 1)
          ],
        ),
      );
    }

    return pairs;
  }

  static List<Widget> removeWidget(
      {required List<Widget> widgets, bool showMoreWidget = false}) {
    List<Widget> pairs = [];
    for (int i = 0;
        i < (showMoreWidget ? widgets.length : (widgets.length / 3));
        i += 4) {
      Widget first = widgets[i];
      Widget? second =
          (i + 1 < widgets.length) ? widgets[i + 1] : const SizedBox();
      Widget? thrd =
          (i + 2 < widgets.length) ? widgets[i + 2] : const SizedBox();
      Widget? four =
          (i + 3 < widgets.length) ? widgets[i + 3] : const SizedBox();

      pairs.add(
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: first),
                const SizedBox(width: Dimensions.space15),
                Expanded(child: second),
                const SizedBox(width: Dimensions.space15),
                Expanded(child: thrd),
                const SizedBox(width: Dimensions.space15),
                Expanded(child: four),
              ],
            ),
            const SizedBox(height: Dimensions.space25 - 1)
          ],
        ),
      );
    }

    return pairs;
  }

  static TextInputType getInputTextFieldType(String type) {
    if (type == "email") {
      return TextInputType.emailAddress;
    } else if (type == "number") {
      return TextInputType.number;
    } else if (type == "url") {
      return TextInputType.url;
    }
    return TextInputType.text;
  }

  static bool getTextInputType(String type) {
    if (type == "text") {
      return true;
    } else if (type == "email") {
      return true;
    } else if (type == "number") {
      return true;
    } else if (type == "url") {
      return true;
    } else if (type == "textarea") {
      return true;
    }
    return false;
  }

  static Future<void> callUSSD(String ussdCode) async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }

    await FlutterPhoneDirectCaller.callNumber(ussdCode);
  }
}

void printx(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}
