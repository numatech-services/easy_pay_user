// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/money_request/money_request_history_controller.dart';
import 'package:viserpay/data/repo/request_money/request_money_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:viserpay/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:viserpay/view/components/card/account_details_card.dart';
import 'package:viserpay/view/components/card/cash_2colum.dart';
import 'package:viserpay/view/components/cash-card/user/user_card.dart';
import 'package:viserpay/view/components/cash-card/title_card.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:viserpay/view/components/text-form-field/customPinText.dart';

import 'package:viserpay/view/components/dialog/app_dialog.dart';

class AcceptRequstMoneyPinScreen extends StatefulWidget {
  const AcceptRequstMoneyPinScreen({super.key});
 
  @override
  State<AcceptRequstMoneyPinScreen> createState() => _AcceptRequstMoneyPinScreenState();
}

class _AcceptRequstMoneyPinScreenState extends State<AcceptRequstMoneyPinScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(RequestMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(MoneyRequestHistoryController(moneyRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (Get.arguments != null) {
        controller.changeRequset(Get.arguments);
      } else {
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    MyUtils.allScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorWhite,
      appBar: CustomAppBar(
        title: MyStrings.requestMoney,
        isTitleCenter: true,
        elevation: 0.1,
      ),
      body: GetBuilder<MoneyRequestHistoryController>(
        builder: (controller) {
          return controller.isLoading
              ? const CustomLoader()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: Dimensions.defaultPaddingHV,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleCard(
                          title: "${MyStrings.requestFrom.tr} ",
                          onlyBottom: true,
                          widget: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: UserCard(
                              title: '${controller.requestToMe.sender?.firstname} ${controller.requestToMe.sender?.lastname}',
                              subtitle: "${controller.requestToMe.sender?.dialCode}${controller.requestToMe.sender?.mobile}",
                              rightWidget: InkWell(
                                onTap: () {
                                  CustomBottomSheet(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const BottomSheetBar(),
                                      const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [BottomSheetCloseButton()],
                                      ),
                                      const SizedBox(height: Dimensions.space15),
                                      CardColumn(
                                        header: MyStrings.userMeassge,
                                        body: controller.requestToMe.note ?? '--',
                                        headerTextStyle: title.copyWith(),
                                        bodyTextStyle: regularDefault.copyWith(color: MyColor.contentTextColor),
                                        bodyMaxLine: 15,
                                        space: 10,
                                      ),
                                      const SizedBox(height: Dimensions.space15),
                                    ],
                                  )).customBottomSheet(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: MyColor.primaryColor,
                                  ),
                                  child: const Icon(Icons.chat, color: MyColor.colorWhite, size: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space16),
                        AccountDetailsCard(
                          amount: 'tk${controller.requestToMe.requestAmount.toString()}',
                          charge: 'tk${StringConverter.formatNumber(controller.requestToMe.charge.toString())}',
                          total: 'tk${controller.requestToMe.requestAmount.toString()}',
                        ),
                        const SizedBox(height: Dimensions.space20),
                        if (controller.otpType.isNotEmpty) ...[
                          Text(MyStrings.selectOtpType.tr, style: mediumDefault.copyWith()),
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: List.generate(
                                controller.otpType.length,
                                (index) => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: controller.selectedOtpType == controller.otpType[index] ? true : false,
                                          onChanged: (p) {
                                            controller.selectotopType(controller.otpType[index]);
                                          },
                                          shape: const CircleBorder(),
                                          activeColor: MyColor.primaryDark,
                                        ),
                                        Text(
                                          controller.otpType[index].toUpperCase(),
                                          style: semiBoldDefault.copyWith(
                                            color: controller.selectedOtpType.toLowerCase() == controller.otpType[index].toLowerCase() ? MyColor.colorBlack : MyColor.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        CustomPinField(
                          onChanged: (p) {
                            MyUtils.vibrate();
                          },
                          controller: controller.pinController,
                          focusNode: controller.pinFocusNode,
                          needOutlineBorder: true,
                          labelText: "",
                          hintText: MyStrings.enterYourPIN,
                          isShowSuffixIcon: true,
                          textInputType: TextInputType.text,
                          inputAction: TextInputAction.done,
                          prefixicon: const SizedBox(
                            width: 22,
                            height: 22,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.lock,
                                color: MyColor.primaryColor,
                              ),
                            ),
                          ),
                          suffixWidget: GestureDetector(
                            onTap: () {
                            int newBalance = int.parse(controller.currentBalance) - int.parse(controller.requestToMe.requestAmount.toString());
                              if (controller.otpType.isEmpty) {
                                if (controller.validatePinCode()) {
                                  submitDialog(context, controller, newBalance.toString());
                                }
                              } else {
                                if (controller.validatePinCode() == true) {
                                  if (controller.selectedOtpType == 'null' || controller.selectedOtpType == "-1") {
                                    CustomSnackBar.error(errorList: [MyStrings.pleaseSelectOtp.tr]);
                                  } else {
                                    submitDialog(context, controller, newBalance.toString());
                                  }
                                }
                              }
                            },
                            child: const SizedBox(
                              width: 22,
                              height: 22,
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.arrow_right_alt_sharp,
                                  color: MyColor.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          onSubmit: () {
                            int newBalance = int.parse(controller.currentBalance) - int.parse(controller.requestToMe.requestAmount.toString());
                            printx('newBalance $newBalance');
                            printx('newBalance ${controller.selectedOtpType}');
                            if (controller.otpType.isEmpty) {
                              if (controller.validatePinCode()) {
                                submitDialog(context, controller, newBalance.toString());
                              }
                            } else {
                              if (controller.validatePinCode() == true) {
                                if (controller.selectedOtpType == 'null' || controller.selectedOtpType == "-1") {
                                  CustomSnackBar.error(errorList: [MyStrings.pleaseSelectOtp.tr]);
                                } else {
                                  submitDialog(context, controller, newBalance.toString());
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  void submitDialog(BuildContext context, MoneyRequestHistoryController controller, String newBalance) {
    AppDialog().confirmDialog(
      context,
      title: MyStrings.acceptRequestMoney.tr,
      userDetails: UserCard(
        title: '${controller.requestToMe.sender?.firstname} ${controller.requestToMe.sender?.lastname}',
        subtitle: "${controller.requestToMe.sender?.dialCode}${controller.requestToMe.sender?.mobile}",
      ),
      cashDetails: CashDetailsColumn(
        secondTitle: MyStrings.newBalance,
        total: 'tk${controller.requestToMe.requestAmount.toString()}',
        newBalance: "tk" + newBalance,
        charge: MyUtils.getChargeText("tk${controller.requestToMe.charge.toString()}"),
      ),
      onfinish: () {},
      onwaiting: () {
        controller.acceptRequest(id: controller.requestToMe.id ?? '');
      },
    );
  }
}
