import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/date_converter.dart';
import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/util.dart';
import '../../../../../data/controller/voucher/redeem_log_controller.dart';
import '../../../../components/column_widget/card_column.dart';
import '../../../../components/divider/custom_divider.dart';
import '../../../../components/text/default_text.dart';

class RedeemLogCard extends StatelessWidget {
  final int index;
  final String currency;
  const RedeemLogCard({
    super.key,
    required this.index,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RedeemLogController>(
      builder: (controller) => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
        decoration: BoxDecoration(color: MyColor.getCardBgColor(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius), boxShadow: MyUtils.getCardShadow()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [DefaultText(text: MyStrings.voucherCode.tr, textColor: MyColor.getLabelTextColor().withOpacity(0.6)), const SizedBox(height: Dimensions.space5), DefaultText(text: controller.redeemLogList[index].voucherCode ?? "", textColor: MyColor.getTextColor())],
            ),
            const CustomDivider(space: Dimensions.space15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CardColumn(
                  header: MyStrings.amount.tr,
                  body: "$currency${StringConverter.formatNumber(controller.redeemLogList[index].amount ?? "")}",
                ),
                CardColumn(
                  alignmentEnd: true,
                  header: MyStrings.usedAt.tr,
                  body: DateConverter.isoStringToLocalDateOnly(controller.redeemLogList[index].createdAt ?? ""),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
