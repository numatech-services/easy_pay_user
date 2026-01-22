import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/airtime/airtime_controller.dart';
import 'package:viserpay/view/components/image/my_image_widget.dart';

import '../../../../data/model/airtime/operator_response_model.dart';
import '../../../components/auto_height_grid_view/auto_height_grid_view.dart';

class AirtimeCountryBottomSheet {
  static void selectCountrySheet(BuildContext context, AirtimeController controller) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * .9,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: MyColor.colorGrey.withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.countryList.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyColor.getCardBgColor(), border: Border.all(width: .5, color: MyColor.primaryColor.withOpacity(.1)), boxShadow: MyUtils.getBottomSheetShadow()),
                          child: InkWell(
                            onTap: () {
                              controller.onCountryTap(controller.countryList[index]);
                            },
                            child: Row(
                              children: [
                                SvgPicture.network(
                                  width: 20,
                                  height: 20,
                                  placeholderBuilder: (context) => SpinKitFadingCube(
                                    color: MyColor.primaryColor.withOpacity(0.3),
                                    size: Dimensions.space20,
                                  ),
                                  controller.countryList[index].flagUrl ?? "",
                                ),
                                const SizedBox(
                                  width: Dimensions.space10,
                                ),
                                Text(controller.countryList[index].name.toString().tr, style: regularDefault.copyWith(color: MyColor.getTextColor())),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        });
  }

  static void selectOperatorBottomSheet(BuildContext context, AirtimeController controller) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * .9,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: MyColor.colorGrey.withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MyStrings.chooseOperator,
                            style: boldLarge.copyWith(color: MyColor.getTextColor()),
                          ),
                          Text(
                            MyStrings.chooseOperatorSubText,
                            style: regularSmall.copyWith(color: MyColor.getLabelTextColor()),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Get.back();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: AutoHeightGridView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: controller.operatorsList.length,
                    mainAxisSpacing: Dimensions.space10,
                    crossAxisSpacing: Dimensions.space10,
                    builder: (context, index) {
                      Operator operator = controller.operatorsList[index];
                      List<String> operatorImages = operator.logoUrls ?? [];
                      return InkWell(
                        onTap: () {
                          Get.back();
                          controller.onOperatorClick(operator, index);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: MyColor.colorWhite,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: operator.id == controller.selectedOperator.id ? MyColor.primaryColor.withOpacity(.8) : MyColor.primaryColor.withOpacity(.3),
                                    width: .5,
                                  ),
                                  boxShadow: MyUtils.getCardShadow()),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyImageWidget(
                                    width: 50,
                                    height: 50,
                                    boxFit: BoxFit.contain,
                                    imageUrl: operatorImages.isNotEmpty ? operatorImages.first : '',
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    operator.name ?? '',
                                    style: regularDefault.copyWith(color: MyColor.colorBlack),
                                    overflow: TextOverflow.visible,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            //selected
                            operator.id == controller.selectedOperator.id
                                ? Positioned(
                                    right: Dimensions.space12,
                                    top: Dimensions.space10,
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: MyColor.getPrimaryColor(),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: MyColor.colorWhite, size: 10),
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
