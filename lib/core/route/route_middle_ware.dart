import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viserpay/core/helper/shared_preference_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/global/user/user_model.dart';
import 'package:viserpay/push_notification_service.dart';

class RouteMiddleWare {
  //
  static Future<void> checkUserStatusAndGoToNextStep(
      {GlobalUser? user,
      String accessToken = "",
      String tokenType = ""}) async {
    bool needEmailVerification = user?.ev == "1" ? false : true;
    bool needSmsVerification = user?.sv == '1' ? false : true;
    // bool isTwoFactorEnable = user?.tv == '1' ? false : false;
    bool isProfileCompleteEnable = user?.profileComplete == '0' ? true : false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        SharedPreferenceHelper.userIdKey, user?.id.toString() ?? '-1');
    await sharedPreferences.setString(
        SharedPreferenceHelper.userEmailKey, user?.email ?? '');
    await sharedPreferences.setString("mobile", user?.mobile ?? '');
    await sharedPreferences.setString(
        SharedPreferenceHelper.userNameKey, user?.username ?? '');
    await sharedPreferences.setString(
        SharedPreferenceHelper.isic_num, user?.isic_num ?? '');
    await sharedPreferences.setString(
        SharedPreferenceHelper.matricule, user?.matricule ?? '');

    if (accessToken.isNotEmpty) {
      await sharedPreferences.setString(
          SharedPreferenceHelper.accessTokenKey, accessToken);
      await sharedPreferences.setString(
          SharedPreferenceHelper.accessTokenType, tokenType);
    }

    if (isProfileCompleteEnable) {
      Get.offAndToNamed(RouteHelper.profileCompleteScreen);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else {
      printx('go to home form route middleware');
      PushNotificationService(apiClient: Get.find()).sendUserToken();
      Get.offAndToNamed(RouteHelper.bottomNavBar, arguments: [true]);
    }
  }
  //
}
