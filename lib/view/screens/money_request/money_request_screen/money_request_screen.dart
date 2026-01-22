import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/extensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_images.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/contact/contact_controller.dart';
import 'package:viserpay/data/repo/request_money/request_money_repo.dart';

import '../../../../data/controller/money_request/money_request_controller.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/app-bar/custom_appbar.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/dialog/app_dialog.dart';
import '../../../components/global/history_icon_widget.dart';
import '../../../components/permisson_widget/contact_request_widget.dart';
import '../../../components/shimmer/contact_card_shimmer.dart';
import '../../../components/text-form-field/custom_text_field.dart';
import 'widget/money_request_recent_section.dart';
import 'widget/money_requst_contact_list.dart';

class MoneyRequestScreen extends StatefulWidget {
  const MoneyRequestScreen({super.key});
 
  @override
  State<MoneyRequestScreen> createState() => _MoneyRequestScreenState();
}

class _MoneyRequestScreenState extends State<MoneyRequestScreen> {
  bool showListView = false; // Flag to control whether to show the ListView
  bool isSearching = false;
   final InActivityTimer timer = InActivityTimer();

  @override
  void initState() {
    MyUtils.allScreen();

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(RequestMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(MoneyRequestController(
      requestMoneyRepo: Get.find(),
    ));
   
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.numberFocusNode.unfocus();
      controller.numberController.text = '';
      controller.numberController.clear();
      controller.initialValue();
    });

    Timer(const Duration(seconds: 3), () {
      // Ensure that the widget is still mounted before updating the state
      if (mounted) {
        setState(() {
          // Set the flag to true to show the ListView
          showListView = true;
        });
      }
    });

      timer.startTimer(context);
  }

  @override
  void dispose() {
    MyUtils.allScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
            onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
      child: GestureDetector(
             onTap: () => timer.handleUserInteraction(context),
             onPanUpdate: (_) => timer.handleUserInteraction(context),
        child: Scaffold(
          backgroundColor: MyColor.colorWhite,
          appBar: CustomAppBar(
            title: MyStrings.requestMoney,
            isTitleCenter: true,
            elevation: 0.1,
            action: [
              HistoryWidget(routeName: RouteHelper.moneyRequestHistoryScreen),
              const SizedBox(
                width: Dimensions.space20,
              ),
            ],
          ),
          body: GetBuilder<MoneyRequestController>(
            builder: (requestMoneyController) {
              // final controller = Get.find<ContactController>();
              return requestMoneyController.isLoading
                  ? const CustomLoader()
                  : RefreshIndicator(
                      onRefresh: () async {
                        requestMoneyController.initialValue();
                      },
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          // void filterContact(String query) {
                          //   setState(() {
                          //     isSearching = true;
                          //   });
                          //   if (query.isEmpty) {
                          //     controller.filterContact = controller.contacts;
                          //   } else {
                          //     setState(() {
                          //       controller.filterContact = controller.contacts.where((country) => country.displayName.toLowerCase().contains(query.toLowerCase())).toList();
                          //     });
                          //   }
                          //   setState(() {
                          //     isSearching = false;
                          //   });
                          // }
        
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            child: Padding(
                              padding: Dimensions.defaultPaddingHV,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    needOutlineBorder: true,
                                    labelText: MyStrings.to.tr,
                                    onChanged: (val) {
                                      // sendController.numberValidation(val);
                                      // if (!isSearching) {
                                      //   filterContact(val);
                                      // }
                                    },
                                    inputAction: TextInputAction.go,
                                    hintText: MyStrings.enterUserNameOrNumber.toSentenceCase(),
                                    controller: requestMoneyController.numberController,
                                    focusNode: requestMoneyController.numberFocusNode,
                                    isShowSuffixIcon: true,
                                    onSubmit: () {
                                      requestMoneyController.changeSelectedMethod();
                                      requestMoneyController.checkUserExist();
                                    },
                                    suffixWidget: GestureDetector(
                                      onTap: () {
                                        requestMoneyController.changeSelectedMethod();
                                        requestMoneyController.checkUserExist();
                                      },
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.arrow_right_alt_sharp,
                                            color: requestMoneyController.isValidNumber ? MyColor.primaryColor : MyColor.getGreyText(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(height: Dimensions.space2),
                                  // requestMoneyController.numberController.text.isNotEmpty
                                  //     ? Row(
                                  //         children: [
                                  //           const Icon(
                                  //             Icons.info,
                                  //             color: MyColor.primaryColor,
                                  //             size: 14,
                                  //           ),
                                  //           const SizedBox(width: Dimensions.space5),
                                  //           Text(
                                  //             MyStrings.pleaseEnterNumberWithCountrycode.tr,
                                  //             style: regularSmall.copyWith(color: MyColor.pendingColor),
                                  //           )
                                  //         ],
                                  //       )
                                  //     : const SizedBox.shrink(),
                                  // const SizedBox(height: Dimensions.space20),
                                  // MoneyRequestRecentSection(moneyRequestController: requestMoneyController),
                                  // const SizedBox(
                                  //   height: Dimensions.space20,
                                  // ),
                                  // Text(
                                  //   MyStrings.allContacts.tr,
                                  //   style: boldDefault,
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  // const SizedBox(
                                  //   height: Dimensions.space20,
                                  // ),
                                  // if (requestMoneyController.contactController.isPermissonGranted == false && requestMoneyController.contactController.isLoading == false) ...[
                                  //   const ContactRequestWidget(),
                                  // ] else ...[
                                  //   !showListView
                                  //       ? SingleChildScrollView(
                                  //           child: Column(
                                  //             children: List.generate(10, (index) => const ContactCardShimmer()),
                                  //           ),
                                  //         )
                                  //       : controller.filterContact.isEmpty && controller.isLoading == false
                                  //           ? Container(
                                  //               margin: EdgeInsets.only(top: context.height / 6),
                                  //               padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  //               child: Center(
                                  //                 child: Text(
                                  //                   MyStrings.noContactFound.tr,
                                  //                   style: regularDefault.copyWith(color: MyColor.colorGrey),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           : MoneyRequestContactList(controller: controller, moneyRequestController: requestMoneyController)
                                  // ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
