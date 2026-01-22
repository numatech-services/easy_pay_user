import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/kyc_controller/kyc_controller.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import 'package:viserpay/data/repo/kyc/kyc_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/custom_no_data_found_class.dart';
import 'package:viserpay/view/components/form_row.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_checkbox_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_date_time_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_radio_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_select_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_text_section.dart';
import 'package:viserpay/view/screens/auth/kyc/widget/already_verifed.dart';
import 'package:viserpay/view/screens/auth/kyc/widget/widget/file_item.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(KycRepo(apiClient: Get.find()));
    Get.put(KycController(repo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<KycController>().beforeInitLoadKycData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(isWhite: true),
          appBar: CustomAppBar(
            title: controller.isAlreadyPending ? MyStrings.kycData : MyStrings.kyc,
            isTitleCenter: true,
            action: [
              if (controller.isAlreadyPending) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space5),
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
                  decoration: BoxDecoration(color: MyColor.pendingColor.withOpacity(0.2), border: Border.all(color: MyColor.pendingColor, width: .5), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                  child: Text(
                    MyStrings.pending.tr,
                    style: regularSmall.copyWith(color: MyColor.pendingColor),
                  ),
                )
              ],
            ],
          ),
          body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: controller.isLoading
                  ? const Padding(padding: EdgeInsets.all(Dimensions.space15), child: CustomLoader())
                  : controller.isAlreadyVerified
                      ? const AlreadyVerifiedWidget()
                      : controller.isAlreadyPending
                          ? const AlreadyVerifiedWidget(
                              isPending: true,
                            )
                          : controller.isNoDataFound
                              ? const NoDataOrInternetScreen()
                              : Center(
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: Dimensions.screenPaddingHV,
                                    child: Form(
                                      key: formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              itemCount: controller.formList.length,
                                              itemBuilder: (ctx, index) {
                                                FormModel? model = controller.formList[index];
                                                return Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (MyUtils.getTextInputType(model.type ?? 'text')) ...[
                                                        KycTextAnEmailSection(
                                                          onChanged: (value) {
                                                            controller.changeSelectedValue(value, index);
                                                          },
                                                          model: model,
                                                        )
                                                      ] else if (model.type == "select") ...[
                                                        KycSelectSection(
                                                          onChanged: (value) {
                                                            controller.changeSelectedValue(value, index);
                                                          },
                                                          model: model,
                                                        )
                                                      ] else if (model.type == 'radio') ...[
                                                        KycRadioSection(
                                                          model: model,
                                                          onChanged: (selectedIndex) {
                                                            controller.changeSelectedRadioBtnValue(index, selectedIndex);
                                                          },
                                                          selectedIndex: controller.formList[index].options?.indexOf(model.selectedValue ?? '') ?? 0,
                                                        )
                                                      ] else if (model.type == "checkbox") ...[
                                                        KycCheckBoxSection(
                                                          model: model,
                                                          onChanged: (value) {
                                                            controller.changeSelectedCheckBoxValue(index, value);
                                                          },
                                                          selectedValue: controller.formList[index].cbSelected,
                                                        )
                                                      ] else if (model.type == "datetime" || model.type == "date" || model.type == "time") ...[
                                                        KycDateTimeSection(
                                                          model: model,
                                                          onChanged: (value) {
                                                            controller.changeSelectedValue(value, index);
                                                          },
                                                          onTap: () {
                                                            printx(model.type);
                                                            if (model.type == "time") {
                                                              controller.changeSelectedTimeOnlyValue(index, context);
                                                            } else if (model.type == "date") {
                                                              controller.changeSelectedDateOnlyValue(index, context);
                                                            } else {
                                                              controller.changeSelectedDateTimeValue(index, context);
                                                            }
                                                          },
                                                          controller: controller.formList[index].textEditingController!,
                                                        )
                                                      ],
                                                      model.type == 'file'
                                                          ? Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                FormRow(label: model.name ?? '', isRequired: model.isRequired == 'optional' ? false : true),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                  child: ConfirmWithdrawFileItem(index: index),
                                                                ),
                                                              ],
                                                            )
                                                          : const SizedBox(),
                                                      const SizedBox(height: Dimensions.space10),
                                                    ],
                                                  ),
                                                );
                                              }),
                                          const SizedBox(height: Dimensions.space25),
                                          Center(
                                            child: GradientRoundedButton(
                                              isLoading: controller.submitLoading,
                                              press: () {
                                                if (formKey.currentState!.validate()) {
                                                  controller.submitKycData();
                                                }
                                              },
                                              text: MyStrings.submit,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
        ),
      ),
    );
  }
}
