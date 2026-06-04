import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/my_images.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:viserpay/view/components/will_pop_widget.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_icon.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/airtime/airtime_controller.dart';
import '../../../data/repo/airtime/airtime_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/custom_appbar.dart';

import '../../components/custom_loader/custom_loader.dart';
import '../../components/global/history_icon_widget.dart';
import '../../components/image/my_image_widget.dart';
import '../../components/text/label_text.dart';
import 'widget/airtime__bottom_sheet.dart';
import 'widget/amount_section.dart';
import 'widget/fixed_amount_section.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(AirtimeRepo(apiClient: Get.find()));
    final controller = Get.put(AirtimeController(airtimeRepo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AirtimeController>(
      builder: (controller) => WillPopWidget(
        nextRoute: RouteHelper.bottomNavBar,
        child: Scaffold(
          backgroundColor: MyColor.colorWhite,
          appBar: CustomAppBar(
            title: MyStrings.airTime.tr,
            action: [
              HistoryWidget(routeName: RouteHelper.airtimeHistoryScreen),
              const SizedBox(width: Dimensions.space20),
            ],
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : SingleChildScrollView(
                  padding: Dimensions.screenPaddingHV,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.space20),
                      const LabelText(text: MyStrings.selectACountry, isRequired: true),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      InkWell(
                        onTap: () {
                          AirtimeCountryBottomSheet.selectCountrySheet(context, controller);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor, width: .5),
                            borderRadius: BorderRadius.circular(10),
                            color: MyColor.colorWhite,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: controller.selectedCountry.id == -1 ? Icon(Icons.language_outlined, color: MyColor.primaryColor.withOpacity(0.7), size: 25) : SvgPicture.network(width: 25, height: 25, fit: BoxFit.cover, controller.selectedCountry.flagUrl ?? ""),
                                    ),
                                    const SizedBox(width: Dimensions.space10),
                                    Expanded(
                                      child: Text(
                                        controller.selectedCountry.id == -1 ? MyStrings.selectACountry : controller.selectedCountry.name ?? '',
                                        style: regularDefault.copyWith(color: MyColor.colorBlack),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space20),

                      const LabelText(text: MyStrings.selectAOperator, isRequired: true),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      InkWell(
                        onTap: () {
                          if (controller.selectedCountry.id != -1) {
                            AirtimeCountryBottomSheet.selectOperatorBottomSheet(context, controller);
                          } else {
                            CustomSnackBar.error(errorList: [MyStrings.selectACountry]);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                          decoration: BoxDecoration(border: Border.all(color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor, width: .5), borderRadius: BorderRadius.circular(10), color: MyColor.colorWhite),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: MyImageWidget(
                                        width: 25,
                                        height: 25,
                                        boxFit: BoxFit.contain,
                                        imageUrl: controller.selectedOperator.logoUrls?.first ?? '',
                                        errorWidget: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Image.asset(MyImages.sim, color: MyColor.primaryColor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space10),
                                    Expanded(
                                      child: Text(
                                        controller.selectedOperator.id == -1 ? MyStrings.mobileOperator : controller.selectedOperator.name ?? "",
                                        style: regularDefault.copyWith(color: MyColor.colorBlack),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space20),
                      const LabelText(text: MyStrings.mobileNumber, isRequired: true),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColor.getTextFieldDisableBorder(), width: .5),
                          borderRadius: BorderRadius.circular(10),
                          // boxShadow: MyUtils.getShadow2(blurRadius: 10),
                          color: MyColor.colorWhite,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
                        child: TextFormField(
                          controller: controller.mobileController,
                          focusNode: controller.mobileFocusNode,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            prefixIcon: IntrinsicWidth(
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(color: MyColor.transparentColor, borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.only(start: Dimensions.space5, end: Dimensions.space5),
                                        child: Text(
                                          "${controller.selectedCountry.callingCodes?.first}".replaceAll('null', '+00'),
                                          style: regularMediumLarge,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            suffixIcon: Padding(padding: const EdgeInsets.all(Dimensions.space15), child: Transform.rotate(angle: 180.4, child: SvgPicture.asset(MyIcon.phoneSVG))),
                            hintText: "000-000",
                            border: InputBorder.none, // Remove border
                            filled: false, // Remove fill
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                            hintStyle: regularMediumLarge.copyWith(color: MyColor.hintTextColor),
                          ),
                          keyboardType: TextInputType.phone, // Set keyboard type to phone
                          style: regularMediumLarge,
                          cursorColor: MyColor.primaryColor, // Set cursor color to red
                          validator: (value) {
                            if (value!.isEmpty) {
                              return;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      //Amount
                      if (controller.selectedOperator.suggestedAmounts?.isNotEmpty ?? false) const AmountInputByUserSection(),
                      if (controller.selectedOperator.fixedAmounts?.isNotEmpty ?? false) const FixedAmountSection(),
                    ],
                  ),
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: SizedBox(
              child: GradientRoundedButton(
                isLoading: controller.submitLoading,
                text: MyStrings.recharge.tr,
                press: () {
                  // check country and oparator
                  // check mobile text field
                  // check denomination type
                  // check amount max-min
                  if (controller.selectedCountry.id != -1 && controller.selectedOperator.id != -1) {
                    if (controller.mobileController.text.isNotEmpty) {
                      if (controller.selectedOperator.denominationType == MyStrings.fixed ? controller.selectedAmount != '0' : controller.amountController.text.isNotEmpty) {
                        double amount = double.tryParse(controller.getAmount()) ?? 0.0;
                        double minAmount = double.tryParse(controller.selectedOperator.localMinAmount) ?? 0.0;
                        double maxAmount = double.tryParse(controller.selectedOperator.localMaxAmount) ?? 0.0;

                        if (controller.selectedOperator.denominationType == MyStrings.fixed) {
                          Get.toNamed(RouteHelper.airtimePinScreen);
                        } else {
                          if (amount >= minAmount && amount <= maxAmount) {
                            Get.toNamed(RouteHelper.airtimePinScreen);
                          } else {
                            CustomSnackBar.error(errorList: ["${MyStrings.enterAmountMsg} between ${controller.currencySym}$minAmount to ${controller.currencySym}$maxAmount"]);
                          }
                        }
                      } else {
                        CustomSnackBar.error(errorList: [controller.selectedOperator.denominationType == MyStrings.fixed ? MyStrings.selectAPackage : MyStrings.enterAmountMsg]);
                      }
                    } else {
                      CustomSnackBar.error(errorList: [MyStrings.pleaseEnterYourMobileNumber]);
                    }
                  } else {
                    CustomSnackBar.error(errorList: [MyStrings.selectACountryAndOperator]);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
