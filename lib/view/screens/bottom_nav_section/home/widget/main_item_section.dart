import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/home/home_controller.dart';

class MainItemSection extends StatelessWidget {
  const MainItemSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final list = MyUtils.makeSloteWidget(widgets: controller.moduleList, showMoreWidget: controller.moduleList.length < 4 ? true : (controller.moduleList.length <= 4 ? true : controller.showMoreWidget));
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15,
                vertical: Dimensions.space15,
              ),
              child: Column(
                children: List.generate(list.length, (index) => list[index]),
              ),
            ),
            if (controller.moduleList.length > 4) ...[
              Positioned(
                bottom:0,
                right: 0,
                left: 0,
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: Dimensions.space15,
                    vertical: 0,
                  ),
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: controller.showMoreWidget
                        ? null
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              MyColor.getSecondaryScreenBgColor().withOpacity(0.1),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                    border: Border(
                      bottom: BorderSide(
                        color: MyColor.getPrimaryColor().withOpacity(0.1),
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(Dimensions.cardRadius),
                      bottomRight: Radius.circular(Dimensions.cardRadius),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        controller.changeShowMoreWidgetState();
                      },
                      splashFactory: NoSplash.splashFactory,
                      customBorder: const CircleBorder(),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: Dimensions.space10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyColor.colorWhite,
                        ),
                        child: !controller.showMoreWidget
                            ? Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: MyColor.getPrimaryColor(),
                                size: Dimensions.space30,
                              )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                  delay: 600.ms,
                                )
                                .moveY(begin: -2, end: 3, duration: 1000.ms)
                            : Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: MyColor.getPrimaryColor(),
                                size: Dimensions.space30,
                              ),
                      ),
                    ),
                  ),
                ),
              )
            ]
          ],
        );
      },
    );
  }
}
