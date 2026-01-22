import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
import 'package:qr_flutter/qr_flutter.dart';


class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrController;
  final InActivityTimer timer = InActivityTimer();
  bool isGlobalQrCode = false;
  String expectedType = "-1";
  String nextRouteName = "-1";
   String? type;
final controller = Get.put(SendMoneyContrller(
  sendMoneyRepo: Get.put(SendMoneyRepo(apiClient: Get.put(ApiClient(sharedPreferences: Get.find())))),
));
final args = Get.arguments; 
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(QrCodeRepo(apiClient: Get.find()));
    Get.put(QrCodeController(qrCodeRepo: Get.find()));
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SendMoneyRepo(apiClient: Get.find()));
    Get.put(SendMoneyContrller(
    sendMoneyRepo: Get.find(), 
    ));
   

    isGlobalQrCode = Get.arguments != null ? false : true;

    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.numberFocusNode.unfocus();
      controller.numberController.text = '';
      controller.numberController.clear();
      controller.initialValue();
    });
       if (args != null && args.length > 0) {
      type = args[0];
    }
    timer.startTimer(context);
  }

  void _onQRViewCreated(QRViewController qrController) {
      if (mounted) {
    setState(() {
      this.qrController = qrController;
    });
}
    qrController.scannedDataStream.listen((scanData) {
      result = scanData;
      String? myQrCode = result?.code != null && result!.code.toString().isNotEmpty ? result?.code.toString() : '';
      if (myQrCode != null && myQrCode.isNotEmpty) {
        
        manageQRData(myQrCode);

      }
    });
  }
  bool isScannerLoading = false;
void manageQRData(String myQrCode) async {
  if (qrController != null) {
    await qrController!.stopCamera().catchError((e) {});
    timer.handleUserInteraction(context);

    List<String> parts = myQrCode.split('-');

    // if (parts.length < 2) { 
    //       controller.numberController.text = parts[0].trim();

    // if (type == "send_money") {
    //   controller.type_payment = "send_money";
    //   controller.checkUserExist(type: type!);
    // } else {
    //   controller.type_payment = "cash_in";
    //   controller.checkUserExist(type: type!);
    // }
    // }
    
      controller.numberController.text = parts[0].trim();
      String idTrans =  parts[1].trim();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('idTrans', idTrans);
      controller.type_payment = "send_money";
   
      controller.checkUserExist(type: type!);
 
    


  }
}


  void _stopCameraSafely() {
  if (qrController != null) {
    qrController!.stopCamera().catchError((e) {
      print("Erreur lors de l'arrêt de la caméra : $e");
    });
  }
}


  @override
  void reassemble() {
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
    } else if (Platform.isIOS) {
      qrController?.resumeCamera();
    }
    super.reassemble();
  }

  @override
  void dispose() {
      if (qrController != null) {
    qrController!.stopCamera().catchError((e) {
      print("Erreur lors de l'arrêt de la caméra 1 : $e");
    }).whenComplete(() {
      qrController!.dispose();
    });
  }
    super.dispose();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      CustomSnackBar.error(errorList: [MyStrings.noPermissionFound.tr]);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
  

    return  WillPopScope(
    onWillPop: () async {
      if (qrController != null) {
        await qrController!.stopCamera().catchError((e) {
          print("Erreur lors de l'arrêt de la caméra 2: $e");
        });
      }
      return true;  // Autoriser le retour
    },
      child: GetBuilder<QrCodeController>(
        builder: (viewController) => Scaffold(
          appBar: CustomAppBar(
            title: MyStrings.qrScan.tr,
            isShowBackBtn: true,
            bgColor: MyColor.appBarColor,
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
            child: GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
              child: Stack(
                children: [
                  !viewController.isScannerLoading
                      ? Column(
                          children: [
                            Expanded(
                                child: QRView(
                              key: qrKey,
                              onQRViewCreated: _onQRViewCreated,
                              cameraFacing: CameraFacing.back,
                              overlay: QrScannerOverlayShape(
                                borderColor: MyColor.primaryColor,
                                borderRadius: 5,
                                borderLength: 30,
                                borderWidth: 10,
                                cutOutSize: (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 300.0,
                              ),
                              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
                            )),
                          ],
                        )
                      :  
                  //     Center(
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       SizedBox(
                  //         height: 50,
                  //         width: 50,
                  //         child: CircularProgressIndicator(
                  //           color: MyColor.primaryColor,
                  //           strokeWidth: 4.0,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Text(
                  //         "Chargement en cours...", // Message personnalisé
                  //         style: TextStyle(color: MyColor.primaryColor),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                      Align(
                          alignment: Alignment.center,
                          child: Lottie.asset(MyAnimation.time, height: 150),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}