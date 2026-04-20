// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/repo/request_money/request_money_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:viserpay/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/card/account_details_card.dart';
import 'package:viserpay/view/components/card/cash_2colum.dart';
import 'package:viserpay/view/components/cash-card/user/user_card.dart';
import 'package:viserpay/view/components/cash-card/title_card.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/text-form-field/customPinText.dart';

import 'package:viserpay/view/components/dialog/app_dialog.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';

import '../../../../data/controller/money_request/money_request_controller.dart';

class MoneyRequestPinScreen extends StatefulWidget {
  const MoneyRequestPinScreen({super.key});
 
  @override
  State<MoneyRequestPinScreen> createState() => _MoneyRequestPinScreenState();
}

class _MoneyRequestPinScreenState extends State<MoneyRequestPinScreen> {
   final InActivityTimer timer = InActivityTimer();
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(RequestMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(MoneyRequestController(
      requestMoneyRepo: Get.find(),
      // contactController: Get.find(),
    ));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.pinController.clear();
      controller.changeInfoWidget();
    });
     timer.startTimer(context);
  }

  @override
  void dispose() {
    super.dispose();
    MyUtils.allScreen();
  }

  @override
  Widget build(BuildContext context) {
    return  NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
      child: GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
        child: Scaffold(
          backgroundColor: MyColor.colorWhite,
          appBar: CustomAppBar(
            title: MyStrings.requestMoney,
            isTitleCenter: true,
            elevation: 0.1,
          ),
          body: GetBuilder<MoneyRequestController>(
            builder: (controller) {
              return controller.isLoading
                  ? const CustomLoader()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: Dimensions.defaultPaddingHV,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TitleCard(
                              title: "${MyStrings.to.tr} ",
                              onlyBottom: true,
                              widget: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: UserCard(
                                  title: controller.selectedContact?.name ?? controller.numberController.text,
                                  subtitle: controller.selectedContact?.number.toString() ?? "",
                                  rightWidget: InkWell(
                                    onTap: () {
                                      CustomBottomSheet(child: GetBuilder<MoneyRequestController>(builder: (controller) {
                                        return Column(
                                          children: [
                                            const BottomSheetBar(),
                                            const Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [BottomSheetCloseButton()],
                                            ),
                                            const SizedBox(height: Dimensions.space15),
                                            CustomTextField(
                                              labelText: MyStrings.requestMoneyNote,
                                              needOutlineBorder: true,
                                              onChanged: (v) {},
                                              controller: controller.msgController,
                                              maxLines: 5,
                                            ),
                                            const SizedBox(height: Dimensions.space30),
                                            GradientRoundedButton(
                                              text: MyStrings.continue_,
                                              press: () {
                                                Get.back();
                                              },
                                            ),
                                            const SizedBox(height: Dimensions.space15),
                                          ],
                                        );
                                      })).customBottomSheet(context);
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
                              amount: "tk" + controller.mainAmount.toString(),
                              charge: "tk" + controller.charge,
                              total: "tk" + controller.mainAmount.toString(),
                              totalTitle: MyStrings.willGet,
                            ),
                            const SizedBox(height: Dimensions.space20),
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
                                  String newBalance = StringConverter.sum(StringConverter.formatNumber(controller.currentBalance), StringConverter.formatNumber(controller.mainAmount.toString()));
        
                                  if (controller.validatePinCode()) {
                                    submitDialog(context, controller, newBalance);
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
                                String newBalance = StringConverter.sum(StringConverter.formatNumber(controller.currentBalance), StringConverter.formatNumber(controller.mainAmount.toString()));
        
                                if (controller.validatePinCode()) {
                                  submitDialog(context, controller, newBalance);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  void submitDialog(BuildContext context, MoneyRequestController controller, String newBalance) {
    AppDialog().confirmDialog(
      context,
      title: MyStrings.requestMoney.tr,
      userDetails: UserCard(
        title: controller.selectedContact?.name ?? controller.numberController.text,
        subtitle: controller.selectedContact?.number.toString() ?? "",
      ),
      cashDetails: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.msgController.text.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
              decoration: BoxDecoration(
                color: MyColor.primaryColor.withOpacity(0.1),
                border: Border.all(color: MyColor.primaryColor, width: .5),
                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
              ),
              child: CardColumn(
                header: MyStrings.yourMeassage,
                body: controller.msgController.text.toCapitalized(),
                headerTextStyle: title.copyWith(),
                bodyTextStyle: regularDefault.copyWith(),
                bodyMaxLine: 10,
              ),
            ),
            const SizedBox(height: Dimensions.space10),
          ],
          CashDetailsColumn(
            secondTitle: '',
            hideBorder: true,
            total: "tk" + controller.mainAmount.toString(),
            newBalance: '', //controller.currencySym + newBalance,
            charge: MyUtils.getChargeText("${controller.currencySym}${controller.charge}"),
          ),
        ],
      ),
      onfinish: () {},
      onwaiting: () {
        controller.submitRequestMoney();
      },
    );
  }
}
