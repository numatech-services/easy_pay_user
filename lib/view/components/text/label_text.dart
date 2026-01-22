import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/style.dart';

class LabelText extends StatefulWidget {
  final bool isRequired;
  final String text;
  final String? instruction;
  final TextAlign? textAlign;

  const LabelText({
    super.key,
    required this.text,
    this.textAlign,
    this.instruction,
    this.isRequired = false,
  });

  @override
  State<LabelText> createState() => _LabelTextState();
}

class _LabelTextState extends State<LabelText> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();
  @override
  Widget build(BuildContext context) {
    return widget.isRequired
        ? Row(
            children: [
              Text(
                widget.text.tr,
                textAlign: widget.textAlign,
                style: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
              ),
              const SizedBox(width: 2),
              if (widget.instruction != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: Dimensions.space2, end: Dimensions.space10),
                  child: Tooltip(
                      key: _tooltipKey,
                      message: "${widget.instruction}",
                      child: GestureDetector(
                        onTap: () {
                          _tooltipKey.currentState?.ensureTooltipVisible();
                        },
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: Dimensions.space15,
                          color: Theme.of(context).textTheme.titleLarge!.color?.withOpacity(0.8),
                        ),
                      )),
                ),
              ],
              Text(
                '*',
                style: semiBoldDefault.copyWith(color: MyColor.colorRed),
              )
            ],
          )
        : Text(
            widget.text.tr,
            textAlign: widget.textAlign,
            style: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
          );
  }
}
