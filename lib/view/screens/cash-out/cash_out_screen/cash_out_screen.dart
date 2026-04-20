import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_images.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/cash_out/cash_out_controller.dart';
import 'package:viserpay/data/model/contact/user_contact_model.dart';
import 'package:viserpay/data/repo/cashout/cashout_repo.dart';
import 'package:viserpay/data/services/api_service.dart';

import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/cash-card/user/user_card.dart';
import 'package:viserpay/view/components/cash-card/title_card.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/dialog/app_dialog.dart';
import 'package:viserpay/view/components/global/history_icon_widget.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';

import '../../../../core/route/route.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
    final InActivityTimer timer = InActivityTimer();
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CashoutRepo(apiClient: Get.find()));
    final controller = Get.put(CashOutController(cashoutRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialValue();
    });
    timer.startTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
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
            title: MyStrings.cashOut.tr,
            isTitleCenter: true,
            elevation: 0.03,
            action: [
              HistoryWidget(routeName: RouteHelper.cashOutHistoryScreen),
              const SizedBox(
                width: Dimensions.space20,
              ),
            ],
          ),
          body: GetBuilder<CashOutController>(builder: (controller) {
            return controller.isLoading
                ? const CustomLoader()
                : StatefulBuilder(builder: (context, setState) {
                    void filterContact(String query) {
                      setState(() {});
                    }
        
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: Dimensions.defaultPaddingHV,
                        child: Column(
                          children: [
                            CustomTextField(
                              needOutlineBorder: true,
                              inputAction: TextInputAction.done,
                              focusColor: controller.isValidNumber ? MyColor.primaryColor : MyColor.getGreyText(),
                              onChanged: (val) {
                               MyUtils().validateAndUpdateAmount(controller.amountController, val);
                              },
                              labelText: "Montant",
                              hintText: "Entrez le montant à rétirer",
                              controller: controller.amountController,
                              focusNode: controller.numberFocusNode,
                              isShowSuffixIcon: true,
                              textInputType: TextInputType.numberWithOptions(decimal: true),
                              onSubmit: ()async {
                                  int currntBalance = int.parse(controller.currentBalance);
                                if (controller.amountController.text.trim().isNotEmpty) {
                                  bool isValid = await MyUtils().balanceValidation(
                                    currentBalance: currntBalance,
                                    amount: int.tryParse(controller.amountController.text) ?? 0,
                                  );
            
                                  if (isValid) {
                                    Get.toNamed(RouteHelper.cashOutPinScreen);
                                  }
                                } else {
                                  CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
                                }
                              },
                              suffixWidget: GestureDetector(
                                onTap: () async {
                                   int currntBalance = int.parse(controller.currentBalance);
                                if (controller.amountController.text.trim().isNotEmpty) {
                                  bool isValid = await MyUtils().balanceValidation(
                                    currentBalance: currntBalance,
                                    amount: int.tryParse(controller.amountController.text) ?? 0,
                                  );
            
                                  if (isValid) {
                                    Get.toNamed(RouteHelper.cashOutPinScreen);
                                  }
                                } else {
                                  CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
                                }
                                },
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_right_alt_sharp,
                                      color: controller.isValidNumber ? MyColor.primaryColor : MyColor.getGreyText(),
                                    ),
                                  ),
                                ),
                              ),
                              
                            ),
                            const SizedBox(height: Dimensions.space2),
                            controller.numberController.text.isNotEmpty
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.info,
                                        color: MyColor.primaryColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: Dimensions.space5),
                                      Text(
                                        MyStrings.pleaseEnterNumberWithCountrycode.tr,
                                        style: regularSmall.copyWith(color: MyColor.pendingColor),
                                      )
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(
                              height: Dimensions.space16,
                            ),
                           
                            // const SizedBox(
                            //   height: Dimensions.space25,
                            // ),
                            // controller.latestCashOutHistory.isNotEmpty
                            //     ? TitleCard(
                            //         title: MyStrings.recent.tr,
                            //         widget: Column(
                            //           children: List.generate(
                            //             controller.latestCashOutHistory.length > 3 ? 3 : controller.latestCashOutHistory.length,
                            //             (i) => controller.latestCashOutHistory[i].receiverId == null
                            //                 ? const SizedBox.shrink()
                            //                 : GestureDetector(
                            //                     behavior: HitTestBehavior.translucent,
                            //                     onTap: () {
                            //                       controller.selectContact(
                            //                         UserContactModel(name: controller.latestCashOutHistory[i].receiverAgent?.username ?? '', number: controller.latestCashOutHistory[i].receiverAgent?.mobile ?? ''),
                            //                         shouldCheckUser: true,
                            //                       );
                            //                     },
                            //                     child: Container(
                            //                       margin: const EdgeInsets.symmetric(
                            //                         vertical: Dimensions.space10,
                            //                       ),
                            //                       padding: const EdgeInsets.symmetric(horizontal: 10),
                            //                       child: UserCard(
                            //                         title: controller.latestCashOutHistory[i].receiverAgent?.username ?? '',
                            //                         subtitle: controller.latestCashOutHistory[i].receiverAgent?.mobile ?? '',
                            //                       ),
                            //                     ),
                            //                   ),
                            //           ),
                            //         ),
                            //       )
                            //     : const SizedBox.shrink()
                          ],
                        ),
                      ),
                    );
                  });
          }),
        ),
      ),
    );
  }
}