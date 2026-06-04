import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/data/controller/airtime/airtime_controller.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../components/form_row.dart';
import '../../../components/snack_bar/show_custom_snackbar.dart';
import 'operator_widget.dart';

class OperatorSection extends StatelessWidget {
  const OperatorSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirtimeController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.space16),
          const FormRow(label: MyStrings.mobileOperator, isRequired: true),
          const SizedBox(
            height: Dimensions.space8,
          ),
          OperatorWidget(
            title: controller.selectedOperator.id == -1 ? MyStrings.selectOperator.tr : controller.selectedOperator.name,
            image: controller.selectedOperator.logoUrls?.first ?? "",
            onTap: () {
              if (controller.selectedCountry.id == -1) {
                CustomSnackBar.error(errorList: [MyStrings.selectCountryFirst.tr]);
              } else {
                // Get.toNamed(RouteHelper.selectOperatorScreen, arguments: controller.selectedCountry.id.toString());
              }
            },
            isShowChangeButton: false,
          ),
          const SizedBox(height: Dimensions.space16),
        ],
      ),
    );
  }
}
