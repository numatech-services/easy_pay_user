import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/home/home_controller.dart';
import 'package:viserpay/view/components/bottom-sheet/bottom_sheet_header_row.dart';

class AllItemBottomshet extends StatefulWidget {
  const AllItemBottomshet({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AllItemBottomshet();
  }
}

class _AllItemBottomshet extends State<AllItemBottomshet> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final subList = controller.moduleList.sublist(7, controller.moduleList.length);
        final list = MyUtils.removeWidget(widgets: subList, showMoreWidget: true);

        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          // padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const BottomSheetHeaderRow(),
                const SizedBox(height: Dimensions.space10),
                Column(
                  children: List.generate(list.length, (index) {
                    return list[index].animate().fadeIn(duration: 700.ms);
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
