import 'package:flutter/material.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';
import 'package:get/get.dart';

class KycTextAnEmailSection extends StatelessWidget {
  FormModel model;
  Function onChanged;

  KycTextAnEmailSection({
    super.key,
    required this.onChanged,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          isRequired: model.isRequired == 'optional' ? false : true,
          instruction: model.instruction,
          hintText: '',
          needOutlineBorder: true,
          labelText: model.name ?? '',
          textInputType: MyUtils.getInputTextFieldType(model.type ?? 'text'),
          validator: (value) {
            if (model.isRequired != 'optional' && value.toString().isEmpty) {
              return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
            } else {
              return null;
            }
          },
          onChanged: (value) => onChanged(value),
          maxLines: model.type == "textarea" ? 5 : 1,
        ),
        const SizedBox(height: Dimensions.space10),
      ],
    );
  }
}
