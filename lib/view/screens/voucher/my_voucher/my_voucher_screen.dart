import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/view/components/will_pop_widget.dart';

import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/voucher/voucher_list_controller.dart';
import '../../../../data/repo/voucher/voucher_list_repo.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/app-bar/action_button_icon_widget.dart';
import '../../../components/app-bar/custom_appbar.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/no_data.dart';
import 'widget/voucher_list_card.dart';

class MyVoucherScreen extends StatefulWidget {
  const MyVoucherScreen({super.key});

  @override
  State<MyVoucherScreen> createState() => _MyVoucherScreenState();
}

class _MyVoucherScreenState extends State<MyVoucherScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<VoucherListController>().hasNext()) {
        Get.find<VoucherListController>().loadData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(VoucherListRepo(apiClient: Get.find()));
    final controller = Get.put(VoucherListController(voucherListRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialState();
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
    return GetBuilder<VoucherListController>(
      builder: (controller) => WillPopWidget(
        nextRoute: RouteHelper.bottomNavBar,
        child: Scaffold(
          backgroundColor: MyColor.screenBgColor,
          appBar: CustomAppBar(
            title: MyStrings.myVoucher,
            isTitleCenter: true,
            elevation: 0.1,
            action: [
              ActionButtonIconWidget(backgroundColor: MyColor.getPrimaryColor().withOpacity(0.2), pressed: () => Get.toNamed(RouteHelper.createVoucherScreen), icon: Icons.add),
              const SizedBox(width: 10),
            ],
            backButtonOnPress: () {
              if (Get.previousRoute == RouteHelper.createVoucherScreen) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.bottomNavBar);
              }
            },
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : Padding(
                  padding: Dimensions.screenPaddingHV,
                  child: Column(
                    children: [
                      Expanded(
                        child: controller.voucherList.isEmpty
                            ? const Center(
                                child: NoDataWidget(),
                              )
                            : SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: VoucherListCard(scrollController: scrollController),
                              ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
