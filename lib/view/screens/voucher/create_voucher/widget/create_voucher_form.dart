import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/view/components/cash-card/balance_box_card.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../data/controller/voucher/create_voucher_controller.dart';

class CreateVoucherForm extends StatefulWidget {
  const CreateVoucherForm({super.key});

  @override
  State<CreateVoucherForm> createState() => _CreateVoucherFormState();
}

class _CreateVoucherFormState extends State<CreateVoucherForm> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateVoucherController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.space15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BalanceBoxCard(
              //   textEditingController: controller.amountController,
              //   focusNode: controller.amountFocus,
              //   onpress: () {
              //     double balance = double.tryParse(controller.currentBalance) ?? 0;
              //     double amount = double.tryParse(controller.amountController.text) ?? 0;

              //     if (MyUtils().balanceValidation(currentBalance: balance, amount: amount)) {
              //       Get.toNamed(RouteHelper.createVoucherPinScreen);
              //     }
              //   },
              // ),
              const SizedBox(height: Dimensions.textToTextSpace),
              // Text(
              //   "${MyStrings.limit.tr}: ${controller.minLimit} - ${controller.maxLimit} ${controller.currency}",
              //   style: regularExtraSmall.copyWith(color: MyColor.getPrimaryColor()),
              // )
            ],
          ),
        ],
      ),
    );
  }
}
