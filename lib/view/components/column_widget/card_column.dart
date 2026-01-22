import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/style.dart';

import '../../../core/utils/my_strings.dart';
import '../snack_bar/show_custom_snackbar.dart';

class CardColumn extends StatelessWidget {
  final String header;
  final String body;
  final bool alignmentEnd;
  final bool isDate;
  final Color? textColor;
  String? subBody;
  TextStyle? headerTextStyle;
  TextStyle? bodyTextStyle;
  TextStyle? subBodyTextStyle;
  bool? isOnlyHeader;
  bool? isOnlyBody;
  bool? isCopyable;
  final int bodyMaxLine;
  double? space = 5;
  final int maxLine;

  CardColumn({
    super.key,
    this.maxLine = 1,
    this.bodyMaxLine = 1,
    this.alignmentEnd = false,
    required this.header,
    this.isDate = false,
    this.textColor,
    this.headerTextStyle,
    this.bodyTextStyle,
    required this.body,
    this.subBody,
    this.isOnlyHeader = false,
    this.isOnlyBody = false,
    this.space,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return isOnlyHeader!
        ? Column(
            crossAxisAlignment: alignmentEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                header.tr,
                style: headerTextStyle ?? regularSmall.copyWith(color: MyColor.getGreyText(), fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: space),
            ],
          )
        : Column(
            crossAxisAlignment: alignmentEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                header.tr,
                style: headerTextStyle ?? regularSmall.copyWith(color: MyColor.getTextColor().withOpacity(0.6)),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLine,
              ),
              SizedBox(height: space),
              if (isCopyable == true) ...[
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: body.toString())).then((value) => CustomSnackBar.success(successList: [MyStrings.copyLink]));
                  },
                  child: Row(
                    children: [
                      Text(
                        body.tr,
                        maxLines: bodyMaxLine,
                        style: isDate
                            ? regularDefault.copyWith(fontStyle: FontStyle.italic, color: textColor ?? MyColor.getTextColor(), fontSize: Dimensions.fontSmall)
                            : bodyTextStyle ??
                                regularSmall.copyWith(
                                  color: textColor ?? MyColor.getTextColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: Dimensions.space2),
                        child: Icon(Icons.copy_sharp, color: textColor ?? MyColor.getTextColor(), size: Dimensions.fontSmall),
                      )
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  body.tr,
                  maxLines: bodyMaxLine,
                  style: isDate ? regularDefault.copyWith(fontStyle: FontStyle.italic, color: textColor ?? MyColor.getTextColor(), fontSize: Dimensions.fontSmall) : bodyTextStyle ?? regularSmall.copyWith(color: textColor ?? MyColor.getTextColor(), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: Dimensions.space5),
              subBody != null
                  ? Text(subBody!.tr, maxLines: bodyMaxLine, style: isDate ? regularDefault.copyWith(fontStyle: FontStyle.italic, color: textColor ?? MyColor.getTextColor(), fontSize: Dimensions.fontSmall) : subBodyTextStyle ?? regularSmall.copyWith(color: textColor ?? MyColor.getTextColor().withOpacity(0.5), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)
                  : const SizedBox.shrink()
            ],
          );
  }
}
