import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/authorization/authorization_response_model.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/model/request_money/my_requset_history_response_model.dart';
import 'package:viserpay/data/model/request_money/request_to_me_response_model.dart';
import 'package:viserpay/data/repo/request_money/request_money_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class MoneyRequestHistoryController extends GetxController {
  RequestMoneyRepo moneyRepo;
  MoneyRequestHistoryController({required this.moneyRepo});

  bool isLoading = false;
  int currentTab = 0;
  int page = 0;

  String currency = '';
  String currencySym = '';
  String currentBalance = '';

  TextEditingController pinController = TextEditingController();
  FocusNode pinFocusNode = FocusNode();

  String? nextPageUrl;
  List<String> otpType = [];
  List<MyRequest> myRequestList = [];
  List<RequestToMe> requestToMeList = [];
  String selectedOtpType = "-1";
  void selectotopType(String otpType) {
    selectedOtpType = otpType;
    update();
  }

  clearOtpType() {
    selectedOtpType = "-1";
    update();
  }

  void initailValue() async {
    currency = moneyRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = moneyRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    currentBalance = moneyRepo.apiClient.getBalance();
    otpType.clear();
    changeTab(tab: 0);
  }

  void getMyRequestHistoryList() async {
    page = page + 1;
    if (page == 1) {
      myRequestList.clear();
    }
    try {
      ResponseModel responseModel = await moneyRepo.getMyRequestHistory(page.toString());
      if (responseModel.statusCode == 200) {
        MyRequestMoneyHistoryResponseModel model = MyRequestMoneyHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          nextPageUrl = model.data?.requests?.nextPageUrl;
           myRequestList.addAll(model.data?.requests?.data?.reversed ?? []);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void getRequestToMeHistoryList() async {
    page = page + 1;
    if (page == 1) {
      requestToMeList.clear();
    }
    try {
      ResponseModel responseModel = await moneyRepo.getRequestToMeHistory(page.toString());
      if (responseModel.statusCode == 200) {
        RequesToMeMoneyHistoryResponseModel model = RequesToMeMoneyHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          nextPageUrl = model.data?.requests?.nextPageUrl;
          requestToMeList.addAll(model.data?.requests?.data ?? []);
          otpType.clear();
          otpType.addAll(model.data?.otpType ?? []);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  RequestToMe requestToMe = RequestToMe(id: '-1');
  changeRequset(RequestToMe req) {
    requestToMe = req;
    update();
  }

  bool isSubmitLoading = false;
  void acceptRequest({required String id}) async {
    if (otpType.isNotEmpty) {
      if (selectedOtpType == "-1") {
        CustomSnackBar.error(errorList: [MyStrings.selectOtpType]);
        return;
      }
    }
    isSubmitLoading = true;
    update();

    try {
      ResponseModel responseModel = await moneyRepo.acceptRequest(id: id, otpType: selectedOtpType, pin: pinController.text);
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          if (model.data?.actionId != null) {
            Get.toNamed(RouteHelper.otpScreen, arguments: [
              model.data?.actionId,
              RouteHelper.bottomNavBar,
              selectedOtpType,
              selectedOtpType,
            ]);
          } else {
            Get.offAllNamed(RouteHelper.bottomNavBar);
            CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.succeed]);
          }
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }
    isSubmitLoading = false;
    update();
  }

  int selectedIndex = -1;
  void rejecRequest({
    required String id,
    required int index,
  }) async {
    selectedIndex = index;
    update();

    try {
      ResponseModel responseModel = await moneyRepo.rejectRequest(id: id, otpType: selectedOtpType);
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          if (model.data?.actionId != null) {
            Get.toNamed(RouteHelper.otpScreen, arguments: [
              model.data?.actionId,
              RouteHelper.bottomNavBar,
              selectedOtpType,
              selectedOtpType,
            ]);
          } else {
            clearOtpType();
            changeTab(tab: 1);
            CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.succeed]);
          }
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }

    selectedIndex = -1;
    update();
  }

  changeTab({required int tab}) {
    currentTab = tab;
    page = 0;
    nextPageUrl;
    requestToMeList = [];
    myRequestList = [];
    isLoading = true;
    update();
    if (currentTab == 0) {
      getMyRequestHistoryList();
    } else {
      getRequestToMeHistoryList();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  String ? pass;
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
