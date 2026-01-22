// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viserpay/core/helper/shared_preference_helper.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_images.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/core/utils/url_container.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/auth/login_controller.dart';
import 'package:viserpay/data/repo/auth/general_setting_repo.dart';
import 'package:viserpay/data/repo/auth/login_repo.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/image/custom_svg_picture.dart';
import 'package:viserpay/view/components/image/my_image_widget.dart';
import 'package:viserpay/view/components/text-form-field/customPinText.dart';
import 'package:viserpay/view/components/text/default_text.dart';
import 'package:viserpay/view/components/will_pop_widget.dart';
import 'package:viserpay/view/screens/auth/registration/widget/country_bottom_sheet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../environment.dart';
import '../../../components/buttons/gradient_rounded_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isNumberBlank = false;
  final formKey = GlobalKey<FormState>();
    bool hidePassword = true;
    
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    final controller = Get.put(LoginController(loginRepo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    MyUtils.allScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: MyColor.primaryColor, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: MyColor.screenBgColor, systemNavigationBarIconBrightness: Brightness.dark),
      child: WillPopWidget(
        nextRoute: '',
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size(context.width, isLandscape ? context.height * .45 : context.height * .3),
              child: ClipPath(
                clipper: CurveClipper(),
                child: Container(
                  height: 250, // Adjust the height of the curve
                  width: context.width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [MyColor.primaryColor, MyColor.primaryColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(height: 15,),
                      Center(
                        child: Image.asset(
                          MyImages.appLogo,
                          height: 160,
                          // color: MyColor.colorWhite,
                        ),
                      ),
                      // Get.find<LoginController>().loginRepo.apiClient.getMultiLanguageStatus()
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.end,
                      //         children: [
                      //           GestureDetector(
                      //             onTap: () {
                      //               Get.toNamed(RouteHelper.languageScreen);
                      //             },
                      //             child: Align(
                      //               alignment: Alignment.topRight,
                      //               child: Container(
                      //                 height: 30,
                      //                 alignment: Alignment.topRight,
                      //                 margin: const EdgeInsetsDirectional.only(top: 50, start: 15, end: 15),
                      //                 padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                      //                 decoration: BoxDecoration(border: Border.all(color: MyColor.borderColor, width: 1), borderRadius: BorderRadius.circular(4)),
                      //                 child: Row(
                      //                   mainAxisAlignment: MainAxisAlignment.end,
                      //                   children: [
                      //                     const Icon(Icons.g_translate, color: MyColor.colorWhite, size: 14.5),
                      //                     const SizedBox(
                      //                       width: Dimensions.space2 + 1,
                      //                     ),
                      //                     Text(
                      //                       Get.find<SharedPreferences>().getString(SharedPreferenceHelper.languageCode)?.toUpperCase() ?? Environment.defaultLangCode.toUpperCase(),
                      //                       style: regularDefault.copyWith(color: MyColor.colorWhite),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       )
                      //     : const SizedBox.shrink()
                    ],
                  ),
                ),
              )),
          backgroundColor: MyColor.getScreenBgColor(isWhite: true),
          body: GetBuilder<LoginController>(builder: (controller) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Stack(
                children: [
                  Padding(
                    padding: Dimensions.screenPaddingHV,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const SizedBox(height: 240),
                        Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(MyStrings.signIn.tr.toTitleCase(), style: title.copyWith(fontSize: 32)), //to your ViserPay account
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(MyStrings.loginMsg.tr, style: title.copyWith(fontSize: 16, color: MyColor.bodytextColor.withOpacity(0.6), fontWeight: FontWeight.w400)), //
                              ),
                              const SizedBox(height: Dimensions.space40),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: isNumberBlank ? MyColor.colorRed : MyColor.getTextFieldDisableBorder(), width: .5),
                                  borderRadius: BorderRadius.circular(10),
                                  // boxShadow: MyUtils.getShadow2(blurRadius: 10),
                                  color: MyColor.colorWhite,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
                                child: TextFormField(
                                  controller: controller.emailController,
                                   validator: (input) =>
                        !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                .hasMatch(input!)
                            ? "L'adresse email doit être valide"
                            : null,
                                  onFieldSubmitted: (text) => FocusScope.of(context).requestFocus(controller.passwordFocusNode),
                                  decoration: InputDecoration(
                                    
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(Dimensions.space15),
                                      child: Icon(Icons.email_outlined),
                                    ),
                                    hintText: "student@school.com",
                                    border: InputBorder.none, // Remove border
                                    filled: false, // Remove fill
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                                    hintStyle: regularMediumLarge.copyWith(color: MyColor.hintTextColor),
                                  ),
                                  keyboardType: TextInputType.text, // Set keyboard type to phone
                                  style: regularMediumLarge,
                                  cursorColor: MyColor.primaryColor, // Set cursor color to red
                               
                                ),
                              ),
                             SizedBox(height: 15,),
                             Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: isNumberBlank ? MyColor.colorRed : MyColor.getTextFieldDisableBorder(), width: .5),
                                  borderRadius: BorderRadius.circular(10),
                                  // boxShadow: MyUtils.getShadow2(blurRadius: 10),
                                  color: MyColor.colorWhite,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
                                child: TextFormField(
                                  controller: controller.passwordController,
                                  validator: (input) => input!.length < 3
                        ? "Le mot de passe doit contenir plus de 3 caractères"
                        : null,
                         obscureText: hidePassword,                                 
                           decoration: InputDecoration(
                                    
                        suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        color: Colors.black,
                        icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20),
                      ),
                                    hintText: "Mot de pass",
                                    
                                    border: InputBorder.none, // Remove border
                                    filled: false, // Remove fill
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                                    hintStyle: regularMediumLarge.copyWith(color: MyColor.hintTextColor),
                                  ),
                                  keyboardType: TextInputType.text, // Set keyboard type to phone
                                  style: regularMediumLarge,
                                  cursorColor: MyColor.primaryColor, // Set cursor color to red
                               
                                ),
                              ),
                              const SizedBox(height: 25),
                              GradientRoundedButton(
                                isLoading: controller.isSubmitLoading,
                                text: MyStrings.signIn.tr,
                                press: () {
                                  if (formKey.currentState!.validate()) {
                                    controller.loginUser();
                                  }
                                },
                              ),
                              if (controller.canCheckBiometricsAvalable == true && controller.loginRepo.apiClient.getfingerprintStatus() == true) ...[
                                Column(
                                  children: [
                                    const SizedBox(height: 35),
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            color: MyColor.borderColor,
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.space10),
                                        Text(
                                          MyStrings.or.toUpperCase(),
                                          style: title.copyWith(color: MyColor.colorGrey),
                                        ),
                                        const SizedBox(width: Dimensions.space10),
                                        const Expanded(
                                          child: Divider(
                                            color: MyColor.borderColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 25),
                                    GestureDetector(
                                      onTap: () {
                                        if (controller.isDisable == false) {
                                          controller.biomentricLoging();
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(left: Dimensions.space10),
                                          decoration: BoxDecoration(
                                            color: MyColor.getCardBgColor(),
                                            shape: BoxShape.circle,
                                            boxShadow: MyUtils.getShadow2(blurRadius: 14),
                                          ),
                                          child: Center(
                                            child: controller.isBioloading
                                                ? const CustomLoader(
                                                    isPagination: true,
                                                  )
                                                : CustomSvgPicture(
                                                    image: MyIcon.finger2,
                                                    width: 50,
                                                    height: 50,
                                                    color: !controller.isDisable ? MyColor.colorGrey.withOpacity(0.5) : MyColor.primaryColor,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      controller.isPermantlyLocked
                                          ? MyStrings.permantlyLockedPleaselockyourPhoneandTryagain.tr
                                          : controller.isDisable
                                              ? "Please try again after ${controller.countdownSeconds}s  Later"
                                              : '',
                                      style: regularDefault.copyWith(),
                                    ),
                                    controller.isDisable ? const SizedBox.shrink() : const SizedBox(height: 15),
                                  ],
                                )
                              ],
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Text(MyStrings.doNotHaveAccount.tr, overflow: TextOverflow.ellipsis, style: regularLarge.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w500)),
                              //     const SizedBox(width: Dimensions.space5),
                              //     TextButton(
                              //       onPressed: () {
                              //         Get.toNamed(RouteHelper.registrationScreen);
                              //       },
                              //       child: Text(MyStrings.signUp.tr, maxLines: 2, overflow: TextOverflow.ellipsis, style: regularLarge.copyWith(color: MyColor.getPrimaryColor())),
                              //     )
                              //   ],
                              // ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);

    var firstControlPoint = Offset(size.width / 1.6, size.height + 70);
    var firstEndPoint = Offset(size.width, size.height - 60.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
