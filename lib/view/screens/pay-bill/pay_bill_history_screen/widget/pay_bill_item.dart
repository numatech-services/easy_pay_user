import 'package:flutter/material.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/style.dart';

import '../../../../components/image/my_image_widget.dart';

class BillPayItem extends StatelessWidget {
  String name, image;
  bool? isSelect;
  int index;
  BillPayItem({
    super.key,
    required this.name,
    required this.image,
    required this.index,
    this.isSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 45,
          width: 45,
          padding: const EdgeInsets.all(Dimensions.space5),
          decoration: BoxDecoration(
            border: Border.all(color: MyColor.getSymbolColor(index), width: 1),
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
            color: MyColor.getSymbolColor(index).withOpacity(0.1),
          ),
          child: MyImageWidget(
            imageUrl: image,
            radius: Dimensions.defaultRadius,
            height: 35,
            width: 35,
            color: MyColor.getSymbolColor(index),
          ),
        ),
        const SizedBox(height: Dimensions.space5),
        Text(
          name,
          style: regularSmall,
          maxLines: 2,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
