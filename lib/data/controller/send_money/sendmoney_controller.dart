// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/contact/contact_controller.dart';
import 'package:viserpay/data/model/contact/user_contact_model.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/model/global/usercheck/user_check_response_modal.dart';
import 'package:viserpay/data/model/send_money/send_money_history_response_modal.dart';
import 'package:viserpay/data/model/send_money/send_money_response_modal.dart';
import 'package:viserpay/data/repo/send_money/send_money_repo.dart';
import 'package:viserpay/data/model/send_money/send_money_submit_response_modal.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class SendMoneyContrller extends GetxController {
  SendMoneyRepo sendMoneyRepo;
  SendMoneyContrller({required this.sendMoneyRepo});

  bool isLoading = false;
  //
  TextEditingController numberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinController = TextEditingController();

  FocusNode numberFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode pinFocusNode = FocusNode();

  List<UserContactModel> recentList = [];
   String? pass;
    bool isFeesIncluded = false;
    String type_payment = "";
    String ? fullName ;
    String ? phone ;

  bool isValidNumber = false; // note: user number valid
  numberValidation(val) {
    final parse = int.tryParse(numberController.text);
    if (numberController.text.length == 11 && parse.runtimeType.toString() == "int") {
      isValidNumber = true;
      update();
    } else {
      isValidNumber = false;
      update();
    }
  }

   Future<void> saveFeeIncludedStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fees_included', value);
  }

  Future<void> loadFeeIncludedStatus() async {

      MyUtils().loadFeeIncludedStatus();

       update();
  }


  List<String> quickAmountList = [];
  String currency = "tk";
  String currencySym = "tk";
  bool isContactPermissonEnabled = false;
  void initialValue({bool onlyClear = false}) {
    page = 0;
    nextPageUrl;
    currency = sendMoneyRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = sendMoneyRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    quickAmountList = sendMoneyRepo.apiClient.getQuickAmountList();
    currentBalance = sendMoneyRepo.apiClient.getBalance();
    isLoading = true;
    amountFocusNode.unfocus();

    pinController.text = '';
    amountController.text = '';
    amountController.clear();
    pinController.clear();
   
    sendMoneyHistory.clear();
    update();
    if (!onlyClear) {
    
      sendmoneyData();
    }
    isLoading = false;
    update();
  }

  UserContactModel? selectedContact;
  int selectedMethod = -1; // note: 0 for number and 1 for contact
  void selectContact(UserContactModel contact) {
    if (contact.number.isNotEmpty) {
      selectedContact = contact;
      selectedMethod = 1;
      update();
      checkUserExist();
    } else {
      selectedContact = null;
      CustomSnackBar.error(errorList: [MyStrings.selectAValidNumber]);
    }
  }

  void changeSelectedMethod() {
    selectedMethod = 0;
    update();
  }

  String currentBalance = '0';
  SendMoneyCharge? sendMoneyCharge;
  List<LatestSendMoneyHistory> sendMoneyHistory = []; //home screen history list
  List<String> otpType = [];
  String selectedOtpType = "null";

  void selectotopType(String otpType) {
    selectedOtpType = otpType;
    update();
  }

  int mainAmount = 0;
  String charge = "";
  String totalCharge = "";
  String payableText = '';

  void changeInfoWidget() async {
    mainAmount =  int.parse(amountController.text) ;
    update();
    // double rate = double.tryParse(sen?.currency?.rate ?? "0") ?? 0;
    double percent = double.tryParse(sendMoneyCharge?.percentCharge ?? "3") ?? 3;
    double percentCharge = mainAmount * percent / 100;
    double fixedCharge = 0;
    double tempTotalCharge = percentCharge + fixedCharge;
    // double cap = double.tryParse(sendMoneyCharge?.cap ?? "0") ?? 0;
    // double mainCap = cap;

    // if (cap != -1.0 && cap != 1 && tempTotalCharge > mainCap) {
    //   tempTotalCharge = mainCap;
    // }

      // Chargez le statut de manière asynchrone
    bool? statusFeeIncluded = await MyUtils().loadFeeIncludedStatus();
   

    if (statusFeeIncluded != null && statusFeeIncluded == true) {
     int payable = mainAmount ;
      charge = StringConverter.formatNumber('$tempTotalCharge', precision: 2);
    // double payable = tempTotalCharge + mainAmount;
    totalCharge = mainAmount .toString();
    payableText = payableText.length > 5 ? StringConverter.roundDoubleAndRemoveTrailingZero(payable.toString()) : StringConverter.formatNumber(payable.toString());
    update();
    } else {
      int percentCharge = mainAmount ;
     int payable = mainAmount ;
      charge = StringConverter.formatNumber('$tempTotalCharge', precision: 2);
      
    // double payable = tempTotalCharge + mainAmount;
    totalCharge = (mainAmount * percent / 100).toString();
    payableText = payableText.length > 5 ? StringConverter.roundDoubleAndRemoveTrailingZero(payable.toString()) : StringConverter.formatNumber(payable.toString());
    update();
    }

   
  }

  Future<void> sendmoneyData() async {
    isLoading = true;
    isContactPermissonEnabled = await Permission.contacts.isGranted;
    update();
     

    ResponseModel responseModel = await sendMoneyRepo.sendMoneygetData();
    if (responseModel.statusCode == 200) {
      SendMoneyResponseModel modal = SendMoneyResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (modal.status == "success") {
        final data = modal.data;
        if (data != null) {
          currentBalance = data.currentBalance.toString();
          sendMoneyRepo.apiClient.storebalance(currentBalance);
          otpType.clear();
          otpType.addAll(data.otpType!.toList());
          sendMoneyCharge = data.sendMoneyCharge;
          if (data.latestSendMoneyHistory != null) {
            sendMoneyHistory.clear();
            sendMoneyHistory.addAll(data.latestSendMoneyHistory!.toList());
          }
          update();
        }
      } else {
        CustomSnackBar.error(errorList: modal.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  } 

// check user Exists
  Future<void> checkUserExist( {String type = "" }) async {
    isLoading = true;
    update();
    String name = '';
    if (selectedMethod == 1) {
      name = selectedContact!.number.toString();
    } else {
      name = numberController.text.toString();
    }
    ResponseModel responseModel = await sendMoneyRepo.checkUser(usernameOrmobile: name.replaceAll('+', ''), type: type_payment);
    if (responseModel.statusCode == 200) {
      UserCheckResponseModal modal = UserCheckResponseModal.fromJson(jsonDecode(responseModel.responseJson));
      if (modal.status == "success") {
        if (modal.data?.user != null) {
          isFeesIncluded = false;
          saveFeeIncludedStatus(false) ;
          update();
          selectedContact = UserContactModel(name: modal.data!.user?.username?.toString() ?? '', number: "${modal.data?.user?.dialCode}${modal.data?.user?.mobile}");
          // if(type == "send_money"){
          Get.toNamed(RouteHelper.sendMoneyAmountScreen);
          // }else{
          //   mainAmount = double.parse(amountController.text);
          //   if(mainAmount.toString().isNotEmpty && numberController.text.isNotEmpty)
          //   {
          //       fullName = "${modal.data?.user!.firstname } ${modal.data?.user!.lastname }";
          //       phone = modal.data?.user!.mobile ;
          //    submitSendMoney();

          //  }else{
          //   CustomSnackBar.error(errorList: ["Erreur de connexion"]);
          //    }
                       

          // }
        }
        // update();
      } else {
        CustomSnackBar.error(errorList: modal.message?.error ?? [MyStrings.userNotFound]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }

  Future<void> submitSendMoney() async {
    isLoading = true;
    update();

    print("amount-----------------$type_payment");
    print("otpType-----------------$otpType");
     print("usernameOrmobile-----------------${selectedContact?.number}");
      print("usernameOrmobile-----------------$selectedMethod");
      print("usernameOrmobile-----------------${numberController.text}");
      bool? statusFeeIncluded = await MyUtils().loadFeeIncludedStatus();
    ResponseModel responseModel = await sendMoneyRepo.sendMoney(
      amount: amountController.text,
      otpType: selectedOtpType,
      statusFeeIncluded:statusFeeIncluded,
       type: type_payment,
      pin: pinController.text,
      usernameOrmobile: numberController.text,
    );
    if (responseModel.statusCode == 200) {
      SendMoneysubmitResponseModal modal = SendMoneysubmitResponseModal.fromJson(jsonDecode(responseModel.responseJson));

      if (modal.status == "success") {
        Get.back();
        if (modal.data?.actionID == 'null') {
          Get.toNamed(RouteHelper.sendMoneySuccessScreen, arguments: [responseModel]);
        } else {
          Get.toNamed(
            RouteHelper.otpScreen,
            arguments: [
              modal.data?.actionID,
              RouteHelper.sendMoneySuccessScreen,
              pinController.text.toString(),
              selectedOtpType,
            ],
          );
        }
      } else {
        Get.back();
        CustomSnackBar.error(errorList: modal.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }

  bool validatePinCode() {
   MyUtils().getPassword().then((password) {
   pass = password;
  print("Mot de passe : $pass");
});
   

    if (pinController.text.length > 20) {
      MyUtils.vibrate();
      CustomSnackBar.error(errorList: [MyStrings.pinLengthErrorMessage]);
      return false;
    }

     if (pinController.text != pass ) {
      MyUtils.vibrate();
      CustomSnackBar.error(errorList: ["Mot de passe incorrect"]);
      return false;
    }
    if (pinController.text.isEmpty) {
      MyUtils.vibrate();
      CustomSnackBar.error(errorList: [MyStrings.pinErrorMessage]);
      return false;
    }

    return true;
  }

  List<LatestSendMoneyHistory> sendmoneyHistorydata = [];
  int page = 0;
  String? nextPageUrl;
  clearPageData() {
    page = 0;
    nextPageUrl = null;
    update();
  }

  // histroy
 Future<void> getSendMoneyHistory() async {
  page = page + 1;
  if (page == 1) {
    sendmoneyHistorydata.clear();
    isLoading = true;
    update();
  }
  try {
    ResponseModel responseModel = await sendMoneyRepo.history(page: page.toString());
    if (responseModel.statusCode == 200) {
      SendMoneyHistoryResponseModel model = SendMoneyHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        print(model.data?.history?.data);
        nextPageUrl = model.data?.history?.nextPageUrl;

        // Filtrer les données où remark == "send_money"
        List<LatestSendMoneyHistory> filteredData = (model.data?.history?.data ?? [])
            .where((item) => item.remark == 'send_ticket')
            .toList();

        // Ajouter uniquement les données filtrées
        sendmoneyHistorydata.addAll(filteredData);
        update();
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? []);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  } catch (e) {
    print(e.toString());
  } finally {
    isLoading = false;
    update();
  }
}
Future<void> getReceiveMoneyHistory() async {
  page = page + 1;
  if (page == 1) {
    sendmoneyHistorydata.clear();
    isLoading = true;
    update();
  }
  try {
    ResponseModel responseModel = await sendMoneyRepo.history(page: page.toString());
    if (responseModel.statusCode == 200) {
      SendMoneyHistoryResponseModel model = SendMoneyHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        print(model.data?.history?.data);
        nextPageUrl = model.data?.history?.nextPageUrl;

        // Filtrer les données où remark == "send_money"
        List<LatestSendMoneyHistory> filteredData = (model.data?.history?.data ?? [])
            .where((item) => item.remark == 'receive_ticket')
            .toList();

        // Ajouter uniquement les données filtrées
        sendmoneyHistorydata.addAll(filteredData);
        update();
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? []);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  } catch (e) {
    print(e.toString());
  } finally {
    isLoading = false;
    update();
  }
}

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }
}
