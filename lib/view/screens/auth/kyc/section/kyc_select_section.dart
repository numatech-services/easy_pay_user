import 'package:flutter/material.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import 'package:viserpay/view/components/custom_drop_down_button_with_text_field.dart';
import 'package:viserpay/view/components/text/label_text.dart';

class KycSelectSection extends StatelessWidget {
  FormModel model;
  Function onChanged;
  KycSelectSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(
          text: model.name ?? '',
          isRequired: model.isRequired == 'optional' ? false : true,
          instruction: model.instruction,
        ),
        const SizedBox(height: Dimensions.textToTextSpace),
        CustomDropDownWithTextField(
          borderWidth: .5,
          list: model.options ?? [],
          onChanged: (value) => onChanged(value),
          selectedValue: model.selectedValue,
        ),
        const SizedBox(height: Dimensions.space10)
      ],
    );
  }
}
