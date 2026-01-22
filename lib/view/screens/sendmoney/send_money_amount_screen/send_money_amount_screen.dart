// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/send_money/sendmoney_controller.dart';
import 'package:viserpay/data/model/contact/user_contact_model.dart';
import 'package:viserpay/data/repo/send_money/send_money_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/cash-card/balance_box_card.dart';
import 'package:viserpay/view/components/cash-card/user/user_card.dart';
import 'package:viserpay/view/components/cash-card/title_card.dart';
import 'package:viserpay/view/components/checkbox/custom_check_box.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/custom_radio_button.dart';
import 'package:viserpay/view/components/image/custom_svg_picture.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class SendMoneyAmountScreen extends StatefulWidget {
  const SendMoneyAmountScreen({super.key});
 
  @override
  State<SendMoneyAmountScreen> createState() => _SendMoneyAmountScreenState();
}

class _SendMoneyAmountScreenState extends State<SendMoneyAmountScreen> {
  final InActivityTimer timer = InActivityTimer();
  List<String> ticketTypes = ['Petit Déjeuner', 'Déjeuner', 'Dîner', 'Transport'];
String? selectedTicketType;
  @override
  void initState() {
    String? username = Get.arguments != null ? Get.arguments[0] : null;
    String? mobile = Get.arguments != null ? Get.arguments[1] : null;
   

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SendMoneyRepo(apiClient: Get.find()));
    final controller = Get.put(SendMoneyContrller(
      sendMoneyRepo: Get.find(),
    ));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.amountController.clear();
      if (username != null && mobile != null) {
        controller.isLoading = true;
        controller.update();
        controller.initialValue();

        controller.selectContact(UserContactModel(name: username, number: mobile));
        controller.sendMoneyRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
        controller.quickAmountList = controller.sendMoneyRepo.apiClient.getQuickAmountList();

        controller.isLoading = false;
        controller.update();
      }
    });
    timer.startTimer(context);
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
          appBar: CustomAppBar(
            title: MyStrings.sendMoney,
            isTitleCenter: true,
            elevation: 0.1,
          ),
          body: GetBuilder<SendMoneyContrller>(builder: (controller) {
            return controller.isLoading
                ? const CustomLoader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: Dimensions.defaultPaddingHV,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TitleCard(
                            title: "${MyStrings.to.tr} ",
                            onlyBottom: true,
                            widget: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: UserCard(
                                title: controller.selectedContact?.name ?? "",
                                subtitle: "+${controller.selectedContact?.number}",
                                imgWidget: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: MyColor.primaryColor.withOpacity(0.2),
                                  ),
                                  child: const CustomSvgPicture(image: MyIcon.user),
                                ),
                              ),  
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.space16,
                          ),
                        BalanceBoxCard(
                          onpress: () async {
                            printx(controller.currentBalance);
        
                            int currntBalance = int.parse(controller.currentBalance);
        
                            if (controller.amountController.text.trim().isNotEmpty) {
                              bool isValid = await MyUtils().balanceValidation(
                                currentBalance: currntBalance,
                                amount: int.parse(controller.amountController.text) ,
                              );
        
                              if (isValid) {
                                Get.toNamed(RouteHelper.sendMoneyPinScreen);
                              }
                            } else {
                              CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
                            }
                          },
                          textEditingController: controller.amountController,
                          focusNode: controller.amountFocusNode,
                        ),
        
                          const SizedBox(
                            height: Dimensions.space16,
                          ),
                  SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Container(
                              width: 200,
                              margin: const EdgeInsets.all(Dimensions.space2),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
                              decoration: BoxDecoration(
                                color: MyColor.colorWhite,
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                  color: MyColor.borderColor,
                                  width: 0.7,
                                ),
                              ),
                              child: TextField(
                              controller: controller.amountController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center, // Centre le texte dans le champ
                              decoration: const InputDecoration(
                                hintText: "Nombre de tickets",
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                MyUtils().validateAndUpdateAmount(controller.amountController, value);
                              },
                            ),
        
                            ),
                          ],
                        ),
                      ),
                     const SizedBox(height: 20), 
                     DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Type de ticket',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  value: selectedTicketType,
  onChanged: (value) {
    setState(() {
      selectedTicketType = value;
      controller.type_payment = value ?? '';
    });
  },
  items: ticketTypes.map((type) {
    return DropdownMenuItem<String>(
      value: type,
      child: Text(type),
    );
  }).toList(),
)

                    //  Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Switch(
                    //           value: controller.isFeesIncluded, 
                    //           onChanged: (value) {
                    //             setState(() {
                    //               controller.isFeesIncluded = value; 
                    //               controller.saveFeeIncludedStatus(value); 
                    //             });
                    //           },
                    //           activeColor: Colors.green, 
                    //           inactiveThumbColor: Colors.grey, 
                    //         ),
                    //         const Text(
                    //           "Frais inclus",
                    //           style: TextStyle(fontSize: 16),
                    //         ),
                    //       ],
                    //     ),
        
        
                        ],
                      ),
                    ),
                  );
          }),
        ),
      ),
    );
  }
}
