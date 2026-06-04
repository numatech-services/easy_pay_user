import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../data/controller/voucher/create_voucher_controller.dart';
import '../../../../components/bottom-sheet/bottom_sheet_header_row.dart';
import '../../../../components/buttons/gradient_rounded_button.dart';
import '../../../../components/divider/custom_divider.dart';
import '../../../../components/row_widget/bottom_sheet_row.dart';

class CreateVoucherBottomSheet extends StatelessWidget {
  const CreateVoucherBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateVoucherController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHeaderRow(header: MyStrings.paymentPreview),
            const SizedBox(height: Dimensions.space15),
            BottomSheetRow(
              header: MyStrings.totalAmount,
              body: "${StringConverter.formatNumber(controller.amountController.text)} ${controller.currency}",
            ),
            const SizedBox(height: Dimensions.space10),
            BottomSheetRow(
              header: MyStrings.totalCharge,
              body: controller.charge,
            ),
            const CustomDivider(space: Dimensions.space15),
            BottomSheetRow(
              header: MyStrings.payable,
              body: controller.payableText,
            ),
            const SizedBox(height: Dimensions.space30),
            GradientRoundedButton(
              isLoading: controller.submitLoading,
              press: () {
                controller.submitCreateVoucher();
              },
              text: MyStrings.confirm,
            ),
          ],
        );
      },
    );
  }
}
