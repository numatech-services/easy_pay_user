import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/controller/contact/contact_controller.dart';
import 'package:viserpay/data/controller/money_request/money_request_controller.dart';
import 'package:viserpay/data/model/contact/user_contact_model.dart';
import 'package:viserpay/view/components/cash-card/user/user_card.dart';
import 'package:viserpay/view/components/image/custom_svg_picture.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class MoneyRequestContactList extends StatelessWidget {
  ContactController controller;
  final MoneyRequestController moneyRequestController;
  MoneyRequestContactList({super.key, required this.controller, required this.moneyRequestController});

  @override
  Widget build(BuildContext context) {
    return  
     Column(
      children: List.generate(
        controller.filterContact.length,
        (i) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (controller.filterContact[i].phones.isNotEmpty && controller.filterContact[i].phones.first.number.isNotEmpty) {
              moneyRequestController.selectContact(
                UserContactModel(
                  name: controller.filterContact[i].displayName,
                  number: controller.filterContact[i].phones.first.number,
                ),
              );
            } else {
              CustomSnackBar.error(errorList: [MyStrings.selectAvailableNumberPlease.tr]);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.space10,
            ),
            child: UserCard(
              title: controller.filterContact[i].displayName.isNotEmpty
                  ? controller.filterContact[i].displayName
                  : controller.filterContact[i].phones.isNotEmpty
                      ? controller.filterContact[i].phones.first.number.toString()
                      : "--",
              subtitle: controller.filterContact[i].phones.isNotEmpty ? controller.filterContact[i].phones.first.number.toString() : "--",
              imgWidget: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColor.primaryColor.withOpacity(0.2),
                ),
                child: const CustomSvgPicture(image: MyIcon.user),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
