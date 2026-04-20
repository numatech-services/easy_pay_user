// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/contact/contact_controller.dart';
import 'package:viserpay/data/model/contact/user_contact_model.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/model/global/usercheck/user_check_response_modal.dart';
import 'package:viserpay/data/model/request_money/request_money_response_model.dart';
import 'package:viserpay/data/model/send_money/send_money_response_modal.dart';
import 'package:viserpay/data/repo/request_money/request_money_repo.dart';
import 'package:viserpay/data/model/send_money/send_money_submit_response_modal.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class MoneyRequestController extends GetxController {
  RequestMoneyRepo requestMoneyRepo;
  MoneyRequestController({required this.requestMoneyRepo});

  bool isLoading = false;
  String type_payment = "";

  TextEditingController msgController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController pinController = TextEditingController();

  FocusNode numberFocusNode = FocusNode();
  FocusNode amountFocusNode = FocusNode();
  FocusNode pinFocusNode = FocusNode();

  List<UserContactModel> recentList = [];

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

  List<String> quickAmountList = [];
  String currency = "";
  String currencySym = "";
  bool isContactPermissonEnabled = false;
  void initialValue({bool onlyClear = false}) {
    currency = requestMoneyRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = requestMoneyRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    quickAmountList = requestMoneyRepo.apiClient.getQuickAmountList();
    currentBalance = requestMoneyRepo.apiClient.getBalance();
    isLoading = true;

    amountFocusNode.unfocus();
    pinController.text = '';
    amountController.text = '';
    msgController.text = '';
    amountController.clear();
    pinController.clear();
    msgController.clear();
    // contactController.getContact();
    sendMoneyHistory.clear();
    if (!onlyClear) {
      // contactController.getContact();
      requestMoneyData();
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
  RequestedMoneyCharge? requestMoneyCharge;
  List<LatestSendMoneyHistory> sendMoneyHistory = []; //home screen history list
  List<String> otpType = [];
  String selectedOtpType = "-1";

  void selectotopType(String otpType) {
    selectedOtpType = otpType;
    update();
  }

  clearOtp() {
    selectedOtpType = "-1";
    update();
  }

  int mainAmount = 0;
  String charge = "";
  String totalCharge = "";
  String payableText = '';
   String? pass;

  void changeInfoWidget() {
    mainAmount = int.parse(amountController.text);
    update();
    // double rate = double.tryParse(sen?.currency?.rate ?? "0") ?? 0;
    double percent = double.tryParse(requestMoneyCharge?.percentCharge ?? "3") ?? 3;
    double percentCharge = mainAmount * percent / 100;
    double fixedCharge = 0;
    double tempTotalCharge = percentCharge + fixedCharge;
    // double cap = double.tryParse(requestMoneyCharge?.cap ?? "0") ?? 0;
    // double mainCap = cap;

    // if (cap != -1.0 && cap != 1 && tempTotalCharge > mainCap) {
    //   tempTotalCharge = mainCap;
    // }

    charge = StringConverter.formatNumber('$tempTotalCharge', precision: 2);
    double payable = mainAmount - tempTotalCharge;
    totalCharge = (mainAmount * percent / 100).toString();
    payableText = payableText.length > 5 ? StringConverter.roundDoubleAndRemoveTrailingZero(payable.toString()) : StringConverter.formatNumber(payable.toString());
    update();
  }

  Future<void> requestMoneyData() async {
    isLoading = true;
    isContactPermissonEnabled = await Permission.contacts.isGranted;
    update();

    ResponseModel responseModel = await requestMoneyRepo.requestMoneygetData();
    print("responseModel==========$responseModel");
    if (responseModel.statusCode == 200) {
      RequestMoneyResponseModel modal = RequestMoneyResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (modal.status == "success") {
        final data = modal.data;
        if (data != null) {
          currentBalance = data.currentBalance.toString();
          requestMoneyRepo.apiClient.storebalance(currentBalance);
          otpType.clear();
          otpType.addAll(data.otpType!.toList());
          requestMoneyCharge = data.requestMoneyCharge;
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
  Future<void> checkUserExist() async {
    isLoading = true;
    update();
    String name = '';
    if (selectedMethod == 1) {
      name = selectedContact!.number.toString();
    } else {
      name = numberController.text.toString();
    }

    ResponseModel responseModel = await requestMoneyRepo.checkUser(user: name);
    if (responseModel.statusCode == 200) {
      UserCheckResponseModal modal = UserCheckResponseModal.fromJson(jsonDecode(responseModel.responseJson));
      if (modal.status == "success") {
        if (modal.data?.user != null) {
          selectedContact = UserContactModel(name: modal.data!.user?.username?.toString() ?? '', number: modal.data!.user?.mobile?.toString() ?? '');
          Get.toNamed(RouteHelper.moneyRequestAmountScreen);
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

  Future<void> submitRequestMoney() async {
    isLoading = true;
    update();

    ResponseModel responseModel = await requestMoneyRepo.submitRequestMoney(
      amount: mainAmount.toString(),
      username: selectedMethod == 1 ? selectedContact?.number.toString() ?? "" : numberController.text,
      msg: msgController.text,
      pin: pinController.text,
      typeTicket: type_payment
    );
    if (responseModel.statusCode == 200) {
      SendMoneysubmitResponseModal modal = SendMoneysubmitResponseModal.fromJson(jsonDecode(responseModel.responseJson));
      if (modal.status == "success") {
        Get.offAllNamed(RouteHelper.bottomNavBar);
        CustomSnackBar.success(successList: modal.message?.success ?? [MyStrings.successfullSentMoneyRequest]);
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
}
