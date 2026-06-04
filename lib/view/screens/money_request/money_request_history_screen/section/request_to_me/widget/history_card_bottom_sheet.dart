import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/date_converter.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/model/request_money/my_requset_history_response_model.dart';

import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/divider/custom_divider.dart';
import 'package:viserpay/view/components/text/bottom_sheet_header_text.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/widget/request_money_status.dart';

import '../../../../../../components/bottom-sheet/bottom_sheet_bar.dart';

class MoneyRequestHistoryCardBottomSheet extends StatelessWidget {
  MyRequest request;
  String currencySym;
  String currency;

  MoneyRequestHistoryCardBottomSheet({
    super.key,
    required this.request,
    required this.currencySym,
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
              header: MyStrings.date.tr,
              body: DateConverter.convertIsoToString(request.createdAt ?? ""),
            ),
            RequestMoneyStatus(status: request.status ?? '0')
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardColumn(
              header: MyStrings.charge.tr,
              body: "$currencySym${StringConverter.formatNumber(request.charge ?? "")} ",
            ),
            CardColumn(
              alignmentEnd: true,
              header: MyStrings.amount.tr,
              body: "$currencySym${StringConverter.formatNumber(request.requestAmount ?? "")} ",
            ),
          ],
        ),
        const SizedBox(height: Dimensions.space15),
        if (request.note != 'null') ...[
          CardColumn(
            alignmentEnd: false,
            header: MyStrings.details.tr,
            body: request.note ?? '',
          ),
        ],
      ],
    );
  }
}
