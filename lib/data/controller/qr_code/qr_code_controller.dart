import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/url_container.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/model/qr_code/qr_code_response_model.dart';
import 'package:viserpay/data/model/qr_code/qr_code_scan_response_model.dart';
import 'package:viserpay/data/repo/qr_code/qr_code_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:viserpay/view/components/dialog/app_dialog.dart';
import 'package:http/http.dart' as http;

class QrCodeController extends GetxController {
  QrCodeRepo qrCodeRepo;
  QrCodeController({required this.qrCodeRepo});

  bool isLoading = true;
  QrCodeResponseModel model = QrCodeResponseModel();

  String qrCode = "";
  String username = '';

  Future<void> loadData() async {
    username = qrCodeRepo.apiClient.getCurrencyOrUsername(isCurrency: false);
    isLoading = true;
    update();

    ResponseModel responseModel = await qrCodeRepo.getQrData();
    if (responseModel.statusCode == 200) {
      model = QrCodeResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status.toString().toLowerCase() == "success") {
        qrCode = model.data?.qrCode ?? "";
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  Future<void> shareImage() async {
    final box = Get.context!.findRenderObject() as RenderBox?;

    await Share.share(
      qrCode,
      subject: MyStrings.share.tr,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  String downloadUrl = "";
  String _localPath = '';
  String downloadFileName = "";
  bool downloadLoading = false;
  Future<void> downloadImage() async {
    downloadLoading = true;
    update();
    final headers = {
      'Authorization': "Bearer ${qrCodeRepo.apiClient.token}",
      'content-type': 'image/png',
    };

    String url = "${UrlContainer.baseUrl}${UrlContainer.qrCodeImageDownload}";
    http.Response response = await http.post(Uri.parse(url), body: null, headers: headers);
    final bytes = response.bodyBytes;
    String extension = "png";

    await saveAndOpenFile(bytes, '${MyStrings.appName}_${DateTime.now().millisecondsSinceEpoch}.$extension', extension);

    return;
  }

  bool isSubmitLoading = false;
  int selectedIndex = -1;

  Future<void> saveAndOpenFile(List<int> bytes, String fileName, String extension) async {
    Directory? downloadsDirectory;

    if (Platform.isAndroid) {
      await Permission.storage.request();
      downloadsDirectory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    }

    if (downloadsDirectory != null) {
      final downloadPath = '${downloadsDirectory.path}/$fileName';
      final file = File(downloadPath);
      await file.writeAsBytes(bytes);
      CustomSnackBar.success(successList: ['File saved at: $downloadPath']);
      print('File saved at: $downloadPath');
      await openFile(downloadPath, extension);
    } else {
      CustomSnackBar.error(errorList: ["error"]);
    }
    downloadLoading = false;
    update();
  }

  Future<void> openFile(String path, String extension) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        if (result.type == ResultType.noAppToOpen) {
          CustomSnackBar.error(errorList: ['File saved at: $path']);
          // CustomSnackBar.error(errorList: [MyStrings.noDocOpenerApp, 'File saved at: $path']);
        }
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
    }
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      } else {
        return (await getExternalStorageDirectory())?.path ?? "";
      }
    } else if (Platform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return null;
    }
  }

  Future<String> _getToken() async {
  final headers = {
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };

  final body = jsonEncode({
    'client_id': 'ebd961c4-5000-4e12-9e15-30f40915579e',      // Remplacez par votre client_id
    'client_secret': '626c0797-b0d6-4585-886e-5062c9e09c4a', // Remplacez par votre client_secret
    'grant_type': 'client_credentials',
  });


  
  try {
    final response = await http.post(
      Uri.parse('https://openapi.airtel.africa/auth/oauth2/token'),
      headers: headers,
      body: body,
    );

     print("token1: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to obtain token');
    }
  } catch (e) {
        CustomSnackBar.error(errorList: ["Une erreur interne s'est produite"]);

    return '';
  }
}

String generateRandomId(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
}


Future<void> _payer(String token, String scannedData,) async {

  isScannerLoading = true;
    update();

  final headers = {
    'Accept': '*/*',
    'Content-Type': 'application/json',
    'X-Country': 'NE',               // Remplacez par le pays approprié
    'X-Currency': 'XOF',             // Remplacez par la devise appropriée
    'Authorization': 'Bearer $token',
    'x-signature': 'MGsp*****************Ag==',  // Remplacez par la signature appropriée
    'x-key': 'DVZC*******************NM=', 
    'x-service': 'numatechservices',       // Remplacez par la clé appropriée
  };

  final body = jsonEncode({
    'reference': 'Testing transaction',
    'subscriber': {
      'country': 'NE',            // Remplacez par le pays approprié
      'currency': 'XOF',          // Remplacez par la devise appropriée
      'msisdn': '96556984'        // Remplacez par le numéro de téléphone approprié
    },
    'transaction': {
      'amount': 1000,
      'country': 'NE',            // Remplacez par le pays approprié
      'currency': 'XOF',          // Remplacez par la devise appropriée
      'id': generateRandomId(12),   // Remplacez par un ID unique généré
    }
  });

  try {
    final response = await http.post(
      Uri.parse('https://openapi.airtel.africa/merchant/v2/payments/'),
      headers: headers,
      body: body,
    );
    print("object3");
    if (response.statusCode == 200) {
      print("object4");
      final data = jsonDecode(response.body);
      print('Response: $data');
    } else {
          CustomSnackBar.error(errorList: ['Failed to process payment. Status code: ${response.body}']);

      print('Failed to process payment. Status code: ${response.body}');
    }
  } catch (e) {
    CustomSnackBar.error(errorList: ["Une erreur interne s'est produite"]);
    print('Error: $e');
  }

     isScannerLoading = false;
    update();
}

void performPayment(String scannedData) async {
  String token = await _getToken();
  await _payer(token, scannedData);
 
}



  bool isScannerLoading = false;
  Future<bool> submitQrData({
    required String scannedData,
    String expectedType = "-1",
    String nextRouteName = "-1",
  }) async {
    isScannerLoading = true;
    update();

    bool requestStatus = false;

    ResponseModel responseModel = await qrCodeRepo.qrCodeScan(scannedData);
    
    if (responseModel.statusCode == 200) {
      QrCodeSubmitScanResponseModel scanModel = QrCodeSubmitScanResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (scanModel.status.toString().toLowerCase() == "success") {
        String userType = scanModel.data?.userType ?? "";
        String userName = scanModel.data?.userData?.username ?? "";
        String userNumber = "${scanModel.data?.userData?.mobile}";
        List<TransactionCharge>? tempTransactionCharge = scanModel.data?.transactionChargeList ?? [];
        if (expectedType != "-1") {
          if (userType.toLowerCase() == expectedType.toLowerCase()) {
            Get.offAndToNamed(nextRouteName, arguments: [userName, expectedType == 'user' ? "${scanModel.data?.userData?.dialCode}$userNumber" : userNumber]);
          } else {
            Get.back();
            String subTitle = expectedType.toLowerCase() == 'merchant'
                ? MyStrings.scanMerchantQrCode
                : expectedType.toLowerCase() == 'agent'
                    ? MyStrings.scanAgentQrCode
                    : MyStrings.scanUserQrCode;
            AppDialog().unaValableQrCode(subTitle);
          }
        } else {
          if (tempTransactionCharge.isNotEmpty) {
            if (userType.toLowerCase() == 'agent') {
              Get.offAndToNamed(RouteHelper.cashOutAmountScreen, arguments: [userName, userNumber]);
            } else if (userType.toLowerCase() == 'merchant') {
              Get.offAndToNamed(RouteHelper.makePaymentAmountScreen, arguments: [userName, userNumber]);
            } else if (userType.toLowerCase() == 'user') {
              Get.offAndToNamed(RouteHelper.sendMoneyAmountScreen, arguments: [userName, "${scanModel.data?.userData?.dialCode}$userNumber"]);
            } else {
              Get.back();
            }
          } else {
            Get.back();
            CustomSnackBar.error(errorList: [MyStrings.invalidUserType]);
          }
        }
      } else {
        Get.back();
        requestStatus = false;
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } else {
      requestStatus = false;
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isScannerLoading = false;
    update();

    return requestStatus;
  }
  //
}
