import 'package:flutter/material.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:get/get.dart';

class RequestMoneyStatus extends StatelessWidget {
  final String status;
  const RequestMoneyStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: (status == '1'
                ? MyColor.greenSuccessColor
                : status == '0'
                    ? MyColor.pendingColor
                    : MyColor.redCancelTextColor)
            .withOpacity(0.1),
        border: Border.all(
          color: status == '1'
              ? MyColor.greenSuccessColor
              : status == '0'
                  ? MyColor.pendingColor
                  : MyColor.redCancelTextColor,
          width: .5,
        ),
      ),
      child: Text(
        (status == '1'
                ? MyStrings.approved
                : status == '0'
                    ? MyStrings.pending
                    : MyStrings.rejected)
            .tr,
        style: regularDefault.copyWith(
          color: status == '1'
              ? MyColor.greenSuccessColor
              : status == '0'
                  ? MyColor.pendingColor
                  : MyColor.redCancelTextColor,
        ),
      ),
    );
  }
}
