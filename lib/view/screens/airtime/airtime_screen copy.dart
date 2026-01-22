// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:viserpay/core/utils/style.dart';
// import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';

// import '../../../core/utils/dimensions.dart';
// import '../../../core/utils/my_color.dart';
// import '../../../core/utils/my_strings.dart';
// import '../../../data/controller/airtime/airtime_controller.dart';
// import '../../../data/repo/airtime/airtime_repo.dart';
// import '../../../data/services/api_service.dart';
// import '../../components/app-bar/custom_appbar.dart';

// import '../../components/custom_loader/custom_loader.dart';
// import '../../components/text/label_text.dart';
// import '../transaction/widget/filter_row_widget.dart';
// import 'widget/airtime_country_bottomsheet.dart';
// import 'widget/operator_section.dart';

// class AirtimeScreen extends StatefulWidget {
//   const AirtimeScreen({super.key});

//   @override
//   State<AirtimeScreen> createState() => _AirtimeScreenState();
// }

// class _AirtimeScreenState extends State<AirtimeScreen> {
//   @override
//   void initState() {
//     Get.put(ApiClient(sharedPreferences: Get.find()));
//     Get.put(AirtimeRepo(apiClient: Get.find()));
//     var controller = Get.put(AirtimeController(airtimeRepo: Get.find()));

//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.initialSelectedValue();
//       controller.loadCountryData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AirtimeController>(
//       builder: (controller) => Scaffold(
//         backgroundColor: MyColor.screenBgColor,
//         appBar: CustomAppBar(
//           title: MyStrings.airTime.tr,
//         ),
//         body: controller.isLoading
//             ? const CustomLoader()
//             : SingleChildScrollView(
//                 padding: Dimensions.screenPaddingHV,
//                 child: Column(
//                   children: [
//                     const SizedBox(height: Dimensions.space20),
//                     const LabelText(
//                       text: MyStrings.selectACountry,
//                       isRequired: true,
//                     ),
//                     const SizedBox(height: Dimensions.textToTextSpace),

//                     InkWell(
//                       onTap: () {
//                         AirtimeCountryBottomSheet.bottomSheet(context, controller);
//                       },
//                       child: Container(
//                         width: MediaQuery.of(context).size.width,
//                         padding: EdgeInsets.symmetric(vertical: controller.selectedCountry.id != -1 ? 11 : 13, horizontal: 10),
//                         decoration: BoxDecoration(color: MyColor.transparentColor, border: Border.all(color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor, width: .5), borderRadius: BorderRadius.circular(4)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Row(
//                                 children: [
//                                   controller.selectedCountry.id != -1
//                                       ? ClipRRect(
//                                           borderRadius: BorderRadius.circular(4),
//                                           child: SvgPicture.network(width: 25, height: 25, fit: BoxFit.cover, controller.selectedCountry.flagUrl ?? ""),
//                                         )
//                                       : const SizedBox.shrink(),
//                                   const SizedBox(
//                                     width: Dimensions.space10,
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       controller.selectedCountry.id == -1 ? MyStrings.selectACountry : controller.selectedCountry.name.toString() ?? "",
//                                       style: regularDefault.copyWith(color: MyColor.colorBlack),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(
//                               Icons.arrow_drop_down,
//                               color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor,
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: Dimensions.space20),
//                     const LabelText(
//                       text: MyStrings.selectAOperator,
//                       isRequired: true,
//                     ),
//                     const SizedBox(height: Dimensions.textToTextSpace),

//                     InkWell(
//                       onTap: () {
//                         AirtimeCountryBottomSheet.bottomSheet(context, controller);
//                       },
//                       child: Container(
//                         width: MediaQuery.of(context).size.width,
//                         padding: EdgeInsets.symmetric(vertical: controller.selectedCountry.id != -1 ? 11 : 13, horizontal: 10),
//                         decoration: BoxDecoration(color: MyColor.transparentColor, border: Border.all(color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor, width: .5), borderRadius: BorderRadius.circular(4)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 controller.selectedCountry.id != -1
//                                     ? ClipRRect(
//                                         borderRadius: BorderRadius.circular(4),
//                                         child: SvgPicture.network(width: 25, height: 25, fit: BoxFit.cover, controller.selectedCountry.flagUrl ?? ""),
//                                       )
//                                     : const SizedBox.shrink(),
//                                 const SizedBox(
//                                   width: Dimensions.space10,
//                                 ),
//                                 Text(
//                                   controller.selectedCountry.id == -1 ? MyStrings.mobileOperator : controller.selectedCountry.name ?? "",
//                                   style: regularDefault.copyWith(color: MyColor.colorBlack),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               Icons.arrow_drop_down,
//                               color: controller.selectedCountry.id == -1 ? MyColor.textFieldDisableBorderColor : MyColor.textFieldEnableBorderColor,
//                             )
//                           ],
//                         ),
//                       ),
//                     ),

//                     if (controller.authorizationList.isNotEmpty) ...[Text(MyStrings.selectOptType.tr, style: mediumDefault.copyWith())],
//                     if (controller.authorizationList.isNotEmpty) ...[
//                       SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         scrollDirection: Axis.horizontal,
//                         padding: EdgeInsets.zero,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: List.generate(
//                             controller.authorizationList.length,
//                             (index) => Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Checkbox(
//                                       value: controller.selectedAuthorizationMode == controller.authorizationList[index] ? true : false,
//                                       onChanged: (p) {
//                                         controller.changeAuthorizationMode(controller.authorizationList[index]);
//                                       },
//                                       shape: const CircleBorder(),
//                                       activeColor: MyColor.primaryDark,
//                                     ),
//                                     Text(
//                                       controller.authorizationList[index].toUpperCase(),
//                                       style: semiBoldDefault.copyWith(
//                                         color: controller.selectedAuthorizationMode == controller.authorizationList[index].toLowerCase() ? MyColor.colorBlack : MyColor.primaryDark,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                     // const PhoneSection(),
//                     // Visibility(
//                     //     visible: controller.authorizationList.length > 1,
//                     //     child: Column(
//                     //       crossAxisAlignment: CrossAxisAlignment.start,
//                     //       children: [
//                     //         const SizedBox(height: 10),
//                     //         LabelText(
//                     //           text: MyStrings.authorizationMethod.tr,
//                     //           isRequired: true,
//                     //         ),
//                     //         const SizedBox(height: 8),
//                     //         CustomDropDownTextField(
//                     //           selectedValue: controller.selectedAuthorizationMode,
//                     //           list: controller.authorizationList,
//                     //           onChanged: (dynamic value) {
//                     //             controller.changeAuthorizationMode(value);
//                     //           },
//                     //         )
//                     //       ],
//                     //     )),
//                     // controller.selectedOperator.denominationType == MyStrings.range ? const AmountInputByUserSection() : const SizedBox.shrink(),
//                     // controller.selectedOperator.denominationType == MyStrings.fixed ? const FixedAmountSection() : const SizedBox.shrink(),
//                   ],
//                 ),
//               ),
//         bottomNavigationBar: controller.isLoading
//             ? const SizedBox.shrink()
//             : Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//                 child: SizedBox(
//                   child: GradientRoundedButton(
//                     showLoadingIcon: controller.submitLoading,
//                     text: MyStrings.recharge.tr,
//                     press: () {
//                       controller.submitTopUp();
//                     },
//                   ),
//                 )),
//       ),
//     );
//   }
// }
