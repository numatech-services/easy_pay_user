// ignore_for_file: unnecessary_null_comparison
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/shared_preference_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/route/route_middle_ware.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/isic/ticket_balance_controller.dart';
import 'package:viserpay/data/model/auth/login/login_response_model.dart';
import 'package:viserpay/data/model/country_model/country_model.dart';
import 'package:viserpay/data/model/general_setting/general_setting_response_model.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/repo/auth/login_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../environment.dart';

class LoginController extends GetxController {
  LoginRepo loginRepo;

  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode userFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<String> errors = [];
  String? email;
  String? password;
  String userLoginMethod = "";

  LoginController({required this.loginRepo});
  void getGS() {
    gsModel = loginRepo.apiClient.getGSData();

    userLoginMethod =
        gsModel.data?.generalSetting?.loginMethod.toString() ?? "";
    update();
  }

  GeneralSettingResponseModel gsModel = GeneralSettingResponseModel();

  String? countryName;
  String dialCode = Environment.defaultPhoneCode;
  void updateMobilecode(String code) {
    dialCode = code;
    update();
  }

  selectCountryData(Countries value) {
    selectedCountryData = value;
    update();
  }

  // country data
  Countries selectedCountryData = Countries();

  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  Future<dynamic> getCountryData() async {
    ResponseModel mainResponse = await loginRepo.getCountryList();

    if (mainResponse.statusCode == 200) {
      CountryModel model =
          CountryModel.fromJson(jsonDecode(mainResponse.responseJson));
      List<Countries>? tempList = model.data?.countries;

      if (tempList != null && tempList.isNotEmpty) {
        countryList.addAll(tempList);
      }
      var selectDefCountry = tempList!.firstWhere(
        (country) =>
            country.countryCode!.toLowerCase() ==
            Environment.defaultCountryCode.toLowerCase(),
        orElse: () => Countries(),
      );
      if (selectDefCountry.dialCode != null) {
        selectCountryData(selectDefCountry);
      }
      countryLoading = false;
      update();
      return;
    } else {
      CustomSnackBar.error(errorList: [mainResponse.message]);

      countryLoading = false;
      update();
      return;
    }
  }

  void forgetPassword() {
    clearTextField();
    Get.toNamed(RouteHelper.forgotPasswordScreen, arguments: countryList);
  }

  void checkAndGotoNextStep(LoginResponseModel responseModel) async {
    bool needEmailVerification =
        responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification =
        responseModel.data?.user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userIdKey,
        responseModel.data?.user?.id.toString() ?? '-1');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.accessTokenKey,
        responseModel.data?.accessToken ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.accessTokenType,
        responseModel.data?.tokenType ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userEmailKey,
        responseModel.data?.user?.email ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userPhoneNumberKey,
        responseModel.data?.user?.mobile ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userNameKey,
        responseModel.data?.user?.username ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.isic_num,
        responseModel.data?.user?.isicNum ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.matricule,
        responseModel.data?.user?.matricule ?? '');

    await loginRepo.sendUserToken();

    bool isProfileCompleteEnable =
        responseModel.data?.user?.profileComplete == '0' ? true : false;

        if (needSmsVerification == false &&
        needEmailVerification == false &&
        isTwoFactorEnable == false) {

      //  IMPORTANT : charger les soldes APRÈS que le token soit prêt
      await Get.find<TicketBalanceController>().fetchBalances();

      if (isProfileCompleteEnable) {
        Get.offAndToNamed(RouteHelper.profileCompleteScreen);
      } else {
        Get.offAndToNamed(RouteHelper.bottomNavBar);
      }
    }

    // else if (needSmsVerification == true && needEmailVerification == true && isTwoFactorEnable == true) {
    //   Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    // } else if (needSmsVerification == true && needEmailVerification == true) {
    //   Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    // } else if (needSmsVerification) {
    //   Get.offAndToNamed(RouteHelper.smsVerificationScreen, arguments: [isProfileCompleteEnable, isTwoFactorEnable]);
    // } else if (needEmailVerification) {
    //   Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [false, isProfileCompleteEnable, isTwoFactorEnable]);
    // }
    // else if (isTwoFactorEnable) {
    //   Get.offAndToNamed(RouteHelper.twoFactorScreen, arguments: isProfileCompleteEnable);
    // }

  }

  bool isSubmitLoading = false;
  void loginUser() async {
    isSubmitLoading = true;
    update();
    if (dialCode.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.selectyourCountry]);
    }

    String email = emailController.text;
    MyUtils().savePassword(passwordController.text.toString());
    ResponseModel model = await loginRepo.loginUser(
      password: passwordController.text.toString(),
      email: email,
      dialCode: "227",
    );
    loginRepo.apiClient.storePasscode(passwordController.text);
    loginRepo.apiClient.storeEmail(emailController.text);

    if (model.statusCode == 200) {
      LoginResponseModel loginModel =
          LoginResponseModel.fromJson(jsonDecode(model.responseJson));
//
await loginRepo.apiClient.sharedPreferences.setString(
  SharedPreferenceHelper.accessTokenKey,
  loginModel.data?.accessToken ?? ''
);

await loginRepo.apiClient.sharedPreferences.setString(
  SharedPreferenceHelper.accessTokenType,
  loginModel.data?.tokenType ?? 'Bearer'
);

//
      if (loginModel.status.toString().toLowerCase() == "success") {
        // checkAndGotoNextStep(loginModel);
        // print( loginModel.data?.user);
        String ph = loginRepo.apiClient.getEmail();
        String ps = loginRepo.apiClient.getPasscode();
        print("Email========================$ph");
        print("Pass========================$ps");

        passwordController.clear();
        emailController.clear();
        RouteMiddleWare.checkUserStatusAndGoToNextStep(
            user: loginModel.data?.user,
            accessToken: loginModel.data?.accessToken ?? '',
            tokenType: loginModel.data?.tokenType ?? '');
      } else {
        CustomSnackBar.error(
            errorList:
                loginModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
      }
    } else {
      CustomSnackBar.error(errorList: [model.message]);
    }

    isSubmitLoading = false;
    update();
  }

  void clearTextField() {
    passwordController.text = '';
    emailController.text = '';

    update();
  }

  void loadData() async {
    isDisable = false;
    isPermantlyLocked = false;
    countdownSeconds = 30;
    update();
    checkBiometricsAvalable();
    getGS();
    getCountryData();
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometricsAvalable = false;
  Future<void> checkBiometricsAvalable() async {
    bool t = await auth.isDeviceSupported();

    try {
      await auth.getAvailableBiometrics().then((value) {
        for (var element in value) {
          if ((element == BiometricType.fingerprint ||
                  element == BiometricType.weak ||
                  element == BiometricType.strong) &&
              t == true) {
            canCheckBiometricsAvalable = true;
            update();
          } else {
            canCheckBiometricsAvalable = false;
            update();
          }
        }
      });
    } catch (e) {
      canCheckBiometricsAvalable = false;
      update();
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool isDisable = false;
  bool isPermantlyLocked = false;
  bool isBioloading = false;

  Future<void> biomentricLoging() async {
    bool authenticated = false;
    isDisable = false;
    isPermantlyLocked = false;
    countdownSeconds = 30;
    update();

    try {
      // authenticated = await auth.authenticate(
      //   localizedReason: 'Scan your fingerprint to authenticate',
      //   options: const AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: true,
      //     useErrorDialogs: true,
      //     sensitiveTransaction: true,
      //   ),
      //   authMessages: [],
      // );
          authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        biometricOnly: true,
      );

      // .timeout(const Duration(seconds: 10));
      if (authenticated == true) {
        isBioloading = true;
        update();
        String ph = loginRepo.apiClient.getEmail();
        String ps = loginRepo.apiClient.getPasscode();
        print("Email========================$ph");
        print("Pass========================$ps");

        ResponseModel model = await loginRepo.loginUser(
          email: ph,
          password: ps,
          dialCode: "227",
        );

        if (model.statusCode == 200) {
          LoginResponseModel loginModel =
              LoginResponseModel.fromJson(jsonDecode(model.responseJson));
          if (loginModel.status.toString().toLowerCase() ==
              MyStrings.success.toLowerCase()) {
            await loginRepo.apiClient.storeEmail(ph);
            await loginRepo.apiClient.storePasscode(ps);
            checkAndGotoNextStep(loginModel);
          } else {
            CustomSnackBar.error(
                errorList: loginModel.message?.error ??
                    [MyStrings.loginFailedTryAgain]);
          }
        } else {
          CustomSnackBar.error(errorList: [model.message]);
        }
      }
    } on PlatformException catch (e) {
      if (e.code == "PermanentlyLockedOut") {
        // startCountdown();
        isDisable = true;
        isPermantlyLocked = true;
        update();
      } else if (e.code == "LockedOut") {
        isDisable = true;
        update();
        startCountdown();
      }
      update();
    } finally {
      isBioloading = false;
      update();
    }
  }

  int countdownSeconds = 30;
  late Timer countdownTimer;

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 0) {
        countdownSeconds--;
        update();
      } else {
        timer.cancel(); // Stop the timerS when countdown reaches 0
        countdownSeconds = 0;
        isDisable = false;
        update();
      }
    });
  }
  String get token => loginRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

}

