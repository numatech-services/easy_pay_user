import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/data/controller/money_request/money_request_history_controller.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/no_data.dart';
import 'package:viserpay/view/components/shimmer/transaction_card_shimmer.dart';
import 'package:viserpay/view/screens/money_request/money_request_history_screen/section/request_to_me/widget/request_to_me_card.dart';

class RequestToMeSection extends StatefulWidget {
  const RequestToMeSection({super.key}); 

  @override
  State<RequestToMeSection> createState() => _RequestToMeSectionState();
}

class _RequestToMeSectionState extends State<RequestToMeSection> {
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
        return  NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
          child: GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
            child: Container(
              decoration: const BoxDecoration(),
              child: controller.isLoading && controller.requestToMeList.isEmpty
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
                  : controller.requestToMeList.isEmpty
                      ? const SingleChildScrollView(child: NoDataWidget())
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: controller.requestToMeList.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                          itemBuilder: (context, index) {
                            if (controller.requestToMeList.length == index) {
                              return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                            }
                            return RequestToMeCard(
                              index: index,
                              requestData: controller.requestToMeList[index],
                              currencySym: "tk",
                              press: () {},
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
