// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/date_converter.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/controller/cash_out/cash_out_controller.dart';
import 'package:viserpay/data/model/cash_out/cash_out_response_modal.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/image/my_image_widget.dart';

class CashOutHistoryCard extends StatelessWidget {
  final int index;
  final VoidCallback press;
  final LatestCashOutHistory transaction;
  final String currencySym;
  CashOutHistoryCard({
    super.key,
    required this.index,
    required this.press,
    required this.transaction,
    required this.currencySym,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashOutController>(builder: (controller) {
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
                child: Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      alignment: Alignment.center,
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: transaction.trxType == "-" ? MyColor.colorRed.withOpacity(0.2) : MyColor.colorGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: MyImageWidget(
                          imageUrl: transaction.receiverAgent?.getImage.toString() ?? '',
                          radius: 50,
                          isProfile: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${transaction.remark}".replaceAll("_", " ").toTitleCase().tr,
                          style: regularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.space5),

                        
                        Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: transaction.status.toString() == "1"
                                    ? Colors.green.withOpacity(0.2)
                                    : transaction.status.toString() == "3"
                                        ? Colors.orange.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                transaction.status.toString() == "1"
                                    ? "Envoyé"
                                    : transaction.status.toString() == "3"
                                        ? "Annulée"
                                        : "Rétiré",
                                style: TextStyle(
                                  color: transaction.status.toString() == "1"
                                      ? Colors.green
                                      : transaction.status.toString() == "3"
                                          ? Colors.orange
                                          : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            ,

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
                  ),

                  ],
                ),
              ),
              Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      CardColumn(
        header: "${transaction.trxType}$currencySym${StringConverter.formatNumber(transaction.amount.toString())}",
        body: DateConverter.formatDateMonthYear(transaction.createdAt.toString()),
        alignmentEnd: true,
        headerTextStyle: boldDefault.copyWith(
          color: transaction.trxType == "-" ? MyColor.colorRed : MyColor.colorGreen,
          fontSize: Dimensions.fontMediumLarge - 1,
          fontWeight: FontWeight.w500,
        ),
        bodyTextStyle: lightMediumLarge.copyWith(color: MyColor.getGreyText(), fontSize: Dimensions.fontDefault - 1),
      ),
      if (transaction.status.toString() == "1")
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child:ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Confirmation"),
          content: const Text("Voulez-vous vraiment annuler cette transaction ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Non", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Oui", style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.of(context).pop(); 

                controller.submitCashOutCanceling(transaction.id.toString());
              },
            ),
          ],
        );
      },
    );
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    textStyle: const TextStyle(fontSize: 12),
  ),
  child: const Text("Annuler"),
),

        ),
    ],
  ),
),

            ],
          ),
        ),
      );
    });
  }
}
