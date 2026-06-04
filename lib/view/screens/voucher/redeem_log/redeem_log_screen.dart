import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/voucher/redeem_log_controller.dart';
import '../../../../data/repo/voucher/redeem_log_repo.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/app-bar/custom_appbar.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/no_data.dart';
import 'widget/redeem_log_card.dart';

class RedeemLogScreen extends StatefulWidget {
  const RedeemLogScreen({super.key});

  @override
  State<RedeemLogScreen> createState() => _RedeemLogScreenState();
}

class _RedeemLogScreenState extends State<RedeemLogScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<RedeemLogController>().hasNext()) {
        Get.find<RedeemLogController>().loadData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(RedeemLogRepo(apiClient: Get.find()));
    final controller = Get.put(RedeemLogController(redeemLogRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RedeemLogController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          isShowBackBtn: true,
          title: MyStrings.voucherRedeemLog.tr,
          bgColor: MyColor.getAppBarColor(),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Padding(
                padding: Dimensions.screenPaddingHV,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: controller.redeemLogList.isEmpty
                          ? const Center(
                              child: NoDataWidget(),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  controller: scrollController,
                                  itemCount: controller.redeemLogList.length + 1,
                                  separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                  itemBuilder: (context, index) {
                                    if (controller.redeemLogList.length == index) {
                                      return controller.hasNext() ? Container(height: 40, width: MediaQuery.of(context).size.width, margin: const EdgeInsets.all(5), child: const CustomLoader()) : const SizedBox();
                                    }

                                    return RedeemLogCard(
                                      index: index,
                                      currency: controller.currencySym,
                                    );
                                  }),
                            ),
                    ),
                  ],
                )),
      ),
    );
  }
}
