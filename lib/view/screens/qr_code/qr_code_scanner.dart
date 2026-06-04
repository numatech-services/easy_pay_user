import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:viserpay/core/utils/my_animation.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';

import 'package:viserpay/data/controller/qr_code/qr_code_controller.dart';
import 'package:viserpay/data/controller/send_money/sendmoney_controller.dart';
import 'package:viserpay/data/repo/qr_code/qr_code_repo.dart';
import 'package:viserpay/data/repo/send_money/send_money_repo.dart';
import 'package:viserpay/data/services/api_service.dart';

import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  final InActivityTimer timer = InActivityTimer();
  final MobileScannerController cameraController = MobileScannerController();

  bool isProcessing = false;
  String? type;

  final controller = Get.put(SendMoneyContrller(
    sendMoneyRepo: Get.put(
      SendMoneyRepo(
          apiClient: Get.put(ApiClient(sharedPreferences: Get.find()))),
    ),
  ));

  @override
  void initState() {
    super.initState();

    Get.put(QrCodeRepo(apiClient: Get.find()));
    Get.put(QrCodeController(qrCodeRepo: Get.find()));

    final args = Get.arguments;
    if (args != null && args.length > 0) {
      type = args[0];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.numberFocusNode.unfocus();
      controller.numberController.clear();
      controller.initialValue();
    });

    timer.startTimer(context);
  }

  void manageQRData(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    await cameraController.stop();

    timer.handleUserInteraction(context);

    try {
      List<String> parts = code.split('-');

      controller.numberController.text = parts[0].trim();

      if (parts.length > 1) {
        String idTrans = parts[1].trim();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('idTrans', idTrans);
      }

      controller.type_payment = "send_money";
      controller.checkUserExist(type: type ?? "send_money");
    } catch (e) {
      CustomSnackBar.error(errorList: ["QR invalide"]);
      log("QR ERROR: $e");
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await cameraController.stop();
        return true;
      },
      child: GetBuilder<QrCodeController>(
        builder: (viewController) => Scaffold(
          appBar: CustomAppBar(
            title: MyStrings.qrScan.tr,
            isShowBackBtn: true,
            bgColor: MyColor.appBarColor,
          ),
          body: GestureDetector(
            onTap: () => timer.handleUserInteraction(context),
            onPanUpdate: (_) => timer.handleUserInteraction(context),
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (barcodeCapture) {
                    final barcode = barcodeCapture.barcodes.first;
                    final String? code = barcode.rawValue;

                    if (code != null && code.isNotEmpty) {
                      manageQRData(code);
                    }
                  },
                ),

                // Overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MyColor.primaryColor,
                      width: 3,
                    ),
                  ),
                ),

                if (viewController.isScannerLoading)
                  Center(
                    child: Lottie.asset(MyAnimation.time, height: 150),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
