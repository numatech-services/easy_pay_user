import 'package:flutter/material.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import 'package:viserpay/view/components/checkbox/custom_check_box.dart';
import 'package:viserpay/view/components/text/label_text.dart';

class KycCheckBoxSection extends StatelessWidget {
  FormModel model;
  Function onChanged;
  List<String>? selectedValue;
  KycCheckBoxSection({
    super.key,
    required this.model,
    required this.onChanged,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: model.name ?? '', isRequired: model.isRequired == 'optional' ? false : true, instruction: model.instruction),
        CustomCheckBox(
          selectedValue: selectedValue,
          list: model.options ?? [],
          onChanged: (value) => onChanged(value),
        ),
      ],
    );
  }
}
