import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/airtime/operator_response_model.dart';
import 'package:viserpay/data/model/authorization/authorization_response_model.dart';
import 'package:viserpay/data/model/global/user/user_model.dart';

import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/airtime/airtime_country_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../repo/airtime/airtime_repo.dart';

class AirtimeController extends GetxController {
  AirtimeRepo airtimeRepo;

  AirtimeController({required this.airtimeRepo});

  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();
  FocusNode pinFocusNode = FocusNode();

  final TextEditingController pinController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  List<Country> countryList = [];
  List<Operator> operatorsList = [];
  GlobalUser user = GlobalUser(id: -1);

  String currency = "";
  String currencySym = "";
  String currentBalance = "";
  Country selectedCountry = Country(id: -1);
  Operator selectedOperator = Operator(id: -1);

  List<String> otpType = [];
  String? selectedOtpType;

  void initialValue() {
    currency = airtimeRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = airtimeRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    otpType = [];
    loadCountryData();
  }

  void selectOtp(String? value) {
    if (value != null) {
      selectedOtpType = value;
      update();
    }
  }

  var isLoading = true;

  Future<void> loadCountryData() async {
    isLoading = true;
    update();

    ResponseModel responseModel = await airtimeRepo.getAirtimeCountry();

    if (responseModel.statusCode == 200) {
      AirtimeCountryModel model = AirtimeCountryModel.fromJson(jsonDecode(responseModel.responseJson));

      if (model.status.toString().toLowerCase() == MyStrings.success.toString().toLowerCase()) {
        List<Country>? tempCountryList = model.data?.countries;
        if (tempCountryList != null && tempCountryList.isNotEmpty) {
          countryList.clear();
          countryList.addAll(tempCountryList);
        }
        user = model.data?.user ?? GlobalUser(id: -1);
        currentBalance = model.data?.user?.balance ?? '0';
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }

    isLoading = false;
    update();
  }

  Future<void> loadOperator({required String countryId}) async {
    isLoading = true;
    update();

    ResponseModel responseModel = await airtimeRepo.getOperator(countryId: countryId);

    if (responseModel.statusCode == 200) {
      OperatorResponseModel model = OperatorResponseModel.fromJson(jsonDecode(responseModel.responseJson));

      if (model.status.toString().toLowerCase() == MyStrings.success.toString().toLowerCase()) {
        otpType = model.data?.otpType ?? [];
        List<Operator>? tempOperatorList = model.data?.oparators;
        if (tempOperatorList != null && tempOperatorList.isNotEmpty) {
          operatorsList.clear();
          operatorsList.addAll(tempOperatorList);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  setCountry(Country country) {
    selectedCountry = country;
    update();
  }

  int currentTab = 0;
  void changeAmountField(double value) {
    amountController.text = value.toString();
    update();
  }

  void onCountryTap(Country country) async {
    selectedCountry = country;
    selectedOperator = Operator(id: -1);
    currentTab = 0;
    fixAmountDescriptionList.clear();
    fixedAmountList.clear();
    suggestedAmountList.clear();

    try {
      loadOperator(countryId: country.id.toString());
      update();
      Get.back();
    } catch (e) {
      printx(e.toString());
      update();
      Get.back();
    }
  }

  List<Description> fixAmountDescriptionList = [];
  List<String> fixedAmountList = [];
  List<String> suggestedAmountList = [];
  int operatorCurrentIndex = -1;
  void onOperatorClick(Operator operator, int index) {
    selectedOperator = operator;
    operatorCurrentIndex = index;

    fixAmountDescriptionList.clear();
    fixedAmountList.clear();
    suggestedAmountList.clear();

    if (operator.fixedAmountsDescriptions != null && operator.fixedAmountsDescriptions!.isNotEmpty) {
      fixAmountDescriptionList.addAll(operator.fixedAmountsDescriptions!);
    }

    if (operator.fixedAmounts != null && operator.fixedAmounts!.isNotEmpty) {
      fixedAmountList.addAll(operator.fixedAmounts!);
    }

    if (operator.suggestedAmounts != null && operator.suggestedAmounts!.isNotEmpty) {
      suggestedAmountList.addAll(operator.suggestedAmounts!);
    }

    update();
  }

  int selectedAmountIndex = -1;
  String selectedAmount = "";

  void onSelectedAmount(int index, String amount) {
    selectedAmountIndex = index;
    selectedAmount = amount;
    update();
  }

  bool submitLoading = false;
  submitTopUp() async {
    if (selectedCountry.id == -1) {
      CustomSnackBar.error(errorList: [MyStrings.selectCountry.tr]);
      return;
    } else if (selectedOperator.id == -1) {
      CustomSnackBar.error(errorList: [MyStrings.selectOperator.tr]);
      return;
    } else if (mobileController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterPhoneNumber.tr]);
      return;
    } else if (otpType.length > 1 && selectedOtpType?.toLowerCase() == MyStrings.selectOne.toLowerCase()) {
      CustomSnackBar.error(errorList: [MyStrings.selectAuthModeMsg]);
      return;
    } else if (selectedCountry.callingCodes == null || selectedCountry.callingCodes![0].isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.callingCodeIsEmpty.tr]);
      return;
    } else if (selectedOperator.denominationType == MyStrings.fixed && selectedAmount.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.selectAmount.tr]);
      return;
    } else if (selectedOperator.denominationType == MyStrings.range && amountController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmount.tr]);
      return;
    }

    Map<String, String> model = {
      "country_id": selectedCountry.id.toString(),
      "operator_id": selectedOperator.id.toString(),
      "calling_code": selectedCountry.callingCodes![0].toString(),
      "mobile_number": mobileController.text.toString().trim(),
      "amount": getAmount(),
      "pin": pinController.text,
      "otp_type": selectedOtpType?.toLowerCase() ?? "",
    };

    submitLoading = true;
    update();

    ResponseModel responseModel = await airtimeRepo.airtimeApply(model);

    AuthorizationResponseModel topUpResponseModel = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));

    if (topUpResponseModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
      Get.back();
      if (topUpResponseModel.data?.actionId != "") {
        Get.toNamed(RouteHelper.otpScreen, arguments: [topUpResponseModel.data?.actionId, RouteHelper.airtimeHistoryScreen, selectedOtpType, ""]);
      } else {
        Get.toNamed(RouteHelper.airtimeHistoryScreen);
        CustomSnackBar.success(successList: topUpResponseModel.message?.success ?? [MyStrings.success]);
      }
    } else {
      Get.back();
      CustomSnackBar.error(errorList: topUpResponseModel.message?.error ?? [MyStrings.somethingWentWrong.tr]);
    }

    submitLoading = false;
    update();
  }

  String getAmount() {
    if (selectedOperator.denominationType == MyStrings.fixed) {
      return selectedAmount;
    } else {
      return amountController.text;
    }
  }

// balance calcualtion
  String initialOtpType = "";
  String minLimit = "";
  String maxLimit = "";
  String conversionRate = '';
  String inMethodPayable = '';

  double mainAmount = 0;
  double rate = 1;

  // pin section
  bool validatePinCode() {
    if (pinController.text.length != 4) {
      MyUtils.vibrate();
      CustomSnackBar.error(errorList: [MyStrings.pinLengthErrorMessage]);
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
