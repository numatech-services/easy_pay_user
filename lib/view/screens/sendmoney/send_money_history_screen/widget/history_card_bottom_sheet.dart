import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/controller/send_money/sendmoney_controller.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/divider/custom_divider.dart';
import 'package:viserpay/view/components/text/bottom_sheet_header_text.dart';

class HistoryCardBottomSheet extends StatelessWidget {
  final int index;

  const HistoryCardBottomSheet({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SendMoneyContrller>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetBar(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [BottomSheetHeaderText(text: MyStrings.details.tr), const BottomSheetCloseButton()],
          ),
          const CustomDivider(space: Dimensions.space15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                header: MyStrings.transactionId.tr,
                body: controller.sendmoneyHistorydata[index].trx ?? "",
              ),
              CardColumn(
                alignmentEnd: true,
                header: "Montant Ticket", 
                body: "cfa${StringConverter.formatNumber(controller.sendmoneyHistorydata[index].beforeCharge ?? "")}",
              )
            ],
          ),
          const SizedBox(height: Dimensions.space15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                header:"Type de ticket",
                body: "Ticket ${controller.sendmoneyHistorydata[index].ticketType} ",
              ),
              // CardColumn(
              //   header: MyStrings.finalAmount.tr,
              //   body: "${controller.currencySym}${StringConverter.formatNumber(controller.sendmoneyHistorydata[index].amount ?? "")}",
              //   alignmentEnd: true,
              // ),
            ],
          ),
          const SizedBox(height: Dimensions.space15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                header: "Ticket Restant",
                body: "tk${controller.sendmoneyHistorydata[index].postBalance ?? ""}",
              ),
              CardColumn(
                alignmentEnd: true,
                header: MyStrings.details.tr,
                body: "${controller.sendmoneyHistorydata[index].details}",
              ),
            ],
          )
        ],
      );
    });
  }
}
