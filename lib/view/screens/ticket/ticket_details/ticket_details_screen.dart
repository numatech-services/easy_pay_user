import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/controller/support/ticket_details_controller.dart';
import 'package:viserpay/data/repo/support/support_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/buttons/circle_icon_button.dart';
import 'package:viserpay/view/components/buttons/custom_circle_animated_button.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/dialog/app_dialog.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';
import 'package:viserpay/view/components/text/label_text.dart';
import 'package:viserpay/view/screens/ticket/ticket_details/widget/ticket_meassge_widget.dart';

import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  String title = "";
  String ticketId = "-1";
  @override
  void initState() {
    ticketId = Get.arguments[0];
    title = Get.arguments[1];
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    var controller = Get.put(TicketDetailsController(repo: Get.find(), ticketId: ticketId));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: GetBuilder<TicketDetailsController>(builder: (controller) {
        return controller.isLoading
            ? const CustomLoader(
                isFullScreen: true,
              )
            : SingleChildScrollView(
                padding: Dimensions.screenPaddingHV,
                child: Container(
                  // padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.space15),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: MyColor.getCardBgColor(),
                            border: Border.all(
                              color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                                    decoration: BoxDecoration(
                                      color: controller.getStatusColor(controller.model.data?.myTickets?.status ?? "0").withOpacity(0.2),
                                      border: Border.all(color: controller.getStatusColor(controller.model.data?.myTickets?.status ?? "0"), width: 1),
                                      borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                                    ),
                                    child: Text(
                                      controller.getStatusText(controller.model.data?.myTickets?.status ?? '0'),
                                      style: regularDefault.copyWith(
                                        color: controller.getStatusColor(controller.model.data?.myTickets?.status ?? "0"),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                    height: 2,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "[${MyStrings.ticket.tr}#${controller.model.data?.myTickets?.ticket ?? ''}] ${controller.model.data?.myTickets?.subject ?? ''}",
                                      style: boldDefault.copyWith(
                                        color: Theme.of(context).textTheme.titleLarge!.color!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                            if (controller.model.data?.myTickets?.status != '3')
                              CustomCircleAnimatedButton(
                                onTap: () {
                                  AppDialog().warningAlertDialog(context, msgText: MyStrings.closeTicketWarningTxt.tr, () {
                                    Get.back();
                                    controller.closeTicket(controller.model.data?.myTickets?.id.toString() ?? '-1');
                                  });
                                },
                                height: 40,
                                width: 40,
                                backgroundColor: MyColor.colorRed,
                                child: controller.closeLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: MyColor.colorWhite,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.close_rounded, color: MyColor.colorWhite, size: 20),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: MyColor.getCardBgColor(),
                            border: Border.all(
                              color: MyColor.borderColor.withOpacity(0.8),
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            CustomTextField(
                              labelText: MyStrings.message,
                              needOutlineBorder: true,
                              controller: controller.replyController,
                              hintText: MyStrings.yourReply.tr,
                              maxLines: 4,
                              onChanged: (value) {},
                            ),
                            const SizedBox(height: 10),
                            LabelText(text: MyStrings.attachments.tr),
                            if (controller.attachmentList.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        controller.attachmentList.length,
                                        (index) => Row(
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.all(Dimensions.space5),
                                                  decoration: const BoxDecoration(),
                                                  child: controller.isImage(controller.attachmentList[index].path)
                                                      ? ClipRRect(
                                                          borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                                                          child: Image.file(
                                                            controller.attachmentList[index],
                                                            width: context.width / 5,
                                                            height: context.width / 5,
                                                            fit: BoxFit.cover,
                                                          ))
                                                      : controller.isXlsx(controller.attachmentList[index].path)
                                                          ? Container(
                                                              width: context.width / 5,
                                                              height: context.width / 5,
                                                              decoration: BoxDecoration(
                                                                color: MyColor.colorWhite,
                                                                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                                                                border: Border.all(color: MyColor.borderColor, width: 1),
                                                              ),
                                                              child: Center(
                                                                child: SvgPicture.asset(
                                                                  MyIcon.xlsx,
                                                                  height: 45,
                                                                  width: 45,
                                                                ),
                                                              ),
                                                            )
                                                          : controller.isDoc(controller.attachmentList[index].path)
                                                              ? Container(
                                                                  width: context.width / 5,
                                                                  height: context.width / 5,
                                                                  decoration: BoxDecoration(
                                                                    color: MyColor.colorWhite,
                                                                    borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                                                                    border: Border.all(color: MyColor.borderColor, width: 1),
                                                                  ),
                                                                  child: Center(
                                                                    child: SvgPicture.asset(
                                                                      MyIcon.doc,
                                                                      height: 45,
                                                                      width: 45,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  width: context.width / 5,
                                                                  height: context.width / 5,
                                                                  decoration: BoxDecoration(
                                                                    color: MyColor.colorWhite,
                                                                    borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                                                                    border: Border.all(color: MyColor.borderColor, width: 1),
                                                                  ),
                                                                  child: Center(
                                                                    child: SvgPicture.asset(
                                                                      MyIcon.pdfFile,
                                                                      height: 45,
                                                                      width: 45,
                                                                    ),
                                                                  ),
                                                                ),
                                                ),
                                                CircleIconButton(
                                                  onTap: () {
                                                    controller.removeAttachmentFromList(index);
                                                  },
                                                  height: Dimensions.space20 + 5,
                                                  width: Dimensions.space20 + 5,
                                                  backgroundColor: MyColor.redCancelTextColor,
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: MyColor.colorWhite,
                                                    size: Dimensions.space15,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ] else ...[
                              ZoomTapAnimation(
                                onTap: () {
                                  controller.pickFile();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space30),
                                  margin: const EdgeInsets.only(top: Dimensions.space5),
                                  width: context.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: MyColor.primaryColor, width: .5),
                                    borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                                    color: MyColor.primaryColor.withOpacity(0.1),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.attachment_rounded, color: MyColor.colorGrey),
                                      Text(MyStrings.chooseFile.tr, style: lightDefault.copyWith(color: MyColor.colorGrey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: Dimensions.space30),
                            GradientRoundedButton(
                              isLoading: controller.submitLoading,
                              text: MyStrings.reply.tr,
                              press: () {
                                controller.uploadTicketViewReply();
                              },
                            ),
                            const SizedBox(height: Dimensions.space30),
                          ],
                        ),
                      ),
                      controller.messageList.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space20),
                              decoration: BoxDecoration(
                                color: MyColor.colorGrey1,
                                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    MyStrings.noMSgFound.tr,
                                    style: regularDefault.copyWith(color: MyColor.colorGrey),
                                  ),
                                ],
                              ))
                          : Container(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.messageList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => TicketViewCommentReplyModel(
                                  index: index,
                                  messages: controller.messageList[index],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}


//