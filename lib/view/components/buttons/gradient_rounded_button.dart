import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/style.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';

class GradientRoundedButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback press;
  final Color? textColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;

  const GradientRoundedButton({
    super.key,
    required this.text,
    required this.press,
    this.textColor = MyColor.colorWhite,
    this.isLoading = false,
    this.horizontalPadding = 10,
    this.verticalPadding = 18,
    this.cornerRadius = Dimensions.mediumRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isLoading) {
          press();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 7),
              blurRadius: 12,
              color: Color.fromRGBO(29, 111, 251, 0.20),
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFF2176FF), Color(0xFF0A55EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: Dimensions.fontExtraLarge + 3,
                height: Dimensions.fontExtraLarge + 3,
                child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
              )
            else
              Text(
                text.tr,
                style: regularDefault.copyWith(color: textColor, fontSize: Dimensions.fontMediumLarge),
              ),
            const SizedBox(width: 10),
            // Add any additional child widgets here
          ],
        ),
      ),
    );
  }
}
