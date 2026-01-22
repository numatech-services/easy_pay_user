import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_icon.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/voucher/create_voucher_controller.dart';
import '../../../../data/repo/voucher/create_voucher_repo.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/app-bar/action_button_icon_widget.dart';
import '../../../components/app-bar/custom_appbar.dart';
import '../../../components/custom_loader/custom_loader.dart';
import 'widget/create_voucher_form.dart';

class CreateVoucherScreen extends StatefulWidget {
  const CreateVoucherScreen({super.key});

  @override
  State<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends State<CreateVoucherScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CreateVoucherRepo(apiClient: Get.find()));
    final controller = Get.put(CreateVoucherController(createVoucherRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateVoucherController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.colorWhite,
        appBar: CustomAppBar(
          isShowBackBtn: true,
          title: MyStrings.createVoucher.tr,
          isTitleCenter: true,
          elevation: 0.1,
          action: [
            ActionButtonIconWidget(
              backgroundColor: MyColor.getPrimaryColor().withOpacity(0.2),
              pressed: () => Get.toNamed(RouteHelper.myVoucherScreen),
              isImage: true,
              imageSrc: MyIcon.history,
            ),
            const SizedBox(
              width: Dimensions.space10,
            ),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : const SingleChildScrollView(
                padding: Dimensions.screenPaddingHV,
                child: CreateVoucherForm(),
              ),
      ),
    );
  }
}
