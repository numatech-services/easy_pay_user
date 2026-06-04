import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/model/contact/user_contact_model.dart';
import 'package:viserpay/view/components/cash-card/title_card.dart';
import 'package:viserpay/view/components/cash-card/user/user_card.dart';
import 'package:viserpay/view/components/image/custom_svg_picture.dart';

import '../../../../../data/controller/money_request/money_request_controller.dart';

class MoneyRequestRecentSection extends StatelessWidget {
  final MoneyRequestController  moneyRequestController;
  const MoneyRequestRecentSection({super.key, required this.moneyRequestController});

  @override
  Widget build(BuildContext context) {
    return moneyRequestController.numberController.text.isNotEmpty
        ? const SizedBox.shrink()
        : moneyRequestController.sendMoneyHistory.isNotEmpty
            ? TitleCard(
                title: MyStrings.recent.tr,
                widget: Column(
                  children: List.generate(
                    moneyRequestController.sendMoneyHistory.length > 3 ? 3 : moneyRequestController.sendMoneyHistory.length,
                    (i) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        moneyRequestController.selectContact(
                          UserContactModel(
                            name: moneyRequestController.sendMoneyHistory[i].receiverUser!.username.toString(),
                            number: moneyRequestController.sendMoneyHistory[i].receiverUser!.mobile.toString(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimensions.space12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: UserCard(
                          title: moneyRequestController.sendMoneyHistory[i].receiverUser!.username.toString(),
                          subtitle: moneyRequestController.sendMoneyHistory[i].receiverUser!.mobile.toString(),
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
                ))
            : const SizedBox.shrink();
  }
}
