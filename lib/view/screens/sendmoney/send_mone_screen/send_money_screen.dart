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
import 'package:viserpay/data/controller/send_money/sendmoney_controller.dart';
import 'package:viserpay/data/repo/send_money/send_money_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/dialog/app_dialog.dart';
import 'package:viserpay/view/components/global/history_icon_widget.dart';
import 'package:viserpay/view/components/permisson_widget/contact_request_widget.dart';
import 'package:viserpay/view/components/shimmer/contact_card_shimmer.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';
import 'package:viserpay/view/screens/sendmoney/send_mone_screen/widget/send_money_contact_list.dart';
import 'package:viserpay/view/screens/sendmoney/send_mone_screen/widget/send_money_recent_section.dart';

class SendmoneyScreen extends StatefulWidget {
  const SendmoneyScreen({super.key});
 
  @override
  State<SendmoneyScreen> createState() => _SendmoneyScreenState();
}

class _SendmoneyScreenState extends State<SendmoneyScreen> {
  bool showListView = false; // Flag to control whether to show the ListView
  bool isSearching = false;
  final InActivityTimer timer = InActivityTimer();
  @override
  void initState() {
    MyUtils.allScreen();

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SendMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(SendMoneyContrller(
      sendMoneyRepo: Get.find(),
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
            title: MyStrings.sendMoney,
            isTitleCenter: true,
            elevation: 0.1,
            action: [
              HistoryWidget(routeName: RouteHelper.sendMoneyHistoryScreen),
              const SizedBox(
                width: Dimensions.space20,
              ),
            ],
          ),
          body: GetBuilder<SendMoneyContrller>(
            builder: (sendController) {
              return 
              sendController.isLoading
                  ? const CustomLoader()
                  :
                   RefreshIndicator(
                      onRefresh: () async {
                        sendController.initialValue();
                      },
                      child: StatefulBuilder(
                        builder: (context, setState) {
                       
        
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
                                    
                                    },
                                    inputAction: TextInputAction.go,
                                    hintText: "Entrez le numéro ISIC du bénéficiaire",
                                    controller: sendController.numberController,
                                    focusNode: sendController.numberFocusNode,
                                    isShowSuffixIcon: true,
                                    onSubmit: () {
                                      sendController.checkUserExist();
                                    }, 
                                    suffixWidget: GestureDetector(
                                      onTap: () {
                                        sendController.checkUserExist();
                                      },
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.arrow_right_alt_sharp,
                                            color:  MyColor.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.space16),
        
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              thickness: 1.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
                                            child: Text(
                                              "Ou",
                                              style: regularDefault.copyWith(
                                                color: MyColor.primaryColor,
                                                fontSize: Dimensions.fontOverLarge,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              thickness: 1.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                              const SizedBox(height: Dimensions.space16),
        
                                  GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                await MyUtils().isCameraPemissonGranted().then((value) {
                                  if (value == PermissionStatus.granted) {
                                    
                                    Get.toNamed(RouteHelper.qrCodeScanner, arguments: [
                                      "send_money",
                                      //  RouteHelper.qrCodeScanner
                                    ]);
                                  } else {
                                    AppDialog().permissonQrCode();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.space8),
                                decoration: BoxDecoration(border: Border.all(color: MyColor.primaryColor, width: 1.3), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      MyImages.menuQrCode,
                                      height: 24,
                                      color: MyColor.primaryColor,
                                    ),
                                    const SizedBox(
                                      width: Dimensions.space10,
                                    ),
                                    Text(
                                      "Scannez pour envoyer à un bénéficiaire",
                                      style: regularDefault.copyWith(
                                        color: MyColor.primaryColor,
                                        fontSize: Dimensions.fontLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                                  
                                  
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: MyColor.colorWhite,
          //   onPressed: () async {
          //     await MyUtils().isCameraPemissonGranted().then((value) {
          //       if (value == PermissionStatus.granted) {
          //         Get.toNamed(RouteHelper.qrCodeScanner, arguments: [
          //           MyStrings.expectedUser,
          //           RouteHelper.sendMoneyAmountScreen,
          //         ]);
          //       } else {
          //         AppDialog().permissonQrCode();
          //       }
          //     });
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.all(Dimensions.space12),
          //     child: Image.asset(
          //       MyImages.scan,
          //       color: MyColor.primaryColor,
          //       width: 40,
          //       height: 40,
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
