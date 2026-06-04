import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/data/controller/money_request/money_request_history_controller.dart';
import 'package:viserpay/data/repo/request_money/request_money_repo.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/section/my_request/my_request_section.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/section/request_to_me/request_to_me_section.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/app-bar/custom_appbar.dart';

class MoneyRequestHistoryScreen extends StatefulWidget {
  const MoneyRequestHistoryScreen({super.key});
 
  @override
  State<MoneyRequestHistoryScreen> createState() => _MoneyRequestHistoryScreenState();
}

class _MoneyRequestHistoryScreenState extends State<MoneyRequestHistoryScreen> {
   final InActivityTimer timer = InActivityTimer();
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(RequestMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(MoneyRequestHistoryController(moneyRepo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initailValue();
    });
    timer.startTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MoneyRequestHistoryController>(builder: (controller) {
      return NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
        child:GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
          child: Scaffold(
            backgroundColor: MyColor.screenBgColor,
            appBar: CustomAppBar(
              title: MyStrings.requestMoney,
              isTitleCenter: true,
            ),
            body: Padding(
              padding: Dimensions.screenPaddingHV,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.changeTab(tab: 0);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                              decoration: BoxDecoration(
                                color: controller.currentTab == 0 ? MyColor.primaryColor : MyColor.colorWhite,
                                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                              ),
                              child: Center(
                                child: Text(
                                  "My Request",
                                  style: boldDefault.copyWith(color: controller.currentTab == 0 ? MyColor.colorWhite : MyColor.colorBlack),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.space10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.changeTab(tab: 1);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                              decoration: BoxDecoration(
                                color: controller.currentTab == 1 ? MyColor.primaryColor : MyColor.colorWhite,
                                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                              ),
                              child: Center(
                                child: Text(
                                  "To Me",
                                  style: boldDefault.copyWith(color: controller.currentTab == 1 ? MyColor.colorWhite : MyColor.colorBlack),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.space20),
                  Expanded(child: controller.currentTab == 0 ? const MyRequestSection() : const RequestToMeSection())
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
