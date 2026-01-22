import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/model/request_money/my_requset_history_response_model.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/section/request_to_me/widget/history_card_bottom_sheet.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/widget/request_money_status.dart';

import '../../../../../../../data/controller/money_request/money_request_controller.dart';
import '../../../../../../components/bottom-sheet/custom_bottom_sheet.dart';
import '../../../../../../components/divider/custom_divider.dart';
class MoneyRequestHistoryCard extends StatelessWidget {
  final MyRequest request;
  final String currencySym;
  final String currency;

  MoneyRequestHistoryCard({
    super.key,
    required this.request,
    required this.currencySym,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final receiverNameRaw = (request.receiver?.firstname ?? "") +
        " " +
        (request.receiver?.lastname ?? "");
    final receiverName =
        receiverNameRaw.trim().isNotEmpty ? receiverNameRaw : "Inconnu";

    final requestAmount = request.requestAmount != null
        ? "$currencySym${request.requestAmount!}"
        : "$currencySym-";

   

    return GetBuilder<MoneyRequestController>(builder: (controller) {
      return GestureDetector(
        onTap: () {
          CustomBottomSheet(
            child: MoneyRequestHistoryCardBottomSheet(
              request: request,
              currencySym: currencySym,
              currency: currency,
            ),
          ).customBottomSheet(context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.space15,
            horizontal: Dimensions.space10,
          ),
          decoration: BoxDecoration(
            color: MyColor.getCardBgColor(),
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MyStrings.requestTo.tr,
                    style: regularDefault.copyWith(
                      color: MyColor.getTextColor().withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    receiverName,
                    style: regularLarge.copyWith(
                      color: MyColor.getTextColor(),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const CustomDivider(space: Dimensions.space15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CardColumn(
                    header: MyStrings.amount.tr,
                    body: requestAmount,
                  ),
                  RequestMoneyStatus(status: request.status ?? '0'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
