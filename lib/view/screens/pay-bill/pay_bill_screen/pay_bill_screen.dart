import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/payBill/paybill_controller.dart';
import 'package:viserpay/data/model/kyc/kyc_response_model.dart';
import 'package:viserpay/data/repo/paybill/pay_bill_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/cash-card/title_card.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/form_row.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_checkbox_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_date_time_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_radio_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_select_section.dart';
import 'package:viserpay/view/screens/auth/kyc/section/kyc_text_section.dart';
import 'package:viserpay/view/screens/auth/kyc/widget/widget/choose_file_list_item.dart';
import 'package:viserpay/view/screens/pay-bill/widget/paybill_icon_widget.dart';

class PaybillScreen extends StatefulWidget {
  const PaybillScreen({super.key});

  @override
  State<PaybillScreen> createState() => _PaybillScreenState();
}

class _PaybillScreenState extends State<PaybillScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PaybillRepo(apiClient: Get.find()));
    final controller = Get.put(PaybillController(paybillRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.selectedUtils == null) {
        Get.back();
        CustomSnackBar.error(errorList: [MyStrings.selectAUtility]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.appBarColor,
      appBar: CustomAppBar(
        title: MyStrings.paybill,
        isTitleCenter: true,
        elevation: 0.09,
      ),
      body: GetBuilder<PaybillController>(builder: (controller) {
        return controller.isLoading
            ? const CustomLoader()
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: Dimensions.defaultPaddingHV,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: Dimensions.space25,
                      ),
                      TitleCard(
                        title: MyStrings.to.tr,
                        onlyBottom: true,
                        widget: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.space12, horizontal: Dimensions.space12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              BillIcon(
                                imageUrl: controller.selectedUtils?.getImage ?? "",
                                color: MyColor.getSymbolColor(0),
                                radius: 8,
                              ),
                              const SizedBox(
                                width: Dimensions.space15,
                              ),
                              Text(
                                controller.selectedUtils?.name?.tr.toString() ?? "",
                                style: title.copyWith(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space25),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: controller.formList.length,
                              itemBuilder: (ctx, index) {
                                FormModel? model = controller.formList[index];
                                printx(model.type);
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
                                                FormRow(label: (model.name ?? '').tr, isRequired: model.isRequired == 'optional' ? false : true),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                  child: InkWell(
                                                    splashColor: MyColor.primaryColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                                                    onTap: () {
                                                      controller.pickFile(index);
                                                    },
                                                    child: ChooseFileItem(
                                                      fileName: model.selectedValue ?? MyStrings.chooseFile.tr,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                      const SizedBox(height: Dimensions.space10),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: Dimensions.space25),
                            Center(
                              child: GradientRoundedButton(
                                press: () {
                                  if (formKey.currentState!.validate() && controller.hasError().isEmpty) {
                                    Get.toNamed(RouteHelper.paybillAmountScreen);
                                  } else {
                                    CustomSnackBar.error(errorList: controller.hasError());
                                  }
                                },
                                text: MyStrings.continue_.tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
