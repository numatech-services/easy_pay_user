import 'package:flutter/material.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import 'package:viserpay/view/components/custom_radio_button.dart';
import 'package:viserpay/view/components/text/label_text.dart';

class KycRadioSection extends StatelessWidget {
  FormModel model;
  Function onChanged;
  int selectedIndex;
  KycRadioSection({
    super.key,
    required this.model,
    required this.onChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: model.name ?? '', isRequired: model.isRequired == 'optional' ? false : true),
        CustomRadioButton(
          title: model.name,
          selectedIndex: selectedIndex,
          list: model.options ?? [],
          onChanged: (index) => onChanged(index),
        ),
      ],
    );
  }
}
