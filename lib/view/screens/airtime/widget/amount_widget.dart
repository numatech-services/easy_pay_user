import 'package:flutter/material.dart';

import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';

class AmountWidget extends StatelessWidget {
  final String amount;
  final String? description;
  final VoidCallback? onTap;
  final bool selectedAmount;
  final String currency;

  const AmountWidget({super.key, required this.amount, this.description, this.onTap, required this.selectedAmount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        // width: 150,
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selectedAmount ? MyColor.primaryColor.withOpacity(.7) : MyColor.primaryColor.withOpacity(.3)),
          color: selectedAmount ? MyColor.primaryColor.withOpacity(.8) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$amount $currency",
              textAlign: TextAlign.center,
              style: regularExtraLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: selectedAmount ? MyColor.colorWhite : MyColor.primaryColor),
            ),
            description == null
                ? const SizedBox.shrink()
                : Text(
                    "$description",
                    textAlign: TextAlign.center,
                    style: regularDefault.copyWith(color: selectedAmount ? MyColor.colorWhite : null),
                  ),
          ],
        ),
      ),
    );
  }
}
