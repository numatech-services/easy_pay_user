import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/date_converter.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/model/airtime/airtime_history_response_model.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/divider/custom_divider.dart';
import 'package:viserpay/view/components/text/bottom_sheet_header_text.dart';

class AirtimeHistoryBottomSheet extends StatelessWidget {
  final AirtimeHistory data;
  final String currency;
  const AirtimeHistoryBottomSheet({
    super.key,
    required this.data,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
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
              body: data.trx ?? "",
            ),
            CardColumn(
              alignmentEnd: true,
              header: MyStrings.date.tr,
              body: DateConverter.convertIsoToString(data.createdAt ?? ""),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardColumn(
              header: MyStrings.amount.tr,
              body: "$currency ${StringConverter.formatNumber(data.beforeCharge ?? "")}",
            ),
            CardColumn(
              alignmentEnd: true,
              header: MyStrings.charge.tr,
              body: "$currency ${StringConverter.formatNumber(data.charge ?? "")}",
            ),
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardColumn(
              header: MyStrings.finalAmount.tr,
              body: "$currency ${StringConverter.formatNumber(data.amount ?? "")}",
            ),
            CardColumn(
              alignmentEnd: true,
              header: MyStrings.remainingBalance.tr,
              body: "$currency ${StringConverter.formatNumber(data.postBalance ?? "")}",
            ),
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardColumn(
              header: MyStrings.mobileNumber.tr,
              body: "+${data.details?.split('+').last ?? ''}",
            ),
            CardColumn(
              header: MyStrings.mobileOperator.tr,
              body: "${(data.operator?.name ?? "")} ",
              alignmentEnd: true,
            ),
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        CardColumn(
          header: MyStrings.details.tr,
          body: "${(data.details ?? "")} ",
          bodyMaxLine: 80,
        ),
      ],
    );
  }
}
