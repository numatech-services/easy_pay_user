// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/money_request/money_request_history_controller.dart';
import 'package:viserpay/data/model/request_money/request_to_me_response_model.dart';
import 'package:viserpay/view/components/alert-dialog/custom_alert_dialog.dart';
import 'package:viserpay/view/components/buttons/card_button.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/divider/custom_divider.dart';
import 'package:viserpay/view/components/image/my_image_widget.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/section/request_to_me/widget/request_reject_alert_dialog.dart';

class RequestToMeCard extends StatelessWidget {
  final int index;
  final VoidCallback press;
  RequestToMe requestData;
  String currencySym;
  RequestToMeCard({
    super.key,
    required this.index,
    required this.press,
    required this.requestData,
    required this.currencySym,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MoneyRequestHistoryController>(
      builder: (controller) {
        return GestureDetector(
          onTap: press,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space10),
            decoration: BoxDecoration(color: MyColor.getCardBgColor(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(MyStrings.requestFrom.tr, style: regularDefault.copyWith()),
                const SizedBox(height: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MyImageWidget(
                          imageUrl: '${requestData.sender?.getImage}',
                          height: 35,
                          width: 35,
                          radius: 5,
                          isProfile: true,
                        ),
                        const SizedBox(width: Dimensions.space10),
                        CardColumn(
                          header: "${requestData.sender?.firstname ?? "-"} ${requestData.sender?.lastname ?? "-"}".toTitleCase(),
                          headerTextStyle: regularLarge.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w500),
                          body: (requestData.sender?.username ?? "-").toTitleCase(),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        "${requestData.requestAmount ?? '0'} $currencySym",
                        style: boldExtraLarge.copyWith(color: MyColor.primaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
                const CustomDivider(space: 0),
                const SizedBox(height: Dimensions.space10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CardButton(
                      isText: false,
                      bgColor: MyColor.colorRed,
                      icon: Icons.highlight_off,
                      isLoading: controller.selectedIndex == index,
                      press: () {
                        printx(requestData.id);
                        controller.clearOtpType();
                        CustomAlertDialog(isHorizontalPadding: true, child: RequestRejectAlertDialog(index: index)).customAlertDialog(context);
                      },
                    ),
                    const SizedBox(width: Dimensions.space10),
                  CardButton(
                      isText: false,
                      bgColor: MyColor.colorGreen,
                      icon: Icons.done_all,
                      press: () async {
                        controller.clearOtpType();

                        int balance = int.tryParse(controller.currentBalance) ?? 0;
                        int amount = int.tryParse(requestData.requestAmount.toString()) ?? 0;

                        // Attendre le résultat de balanceValidation
                        bool isValid = await MyUtils().balanceValidation(
                          currentBalance: balance,
                          amount: amount,
                        );

                        if (isValid) {
                         await Get.toNamed(RouteHelper.moneyRequestAcceptPinScreen, arguments: requestData);
                        } else {
                          // Message d'erreur géré dans balanceValidation
                        }
                      },
                    ),

                        // CustomBottomSheet(
                        //   child: GetBuilder<MoneyRequestHistoryController>(
                        //     builder: (requestController) => Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             BottomSheetHeaderText(text: MyStrings.sureToConfirm.tr),
                        //             const BottomSheetCloseButton(),
                        //           ],
                        //         ),
                        //         const SizedBox(height: Dimensions.space20),
                        //         Text(
                        //           "${StringConverter.formatNumber(requestData.requestAmount ?? "")} "
                        //           "$currencySym "
                        //           "${MyStrings.willBeReduced} ${MyStrings.availableBalance.toLowerCase()}.",
                        //           textAlign: TextAlign.center,
                        //           style: regularLarge.copyWith(color: MyColor.colorBlack.withOpacity(0.5)),
                        //         ),
                        //         const SizedBox(height: Dimensions.space20),
                        //         if (controller.otpType.isNotEmpty) ...[
                        //           const SizedBox(height: Dimensions.space20),
                        //           Text(MyStrings.selectOtpType.tr, style: mediumDefault.copyWith()),
                        //           const SizedBox(height: Dimensions.space10),
                        //           SingleChildScrollView(
                        //             physics: const BouncingScrollPhysics(),
                        //             scrollDirection: Axis.horizontal,
                        //             padding: EdgeInsets.zero,
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.start,
                        //               children: List.generate(
                        //                 controller.otpType.length,
                        //                 (index) => Row(
                        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //                   children: [
                        //                     Row(
                        //                       children: [
                        //                         Checkbox(
                        //                           value: controller.selectedOtpType == controller.otpType[index] ? true : false,
                        //                           onChanged: (p) {
                        //                             controller.selectotopType(controller.otpType[index]);
                        //                           },
                        //                           shape: const CircleBorder(),
                        //                           activeColor: MyColor.primaryDark,
                        //                         ),
                        //                         Text(
                        //                           controller.otpType[index].toUpperCase(),
                        //                           style: semiBoldDefault.copyWith(
                        //                             color: controller.selectedOtpType.toLowerCase() == controller.otpType[index].toLowerCase() ? MyColor.colorBlack : MyColor.primaryDark,
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //           )
                        //         ],
                        //         const SizedBox(height: Dimensions.space20),
                        //         GradientRoundedButton(
                        //             text: MyStrings.confirm,
                        //             isLoading: controller.isSubmitLoading,
                        //             press: () {
                        //               controller.acceptRequest(id: requestData.id ?? '-1');
                        //             }),
                        //       ],
                        //     ),
                        //   ),
                        // ).customBottomSheet(context);
                     
                   
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
