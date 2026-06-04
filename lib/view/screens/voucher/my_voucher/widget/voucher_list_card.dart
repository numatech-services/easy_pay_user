import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/date_converter.dart';
import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/voucher/voucher_list_controller.dart';
import '../../../../components/animated_widget/expanded_widget.dart';
import '../../../../components/card/custom_card.dart';
import '../../../../components/column_widget/card_column.dart';
import '../../../../components/custom_loader/custom_loader.dart';
import '../../../../components/divider/custom_divider.dart';
import '../../../add-money/add_money_history/widget/status_widget.dart';

class VoucherListCard extends StatefulWidget {
  final ScrollController scrollController;
  const VoucherListCard({super.key, required this.scrollController});

  @override
  State<VoucherListCard> createState() => _VoucherListCardState();
}

class _VoucherListCardState extends State<VoucherListCard> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoucherListController>(
      builder: (controller) => ListView.separated(
        controller: widget.scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.voucherList.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
        itemBuilder: (context, index) {
          if (controller.voucherList.length == index) {
            return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {
              controller.changeSelectedIndex(index);
            },
            child: CustomCard(
              paddingTop: Dimensions.space15,
              paddingBottom: Dimensions.space15,
              width: MediaQuery.of(context).size.height,
              radius: Dimensions.defaultRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CardColumn(
                        isCopyable: true,
                        header: MyStrings.voucherCode,
                        body: controller.voucherList[index].voucherCode ?? "",
                      ),
                      CardColumn(
                          alignmentEnd: true,
                          header: MyStrings.initiated,
                          body: DateConverter.isoStringToLocalDateOnly(
                            controller.voucherList[index].createdAt ?? "",
                          ))
                    ],
                  ),
                  const CustomDivider(space: Dimensions.space15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CardColumn(header: MyStrings.amount, body: "${controller.currencySym}${StringConverter.formatNumber(controller.voucherList[index].amount ?? "")} "),
                      StatusWidget(status: controller.voucherList[index].isUsed == "0" ? MyStrings.notUsed : MyStrings.used, color: controller.voucherList[index].isUsed == "0" ? MyColor.colorOrange : MyColor.colorGreen),
                    ],
                  ),
                  ExpandedSection(
                    expand: controller.selectedIndex == index,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.space15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${MyStrings.usedAt.tr}: ',
                              style: regularSmall.copyWith(color: MyColor.getTextColor().withOpacity(0.6)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Dimensions.space5),
                            Text(
                              controller.voucherList[index].isUsed == "0" ? MyStrings.nA.tr : DateConverter.isoStringToLocalDateOnly(controller.voucherList[index].createdAt ?? ""),
                              style: regularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
