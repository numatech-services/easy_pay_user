import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/global/user/user_model.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/bottom-sheet/custom_bottom_sheet.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../../view/screens/voucher/create_voucher/widget/create_voucher_bottom_sheet.dart';
import '../../model/authorization/authorization_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/voucher/create_voucher_response_model.dart';
import '../../repo/voucher/create_voucher_repo.dart';

class CreateVoucherController extends GetxController {
  CreateVoucherRepo createVoucherRepo;
  CreateVoucherController({required this.createVoucherRepo});

  bool isLoading = false;
  String currency = "";
  String currencySym = "";
  String currentBalance = "";

  CreateVoucherResponseModel model = CreateVoucherResponseModel();

  String selectedOtp = "";
  String amount = "";

  String minLimit = "";
  String maxLimit = "";

  TextEditingController amountController = TextEditingController();
  TextEditingController pinController = TextEditingController();

  FocusNode pinFocusNode = FocusNode();
  FocusNode amountFocus = FocusNode();

  List<String> otpTypeList = [];
  GlobalUser user = GlobalUser(id: -1);

  setSelectedOtp(String? otp) {
    selectedOtp = otp ?? "";
    update();
  }

  VoucherCharge? voucherCharge;
  Future<void> loadData() async {
    currency = createVoucherRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = createVoucherRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    isLoading = true;
    otpTypeList.clear();
    amountController.text = "";
    update();

    ResponseModel responseModel = await createVoucherRepo.getCreateVoucherData();
    if (responseModel.statusCode == 200) {
      model = CreateVoucherResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        voucherCharge = model.data?.voucherCharge;
        currentBalance = model.data?.user?.balance ?? '0.0';
        user = model.data?.user ?? GlobalUser(id: -1);
        minLimit = StringConverter.formatNumber(model.data?.voucherCharge?.minLimit ?? '');
        maxLimit = StringConverter.formatNumber(model.data?.voucherCharge?.maxLimit ?? '');
        List<String>? tempOtpList = model.data?.otpType;
        if (tempOtpList != null || tempOtpList!.isNotEmpty) {
          otpTypeList.addAll(tempOtpList);
        }
        if (tempOtpList.isNotEmpty) {
          selectedOtp = otpTypeList[0];
          setSelectedOtp(selectedOtp);
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

  bool submitLoading = false;
  Future<void> submitCreateVoucher() async {
    submitLoading = true;
    update();

    String amount = amountController.text;
    if (otpTypeList.length > 1) {
      if (selectedOtp.toLowerCase().toString() == MyStrings.selectOne) {
        CustomSnackBar.error(errorList: [MyStrings.selectOtpType]);
      }
    }
    String otpType = selectedOtp.toLowerCase().toString();

    ResponseModel response = await createVoucherRepo.submitCreateVoucher(amount: amount, otpType: otpType, pin: pinController.text);
    if (response.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == 'success') {
        String actionId = model.data?.actionId ?? '';
        Get.back();
        if (actionId.isNotEmpty) {
          printx(actionId);

          Get.toNamed(RouteHelper.otpScreen, arguments: [
            actionId,
            RouteHelper.myVoucherScreen,
            otpType,
            otpType,
          ]);
        } else {
          CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
          Get.toNamed(RouteHelper.myVoucherScreen);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    submitLoading = false;
    update();
  }

  double mainAmount = 0;
  String charge = "";
  String totalCharge = "";
  String payableText = '';

  void changeInfoWidget() {
    mainAmount = double.tryParse(amountController.text) ?? 0.0;
    double percent = double.tryParse(voucherCharge?.percentCharge ?? "0") ?? 0;
    double percentCharge = mainAmount * percent / 100;
    double fixedCharge = double.tryParse(voucherCharge?.fixedCharge ?? "0") ?? 0;
    double tempTotalCharge = percentCharge + fixedCharge;
    double cap = double.tryParse(voucherCharge?.cap ?? "0") ?? 0;
    double mainCap = cap;

    if (cap != -1.0 && cap != 1 && tempTotalCharge > mainCap) {
      tempTotalCharge = mainCap;
    }

    charge = StringConverter.formatNumber('$tempTotalCharge', precision: 2);
    double payable = tempTotalCharge + mainAmount;
    totalCharge = (mainAmount * percent / 100).toString();
    payableText = payableText.length > 5 ? StringConverter.roundDoubleAndRemoveTrailingZero(payable.toString()) : StringConverter.formatNumber(payable.toString());
    update();
  }

  void checkAndShowPreviewBottomSheet(BuildContext context) {
    if (amountController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmountMsg]);
      return;
    } else {
      CustomBottomSheet(child: const CreateVoucherBottomSheet()).customBottomSheet(context);
    }
  }

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
