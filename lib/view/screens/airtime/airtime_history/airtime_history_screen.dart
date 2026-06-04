import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/controller/airtime/airtime_history_controller.dart';
import 'package:viserpay/data/repo/airtime/airtime_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/no_data.dart';
import 'package:viserpay/view/components/shimmer/transaction_card_shimmer.dart';
import 'package:viserpay/view/screens/airtime/airtime_history/widget/airtime_history_bottom_sheet.dart';
import 'package:viserpay/view/screens/airtime/airtime_history/widget/airtime_history_card.dart';

class AirtimeHistoryScreen extends StatefulWidget {
  const AirtimeHistoryScreen({super.key});

  @override
  State<AirtimeHistoryScreen> createState() => _AirtimeHistoryScreenState();
}

class _AirtimeHistoryScreenState extends State<AirtimeHistoryScreen> {
  ScrollController scrollController = ScrollController();
  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<AirtimeHistoryController>().hasNext()) {
        Get.find<AirtimeHistoryController>().getAirTimeHistory();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(AirtimeRepo(apiClient: Get.find()));
    final controller = Get.put(AirtimeHistoryController(airtimeRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((time) {
      controller.initialValue();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.screenBgColor,
      appBar: CustomAppBar(
        title: MyStrings.airTimeHistory,
        isTitleCenter: true,
        backButtonOnPress: () {
          if (Get.previousRoute == RouteHelper.airtimePinScreen || Get.previousRoute == RouteHelper.airtimeHistoryScreen) {
            Get.offAllNamed(RouteHelper.bottomNavBar);
          } else {
            Get.back();
          }
        },
      ),
      body: GetBuilder<AirtimeHistoryController>(
        builder: (controller) {
          return Padding(
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
                : controller.airtTimeHistoryList.isEmpty && controller.isLoading == false
                    ? const Center(child: NoDataWidget())
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: controller.airtTimeHistoryList.length + 1,
                        separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                        itemBuilder: (context, index) {
                          if (controller.airtTimeHistoryList.length == index) {
                            return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                          }
                          return AirTimeHistoryCard(
                            press: () {
                              CustomBottomSheet(child: AirtimeHistoryBottomSheet(currency: controller.currency, data: controller.airtTimeHistoryList[index])).customBottomSheet(context);
                            },
                            transaction: controller.airtTimeHistoryList[index],
                            currencySym: controller.currencySym,
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}
