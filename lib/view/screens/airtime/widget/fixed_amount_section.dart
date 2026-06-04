import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/controller/airtime/airtime_controller.dart';

import '../../../components/auto_height_grid_view/auto_height_grid_view.dart';
import '../../../components/text/label_text.dart';
import 'amount_widget.dart';

class FixedAmountSection extends StatelessWidget {
  const FixedAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirtimeController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.space20),
          const LabelText(
            text: MyStrings.amount,
            isRequired: true,
          ),
          const SizedBox(height: Dimensions.textToTextSpace),
          AutoHeightGridView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: controller.selectedOperator.fixedAmounts?.length ?? 0,
            mainAxisSpacing: Dimensions.space10,
            crossAxisSpacing: Dimensions.space10,
            builder: (context, index) {
              return AmountWidget(
                onTap: () {
                  controller.onSelectedAmount(index, controller.fixedAmountList[index]);
                },
                currency: controller.selectedOperator.fx?.currencyCode ?? '',
                amount: controller.fixedAmountList[index],
                description: controller.fixAmountDescriptionList[index].description,
                selectedAmount: controller.getAmount() == controller.fixedAmountList[index].toLowerCase().trim(),
              );
            },
          )
        ],
      ),
    );
  }
}
