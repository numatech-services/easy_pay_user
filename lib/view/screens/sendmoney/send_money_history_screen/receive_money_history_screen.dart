import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/data/controller/send_money/sendmoney_controller.dart';
import 'package:viserpay/data/repo/send_money/send_money_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/no_data.dart';
import 'package:viserpay/view/components/shimmer/transaction_card_shimmer.dart';
import 'package:viserpay/view/screens/sendmoney/send_money_history_screen/widget/history_card_bottom_sheet.dart';
import 'package:viserpay/view/screens/sendmoney/send_money_history_screen/widget/send_money_history_card.dart';

class ReceiveMoneyHistoryScreen extends StatefulWidget {
  const ReceiveMoneyHistoryScreen({super.key}); 

  @override
  State<ReceiveMoneyHistoryScreen> createState() => _ReceiveMoneyHistoryScreenState();
}

class _ReceiveMoneyHistoryScreenState extends State<ReceiveMoneyHistoryScreen> {
  ScrollController scrollController = ScrollController();
  final InActivityTimer timer = InActivityTimer();
  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<SendMoneyContrller>().hasNext()) {
        Get.find<SendMoneyContrller>().getReceiveMoneyHistory();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SendMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(SendMoneyContrller(
      sendMoneyRepo: Get.find(),
    ));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.clearPageData();
      controller.getReceiveMoneyHistory();
      scrollController.addListener(scrollListener);
    });
    timer.startTimer(context);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SendMoneyContrller>(builder: (controller) {
      return NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
        child: GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
          child: Scaffold(
            backgroundColor: MyColor.screenBgColor,
            appBar: CustomAppBar(
              title: "Tickets reçu",
              isTitleCenter: true,
            ),
            body: Padding(
              padding: Dimensions.screenPaddingHV,
              child: controller.isLoading
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
                          width: double.infinity,
                          decoration: BoxDecoration(color: MyColor.colorGrey3, borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                          child: const TransactionCardShimmer(),
                        );
                      },
                      itemCount: 10,
                    )
                  : controller.sendmoneyHistorydata.isEmpty && controller.isLoading == false
                      ? const Center(
                          child: NoDataWidget(
                              // noDataText: MyStrings.noTrnxHistory.tr,
                              // margin: controller.isSearch ? 10 : 4,
                              ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: controller.sendmoneyHistorydata.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                          itemBuilder: (context, index) {
                            if (controller.sendmoneyHistorydata.length == index) {
                              return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                            }
                            return SendMoneyHistoryCard(
                              index: index,
                              press: () {
                                CustomBottomSheet(
                                  child: HistoryCardBottomSheet(
                                    index: index,
                                  ),
                                ).customBottomSheet(context);
                              },
                              transaction: controller.sendmoneyHistorydata[index],
                              currencySym: controller.currencySym,
                            );
                          },
                        ),
            ),
          ),
        ),
      );
    });
  }
}
