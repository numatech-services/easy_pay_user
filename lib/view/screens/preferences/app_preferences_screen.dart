
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/controller/localization/localization_controller.dart';
import 'package:viserpay/data/controller/my_language_controller/my_language_controller.dart';
import 'package:viserpay/data/repo/auth/general_setting_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/image/custom_svg_picture.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool isAutoupdate = false;
  bool isLoading = false;

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    Get.put(MyLanguageController(repo: Get.find(), localizationController: Get.find()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorWhite,
      appBar: CustomAppBar(
        title: MyStrings.appPreference,
        isTitleCenter: true,
        elevation: 0.01,
      ),
      body: GetBuilder<MyLanguageController>(
        builder: (controller) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: controller.isChangeLangLoading
                ? const CustomLoader(isFullScreen: true)
                : Padding(
                    padding: Dimensions.defaultPaddingHV,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Get.toNamed(RouteHelper.languageScreen);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(MyStrings.language.tr, style: regularDefault.copyWith(fontSize: Dimensions.fontExtraLarge)),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(RouteHelper.languageScreen);
                                },
                                child: const CustomSvgPicture(image: MyIcon.arrowRightIos, color: MyColor.colorBlack),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.space25),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            controller.resetLanguage();
                            setState(() {
                              isLoading = false;
                              isAutoupdate = true;
                            });
                          },
                          child: Text(
                            MyStrings.resetPreference.tr,
                            style: semiBoldDefault.copyWith(fontSize: 16, color: const Color(0xFFE80F0F)),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space25),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
