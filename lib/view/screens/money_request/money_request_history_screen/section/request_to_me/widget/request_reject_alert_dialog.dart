import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_images.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/controller/money_request/money_request_history_controller.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_danger_button.dart';
import 'package:viserpay/view/components/divider/custom_divider.dart';

class RequestRejectAlertDialog extends StatelessWidget {
  final int index;
  const RequestRejectAlertDialog({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MoneyRequestHistoryController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: Dimensions.space10),
          Align(alignment: Alignment.center, child: Image.asset(MyImages.rejectImage, height: 50, width: 50)),
          const SizedBox(height: Dimensions.space10),
          Align(
            alignment: Alignment.center,
            child: Text(
              MyStrings.areYouSureReject,
              style: regularLarge.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const CustomDivider(space: Dimensions.space20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GradientRoundedButton(
                  horizontalPadding: 4,
                  verticalPadding: 4,
                  text: MyStrings.cancel,
                  press: () {
                    Get.back();
                  },
                ),
              ),
              const SizedBox(width: Dimensions.space15),
              Expanded(
                child: GradientRoundedDangerButton(
                  text: MyStrings.reject,
                  horizontalPadding: 4,
                  verticalPadding: 4,
                  showLoadingIcon: false,
                  press: () {
                    Get.back();
                    controller.rejecRequest(id: controller.requestToMeList[index].id.toString(), index: index);
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: Dimensions.space20),
        ],
      ),
    );
  }
}
