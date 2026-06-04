import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/data/controller/airtime/airtime_controller.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../components/text/label_text.dart';

class AmountInputByUserSection extends StatelessWidget {
  const AmountInputByUserSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirtimeController>(
        builder: (controller) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.space20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(MyStrings.amount.tr, style: regularDefault),
                    Text(" *", style: regularDefault.copyWith(color: MyColor.redCancelTextColor)),
                    Expanded(
                      child: Text(
                        " (${MyStrings.minAmount.tr} ${controller.currencySym}"
                        "${controller.selectedOperator.localMinAmount} & ${MyStrings.maxAmount.tr} "
                        "${controller.currencySym}${controller.selectedOperator.localMaxAmount})",
                        style: regularSmall.copyWith(color: MyColor.primaryColor.withOpacity(.7)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.textToTextSpace),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: MyColor.getTextFieldDisableBorder(), width: .5),
                    borderRadius: BorderRadius.circular(10),
                    color: MyColor.colorWhite,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
                  child: TextFormField(
                    controller: controller.amountController,
                    focusNode: controller.amountFocusNode,
                    onChanged: (value) {
                      controller.getAmount();
                    },
                    decoration: InputDecoration(
                      suffixIcon: IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.space5),
                          decoration: BoxDecoration(color: MyColor.getPrimaryColor().withOpacity(0.05), borderRadius: BorderRadius.circular(5)),
                          alignment: Alignment.center,
                          child: Text(controller.currency, textAlign: TextAlign.center, style: regularDefault.copyWith(color: MyColor.getPrimaryColor(), fontWeight: FontWeight.w500)),
                        ),
                      ),
                      hintText: MyStrings.enterAmount,
                      border: InputBorder.none, // Remove border
                      filled: false, // Remove fill
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      hintStyle: regularMediumLarge.copyWith(color: MyColor.hintTextColor),
                    ),
                    keyboardType: TextInputType.phone, // Set keyboard type to phone
                    style: regularMediumLarge,
                    cursorColor: MyColor.primaryColor, // Set cursor color to red
                    validator: (value) {
                      if (value!.isEmpty) {
                        return;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.space15),
                const LabelText(text: MyStrings.suggestedAmounts, isRequired: false),
                const SizedBox(height: Dimensions.textToTextSpace),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(controller.selectedOperator.suggestedAmounts?.length ?? 0, (index) {
                          return GestureDetector(
                            onTap: () {
                              double amount = double.tryParse(controller.selectedOperator.suggestedAmounts?[index].toString() ?? '0') ?? 0;
                              controller.changeAmountField(amount);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: MyColor.primaryColor.withOpacity(0.2)), color: MyColor.colorWhite),
                              child: Text(
                                "${controller.selectedOperator.suggestedAmounts?[index]} ${controller.currency}",
                                style: regularLarge.copyWith(color: MyColor.primaryColor.withOpacity(0.8)),
                              ),
                            ),
                          );
                        })),
                  ),
                ),
                const SizedBox(height: Dimensions.space15),
              ],
            ));
  }
}
