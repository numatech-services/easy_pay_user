import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/data/controller/support/new_ticket_controller.dart';
import 'package:viserpay/data/repo/support/support_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/buttons/circle_icon_button.dart';
import 'package:viserpay/view/components/buttons/gradient_rounded_button.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/text-form-field/custom_text_field.dart';
import 'package:viserpay/view/components/text/label_text.dart';

class AddNewTicketScreen extends StatefulWidget {
  const AddNewTicketScreen({super.key});

  @override
  State<AddNewTicketScreen> createState() => _AddNewTicketScreenState();
}

class _AddNewTicketScreenState extends State<AddNewTicketScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    Get.put(NewTicketController(repo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewTicketController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.screenBgColor,
        appBar: CustomAppBar(title: MyStrings.addNewTicket.tr),
        body: controller.isLoading
            ? const CustomLoader(isFullScreen: true)
            : SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.textToTextSpace),
                      CustomTextField(
                        labelText: MyStrings.subject,
                        hintText: MyStrings.enterYourSubject.tr,
                        controller: controller.subjectController,
                        isPassword: false,
                        isShowSuffixIcon: false,
                        needOutlineBorder: true,
                        nextFocus: controller.messageFocusNode,
                        onSuffixTap: () {},
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      LabelText(text: MyStrings.priority.tr),
                      const SizedBox(height: Dimensions.space5),
                      DropDownTextFieldContainer(
                        color: MyColor.colorGrey1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: DropdownButton<String>(
                            dropdownColor: MyColor.colorWhite,
                            value: controller.selectedPriority,
                            elevation: 8,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconDisabledColor: Colors.grey,
                            iconEnabledColor: MyColor.primaryColor,
                            isExpanded: true,
                            underline: Container(height: 0, color: Colors.deepPurpleAccent),
                            onChanged: (String? newValue) {
                              controller.setPriority(newValue);
                            },
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.space5),
                            borderRadius: BorderRadius.circular(0),
                            items: controller.priorityList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: regularDefault.copyWith(fontSize: Dimensions.fontDefault),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      CustomTextField(
                        labelText: MyStrings.message,
                        hintText: MyStrings.enterYourMessage.tr,
                        isPassword: false,
                        needOutlineBorder: true,
                        controller: controller.messageController,
                        maxLines: 5,
                        focusNode: controller.messageFocusNode,
                        isShowSuffixIcon: false,
                        onSuffixTap: () {},
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      InkWell(
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          controller.pickFile();
                        },
                        child: CustomTextField(
                          labelText: MyStrings.attachments,
                          hintText: MyStrings.enterFile.tr,
                          inputAction: TextInputAction.done,
                          isEnable: false,
                          isShowSuffixIcon: true,
                          needOutlineBorder: true,
                          onChanged: (value) {
                            return;
                          },
                          suffixWidget: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              controller.pickFile();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                              margin: const EdgeInsets.all(Dimensions.space5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: MyColor.primaryColor,
                              ),
                              child: Text(
                                MyStrings.upload.tr,
                                style: regularDefault.copyWith(color: MyColor.colorWhite),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5 - 3),
                      Text(MyStrings.supportedFileHint, style: regularDefault.copyWith(color: MyColor.highPriorityPurpleColor)),
                      const SizedBox(height: Dimensions.space10),
                      if (controller.attachmentList.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
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
                                        height: Dimensions.space20,
                                        width: Dimensions.space20,
                                        backgroundColor: MyColor.redCancelTextColor,
                                        child: const Icon(
                                          Icons.close,
                                          color: MyColor.colorWhite,
                                          size: Dimensions.space12,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                      const SizedBox(height: 30),
                      Center(
                        child: GradientRoundedButton(
                          isLoading: controller.submitLoading,
                          text: MyStrings.submit.tr,
                          press: () {
                            controller.submit();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class DropDownTextFieldContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  const DropDownTextFieldContainer({super.key, required this.child, this.color = MyColor.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        border: Border.all(color: MyColor.gbr, width: .5),
      ),
      child: child,
    );
  }
}
