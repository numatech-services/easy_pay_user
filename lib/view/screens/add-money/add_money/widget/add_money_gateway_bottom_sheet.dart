import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/url_container.dart';
import 'package:viserpay/data/controller/add_money/add_money_method_controller.dart';
import 'package:viserpay/data/model/add_money/add_money_method_response_model.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_close_button.dart';
import 'package:viserpay/view/components/card/bottom_sheet_card.dart';
import 'package:viserpay/view/components/image/my_image_widget.dart';

class AddMoneyGatewayBottomSheet extends StatelessWidget {
  const AddMoneyGatewayBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddMoneyMethodController>(builder: (controller) {
      return Column(
        children: [
          const BottomSheetBar(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [BottomSheetCloseButton()],
          ),
          const SizedBox(height: Dimensions.space15),
          SizedBox(
            height: context.height / 2,
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.gatewayList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      final controller = Get.find<AddMoneyMethodController>();
                      PaymentMethods selectedValue = controller.gatewayList[index];
                      controller.selectPaymentMethod(selectedValue);
                      Navigator.pop(context);

                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: BottomSheetCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              MyImageWidget(
                                imageUrl: '${UrlContainer.domainUrl}/${controller.imagePath}/${controller.gatewayList[index].method?.image}',
                                height: 40,
                                width: 60,
                                boxFit: BoxFit.contain,
                              ),
                              const SizedBox(width: Dimensions.space10),
                              Text(
                                controller.gatewayList[index].name.toString(),
                                style: regularDefault,
                              ),
                            ],
                          ),
                          Radio(
                            value: controller.gatewayList[index].id == controller.selectedPaymentMethods.id,
                            groupValue: true,
                            onChanged: (v) {
                              PaymentMethods selectedValue = controller.gatewayList[index];
                              controller.selectPaymentMethod(selectedValue);
                              Navigator.pop(context);

                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      );
    });
  }
}
