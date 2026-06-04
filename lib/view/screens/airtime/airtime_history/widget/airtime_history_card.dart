// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:viserpay/core/helper/date_converter.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/model/airtime/airtime_history_response_model.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/image/rechange_image_widget.dart';

class AirTimeHistoryCard extends StatelessWidget {
  final VoidCallback press;
  AirtimeHistory transaction;
  String currencySym;
  AirTimeHistoryCard({
    super.key,
    required this.press,
    required this.transaction,
    required this.currencySym,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space10),
        decoration: BoxDecoration(color: MyColor.getCardBgColor(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Container(
                    height: 45,
                    width: 60,
                    alignment: Alignment.center,
                    child: RechargeImageWidget(
                      imageUrl: transaction.operator?.logoUrls?.first ?? '',
                      height: 40,
                      width: 50,
                      boxFit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: Dimensions.space10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.operator?.name ?? '',
                          style: regularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.space5),
                        SizedBox(
                          width: 150,
                          child: Text(
                            transaction.trx.toString(),
                            style: regularSmall.copyWith(color: MyColor.getTextColor().withOpacity(0.5)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: CardColumn(
                header: "$currencySym${StringConverter.formatNumber(transaction.amount.toString())}",
                body: DateConverter.convertIsoToString(transaction.createdAt ?? ""),
                isOnlyHeader: true,
                alignmentEnd: true,
                headerTextStyle: boldDefault.copyWith(
                  color: MyColor.greenSuccessColor,
                  fontSize: Dimensions.fontMediumLarge - 1,
                  fontWeight: FontWeight.w500,
                ),
                bodyTextStyle: lightMediumLarge.copyWith(color: MyColor.getGreyText(), fontSize: Dimensions.fontDefault - 1),
              ),
            )
          ],
        ),
      ),
    );
  }
}
