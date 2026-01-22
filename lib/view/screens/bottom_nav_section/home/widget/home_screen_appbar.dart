import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/view/screens/edit_profile/widget/profile_image.dart';
import 'package:viserpay/data/controller/isic/ticket_balance_controller.dart';

import '../../../../../core/route/route.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_icon.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/util.dart';
import '../../../../../data/controller/home/home_controller.dart';
import '../../../../components/image/custom_svg_picture.dart';
import '../../../../components/image/my_image_widget.dart';

PreferredSize homeScreenAppBar(
  BuildContext context,
  HomeController controller,
  GlobalKey<ScaffoldState> bottomNavScaffoldKey,
) {

  final ticketCtrl = Get.find<TicketBalanceController>();
  final screenWidth = MediaQuery.of(context).size.width;

  return PreferredSize(
    preferredSize: Size(screenWidth, 160),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2.0),
            blurRadius: 4.0,
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ligne principale : image + nom + solde + menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image utilisateur
                if (controller.isLoading)
                  Shimmer.fromColors(
                    baseColor: MyColor.colorGrey.withOpacity(0.2),
                    highlightColor: MyColor.primaryColor.withOpacity(0.7),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: MyColor.colorGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => Get.toNamed(RouteHelper.profileScreen),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: MyColor.borderColor, width: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: controller.userimage == "null" ||
                                controller.userimage == ""
                            ? ProfileWidget(imagePath: "", onClicked: () {})
                            : MyImageWidget(
                                imageUrl: controller.userimage,
                                boxFit: BoxFit.cover),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),

                // Nom et solde
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      if (controller.isLoading)
                        Shimmer.fromColors(
                          baseColor: MyColor.colorGrey.withOpacity(0.2),
                          highlightColor: MyColor.primaryColor.withOpacity(0.7),
                          child: Container(
                            width: screenWidth * 0.4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: MyColor.colorGrey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        )
                      else
                        Text(
                          controller.fullName.toUpperCase(),
                          style: heading.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MyColor.getTextColor(),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                      const SizedBox(height: 5),

                      // Bouton solde
                      Material(
                        color: MyColor.borderColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: controller.changeState,
                          child: Obx(
                            () => Container(
                              width: screenWidth * 0.45,
                              height: 28,
                              decoration: BoxDecoration(
                                color: MyColor.primaryColor.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedOpacity(
                                    opacity:
                                        controller.isBalanceShown.value ? 1 : 0,
                                    duration: const Duration(milliseconds: 500),
                                    child: Text(
                                      controller.userBalance,
                                      style: const TextStyle(
                                          color: MyColor.primaryColor,
                                          fontSize: 14),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    left:
                                        controller.isAnimation.value ? 12 : 22,
                                    child: AnimatedOpacity(
                                      opacity:
                                          controller.isBalance.value ? 1 : 0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 10),
                                        child: Text(
                                          MyStrings.tapForBalance.tr,
                                          style: TextStyle(
                                            color: MyColor.primaryColor
                                                .withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration:
                                        const Duration(milliseconds: 1100),
                                    left:
                                        controller.isAnimation.value ? 145 : 2,
                                    curve: Curves.fastOutSlowIn,
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: MyColor.primaryColor
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                          controller.defaultCurrencySymbol,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Bouton menu
                GestureDetector(
                  onTap: () =>
                      bottomNavScaffoldKey.currentState!.openEndDrawer(),
                  child: const CustomSvgPicture(
                    image: MyIcon.menutop,
                    color: MyColor.colorBlack,
                    height: 24,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 10),

/// SOLDES DES TICKETS
Obx(() {
  if (ticketCtrl.isLoading.value) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: List.generate(
          4,
          (_) => Expanded(
            child: Container(
              height: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
    
  }

  final balance = ticketCtrl.balance.value;

if (balance != null) {
  return Row(
    children: [
      _ticketCard("Petit-déjeuner", balance.petitDejeuner, Colors.orange),
      _ticketCard("Déjeuner", balance.dejeuner, Colors.green),
      _ticketCard("Dîner", balance.diner, Colors.blue),
      _ticketCard("Transport", balance.transport, Colors.red),
    ],
  );
}

  ///  CAS DEBUG : AFFICHER JSON API
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.redAccent),
    ),
    child: Text(
      ticketCtrl.rawJson.value.isEmpty
          ? "Aucune donnée reçue"
          : ticketCtrl.rawJson.value,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.red,
      ),
    ),
  );
}),

          ],
        ),
      ),
    ),
  );
  
}

// Widget _ticketCard(String title, int value, Color color) {
//   return Expanded(
//     child: Container(
//       height: 55,
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 11),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value.toString(),
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _ticketCard(String title, int value, Color color) {
  return Expanded(
    child: Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  
}