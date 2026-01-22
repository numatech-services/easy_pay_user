import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/data/controller/money_request/money_request_history_controller.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/no_data.dart';
import 'package:viserpay/view/components/shimmer/transaction_card_shimmer.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/section/my_request/widget/money_request_history_card.dart';

class MyRequestSection extends StatefulWidget {
  const MyRequestSection({super.key});
 
  @override
  State<MyRequestSection> createState() => _MyRequestSectionState();
}

class _MyRequestSectionState extends State<MyRequestSection> {
  ScrollController scrollController = ScrollController();
  final InActivityTimer timer = InActivityTimer();
  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<MoneyRequestHistoryController>().hasNext()) {
        Get.find<MoneyRequestHistoryController>().getMyRequestHistoryList();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
    return GetBuilder<MoneyRequestHistoryController>(
      builder: (controller) {
        return NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
          child: GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
            child: Container(
              decoration: const BoxDecoration(),
              child: controller.isLoading && controller.myRequestList.isEmpty
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
                  : controller.myRequestList.isEmpty
                      ? const NoDataWidget()
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: controller.myRequestList.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                          itemBuilder: (context, index) {
                            if (controller.myRequestList.length == index) {
                              return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                            }
                            return MoneyRequestHistoryCard(
                              request: controller.myRequestList[index],
                              currencySym: "tk",
                              currency: controller.currency,
                            );
                          },
                        ),
            ),
          ),
        );
      },
    );
  }
}
