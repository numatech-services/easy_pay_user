import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/helper/shared_preference_helper.dart';
import 'package:viserpay/core/route/route.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_icon.dart';
import 'package:viserpay/core/utils/my_images.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/dashboard/dashboard_response_model.dart';
import 'package:viserpay/data/model/general_setting/general_setting_response_model.dart';
import 'package:viserpay/data/model/general_setting/module_settings_response_model.dart'
    as module;
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/repo/home/home_repo.dart';
import 'package:viserpay/view/components/buttons/circle_animated_button_with_text.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:viserpay/view/screens/bottom_nav_section/home/widget/meal_reservation_history_page.dart';
import '../../../view/components/bottom-sheet/custom_bottom_sheet.dart';
import '../../../view/components/image/custom_svg_picture.dart';
import '../../../view/screens/voucher/redeem_voucher/redeem_voucher.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viserpay/view/screens/bottom_nav_section/home/widget/meal_reservation_bottom_sheet.dart';


class HomeController extends GetxController {
  HomeRepo homeRepo;

  HomeController({required this.homeRepo});

  bool isLoading = false;

  String fullName = "";
  String username = "";
  String isicNum = "";
  String userBalance = "";
  String email = "";
  String mobileNo = "";
  String userimage = '';
  String totalMoneyIn = "";
  String totalMoneyOut = "";
  String defaultCurrency = "";
  String defaultCurrencySymbol = "tk";
  String kycRejectReson = "";

  GeneralSettingResponseModel generalSettingResponseModel =
      GeneralSettingResponseModel();

  Future<void> initialData({bool fromRefresh = false}) async {
    isLoading = true;
    update();
    await homeRepo.refreshModuleSetting();
    moduleList = [];
    await loadData();
    moduleList = getModuleList();
    printx('moduleList ${moduleList.length}');
    isLoading = false;
    update();
  }

  List<Widget> moduleList = [];
  List<AppBanner> appBanners = [];
  List<Merchant> merchants = [];
  List<LatestTransaction> latestTransactions = [];

  bool isKycVerified = true;
  bool isKycPending = false;
  bool isKycRejected = false;
  Future<void> loadData() async {
    isLoading = true;
    defaultCurrency = homeRepo.apiClient.getCurrencyOrUsername();
    generalSettingResponseModel = homeRepo.apiClient.getGSData();
    update();

    ResponseModel responseModel = await homeRepo.getData();

    if (responseModel.statusCode == 200) {
      DashboardResponseModel model = DashboardResponseModel.fromJson(
          jsonDecode(responseModel.responseJson));
      if (model.status.toString().toLowerCase() ==
          MyStrings.success.toLowerCase()) {
        printx('model.data?.user?.kv ${model.data?.user?.kycRejectionReason}');
        printx('model.data?.user?.kv ${model.data?.user?.kv}');
        printx('model.data?.user?.kv ${model.data?.user?.kycRejectionReason}');

        fullName =
            "${model.data?.user?.firstname ?? ""} ${model.data?.user?.lastname ?? ""}";
        username = model.data?.user?.username ?? "";
        isicNum = model.data?.user?.isicNum ?? "";
        userBalance = model.data?.user?.balance ?? "0.0";
        email = model.data?.user?.email ?? "";
        mobileNo = "${model.data?.user?.dialCode}${model.data?.user?.mobile}";
        isKycVerified = model.data?.user?.kv == '1';
        isKycPending = model.data?.user?.kv == '2';
        isKycRejected = model.data?.user?.kv == '0' &&
            (model.data?.user?.kycRejectionReason).toString() != 'null';
        userimage = model.data?.user?.image == null
            ? 'null'
            : model.data?.user?.getImage ?? '';
        kycRejectReson = model.data?.user?.kycRejectionReason ?? '';
        update();
        homeRepo.apiClient.storebalance(userBalance);
        latestTransactions.clear();
        List<LatestTransaction>? tempTrxList = model.data?.latestTransactions;
        if (tempTrxList != null && tempTrxList.isNotEmpty) {
          latestTransactions.addAll(tempTrxList);
        }

        appBanners.clear();
        List<AppBanner>? tempbannerList = model.data?.appBanners;
        if (tempbannerList != null && tempbannerList.isNotEmpty) {
          appBanners.addAll(tempbannerList);
        }

        merchants.clear();
        List<Merchant>? tempMarchantList = model.data?.merchants;
        if (tempMarchantList != null && tempMarchantList.isNotEmpty) {
          merchants.addAll(tempMarchantList);
        }

        update();
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  bool isVisibleItem = false;
  void visibleItem() {
    isVisibleItem = !isVisibleItem;
    update();
  }

  void gotoNextRoute(String routeName) async {
    await Get.toNamed(routeName)?.then((value) {
      loadData();
    });
  }

  Future<void> refreshModule() async {
    try {
      ResponseModel responseModel = await homeRepo.refreshModuleSetting();
      if (responseModel.statusCode == 200) {
        module.ModuleSettingsResponseModel model =
            module.ModuleSettingsResponseModel.fromJson(
                jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? []);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    }
  }

  List<Widget> getModuleList() {
    List<Widget> temModuleList = [];

    String pre = homeRepo.apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.moduleSettingKey) ??
        '';
    // ResponseModel responseModel =  homeRepo.refreshModuleSetting();
    module.ModuleSettingsResponseModel model =
        module.ModuleSettingsResponseModel.fromJson(jsonDecode(pre));
    List<module.UserModule>? userModule = model.data?.moduleSetting?.user;

    var sendMoneyModule =
        userModule?.where((element) => element.slug == 'send_money').first;
    bool isSendMoneyEnable =
        sendMoneyModule != null && sendMoneyModule.status == '0' ? false : true;

    var mobileRechargeModule =
        userModule?.where((element) => element.slug == 'mobile_recharge').first;
    bool isMobileRechargeEnable =
        mobileRechargeModule != null && mobileRechargeModule.status == '0'
            ? false
            : true;

    var cashOutExchangeModule =
        userModule?.where((element) => element.slug == 'cash_out').first;
    bool isCashOutEnable =
        cashOutExchangeModule != null && cashOutExchangeModule.status == '0'
            ? false
            : true;

    var makePaymentModule =
        userModule?.where((element) => element.slug == 'make_payment').first;
    bool isMakePaymentEnable =
        makePaymentModule != null && makePaymentModule.status == '0'
            ? false
            : true;

    var bankTransferModule =
        userModule?.where((element) => element.slug == 'bank_transfer').first;
    bool isBankTransferEnable =
        bankTransferModule != null && bankTransferModule.status == '0'
            ? false
            : false;

    var paybillModule =
        userModule?.where((element) => element.slug == 'utility_bill').first;
    bool isPaybillEnable =
        paybillModule != null && paybillModule.status == '0' ? false : false;

    var donationModule =
        userModule?.where((element) => element.slug == 'donation').first;
    bool isDonationEnable =
        donationModule != null && donationModule.status == '0' ? false : false;

    var addMoneyModule =
        userModule?.where((element) => element.slug == 'add_money').first;
    bool isAddMoneyEnable =
        addMoneyModule != null && addMoneyModule.status == '0' ? false : false;

    var createVoucherModule =
        userModule?.where((element) => element.slug == 'create_voucher').first;
    bool isCreateVoucherEnable =
        createVoucherModule != null && createVoucherModule.status == '0'
            ? true
            : true;

    var requestModule =
        userModule?.where((element) => element.slug == 'request_money').first;
    bool isRequestModuleEnable =
        requestModule != null && requestModule.status == '0' ? false : true;

    var airTimeModule =
        userModule?.where((element) => element.slug == 'air_time').first;
    bool isAirTimeModuleEnable =
        airTimeModule != null && airTimeModule.status == '0' ? false : false;

    if (isSendMoneyEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          buttonName: MyStrings.sendMoney,
          backgroundColor: MyColor.sendMoneyBaseColor.withOpacity(0.1),
          onTap: () => gotoNextRoute(
            RouteHelper.sendMoneyScreen,
          ),
          height: 56,
          width: 56,
          child: const CustomSvgPicture(
              image: MyIcon.sendMoney,
              color: MyColor.sendMoneyBaseColor,
              height: 24,
              width: 24),
        ),
      );
    }
    if (isMobileRechargeEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: "Historique des envois",
          backgroundColor: MyColor.rechargeBaseColor.withOpacity(0.1),
          child: const CustomSvgPicture(
              image: MyIcon.history,
              color: MyColor.rechargeBaseColor,
              height: 24,
              width: 24),
          onTap: () => gotoNextRoute(
            RouteHelper.sendMoneyHistoryScreen,
          ),
        ),
      );
    }

    if (isCashOutEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: MyStrings.receiveMoney,
          backgroundColor: MyColor.addMoneyBaseColor.withOpacity(0.1),
          child: const CustomSvgPicture(
              image: MyIcon.addMoney,
              color: MyColor.addMoneyBaseColor,
              height: 24,
              width: 24),
          onTap: () => gotoNextRoute(
            RouteHelper.myQrCodeScreen,
          ),
        ),
      );
    }

    if (isCashOutEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: "Historique des receptions",
          backgroundColor: MyColor.bankTransferBaseColor.withOpacity(0.1),
          child: const CustomSvgPicture(
              image: MyIcon.history,
              color: MyColor.bankTransferBaseColor,
              height: 24,
              width: 24),
          onTap: () => gotoNextRoute(
            RouteHelper.receiveMoneyHistoryScreen,
          ),
        ),
      );
    }

    if (isMakePaymentEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: MyStrings.payment_,
          backgroundColor: MyColor.paymentBaseColor.withOpacity(0.1),
          child: const CustomSvgPicture(
              image: MyIcon.cart,
              color: MyColor.paymentBaseColor,
              height: 24,
              width: 24),
          onTap: () => gotoNextRoute(
            RouteHelper.makePaymentScreen,
          ),
        ),
      );
    }

    if (isBankTransferEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: MyStrings.bankTransfer,
          backgroundColor: MyColor.bankTransferBaseColor.withOpacity(0.1),
          child: const CustomSvgPicture(
              image: MyIcon.bank,
              color: MyColor.bankTransferBaseColor,
              height: 24,
              width: 24),
          onTap: () => gotoNextRoute(
            RouteHelper.bankTransferScreen,
          ),
        ),
      );
    }

    if (isPaybillEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: MyStrings.payBill,
          backgroundColor: MyColor.paybillBaseColor.withOpacity(0.2),
          child: const CustomSvgPicture(
              image: MyIcon.paybill,
              color: MyColor.paybillBaseColor,
              height: 32,
              width: 32),
          onTap: () => gotoNextRoute(
            RouteHelper.paybillHomeScreen,
          ),
        ),
      );
    }

    if (isDonationEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          height: 56,
          width: 56,
          buttonName: MyStrings.donation,
          backgroundColor: MyColor.donationBaseColor.withOpacity(0.1),
          child: const CustomSvgPicture(
              image: MyIcon.donation,
              color: MyColor.donationBaseColor,
              height: 26,
              width: 26),
          onTap: () => gotoNextRoute(
            RouteHelper.donaTionHomeScreen,
          ),
        ),
      );
    }

    if (isAddMoneyEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          buttonName: MyStrings.addMoney,
          backgroundColor: MyColor.addMoneyBaseColor.withOpacity(0.1),
          onTap: () => gotoNextRoute(RouteHelper.addMoneyScreen),
          height: 56,
          width: 56,
          child: const CustomSvgPicture(
              image: MyIcon.addMoney,
              color: MyColor.addMoneyBaseColor,
              height: 24,
              width: 24),
        ),
      );
    }
    if (isAirTimeModuleEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          buttonName: MyStrings.airTime,
          backgroundColor: Colors.lightBlue.withOpacity(0.1),
          onTap: () {
            Get.back();
            gotoNextRoute(RouteHelper.airtimeScreen);
          },
          height: 56,
          width: 56,
          child: Image.asset(MyImages.airTimeImage,
              color: Colors.lightBlue, height: 24, width: 24),
        ),
      );
    }
    if (isRequestModuleEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
          buttonName: MyStrings.requestMoney,
          backgroundColor: Colors.teal.withOpacity(0.1),
          onTap: () => gotoNextRoute(RouteHelper.moneyRequestScreen),
          height: 56,
          width: 56,
          child: Image.asset(MyImages.reqMoneyImage,
              color: Colors.teal, height: 24, width: 24),
        ),
      );
    }

    //     if (isCashOutEnable) {
    //   temModuleList.add(
    //     CircleAnimatedButtonWithText(
    //       height: 56,
    //       width: 56,
    //       buttonName: "Rétrait d'argent",
    //       backgroundColor: MyColor.cashoutBaseColor.withOpacity(0.1),
    //       child: const CustomSvgPicture(image: MyIcon.cashout, color: MyColor.cashoutBaseColor, height: 24, width: 24),
    //       onTap: () => gotoNextRoute(
    //         RouteHelper.cashOutScreen,
    //       ),
    //     ),
    //   );
    // }
    //  if (isRequestModuleEnable) {
    //   temModuleList.add(
    //     CircleAnimatedButtonWithText(
    //       buttonName: "Historique demande d'argent",
    //       backgroundColor: Colors.pink.withOpacity(0.1),
    //       onTap: ()   {
    //         Get.toNamed(RouteHelper.moneyRequestHistoryScreen);
    //       },

    //       height: 56,
    //       width: 56,
    //       child: const CustomSvgPicture(image: MyIcon.history, color: Colors.pink, height: 24, width: 24),
    //     ),
    //   );
    // }
    if (isCreateVoucherEnable) {
      temModuleList.add(
        CircleAnimatedButtonWithText(
            buttonName: " Offre Zamani",
            backgroundColor: Colors.pink.withOpacity(0.1),
            onTap: () {
              MyUtils().showSchoolOfferBottomSheet(Get.context!);
              // Get.toNamed(RouteHelper.voucherScreen);
              // CustomBottomSheet(child: const RedeemVoucher()).customBottomSheet(Get.context!);
            },
            height: 56,
            width: 56,
            // child: Image.asset(MyImages.voucherImage,
            //  color: Colors.pink, height: 24, width: 24),
            child: ClipOval(
              child: Image.asset(MyImages.voucherImage,
                  color: Colors.pink, height: 24, width: 24),
            )),
      );
    }
    // Afficher la carte ISIC
    temModuleList.add(
      CircleAnimatedButtonWithText(
        buttonName: "Ma carte ISIC",
        backgroundColor: Colors.green.withOpacity(0.1),
        onTap: () => gotoNextRoute(RouteHelper.isicCardScreen),
        height: 56,
        width: 56,
        child: const Icon(Icons.credit_card, color: Colors.green, size: 24),
      ),
    );

    // Vérification / Activation de carte
    temModuleList.add(
      CircleAnimatedButtonWithText(
        buttonName: "Activer ISIC",
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        onTap: () => gotoNextRoute(RouteHelper.isicActivationScreen),
        height: 56,
        width: 56,
        child:
            const Icon(Icons.verified_user, color: Colors.blueAccent, size: 24),
      ),
    );

    // Upload photo ISIC
    temModuleList.add(
      CircleAnimatedButtonWithText(
        buttonName: "Photo ISIC",
        backgroundColor: Colors.orange.withOpacity(0.1),
        onTap: () => gotoNextRoute(RouteHelper.isicPhotoScreen),
        height: 56,
        width: 56,
        child: const Icon(Icons.camera_alt, color: Colors.orange, size: 24),
      ),
    );

    // Historique des cartes ISIC
    temModuleList.add(
      CircleAnimatedButtonWithText(
        buttonName: "Historique ISIC",
        backgroundColor: Colors.purple.withOpacity(0.1),
        onTap: () => gotoNextRoute(RouteHelper.isicHistoryScreen),
        height: 56,
        width: 56,
        child: const Icon(Icons.history, color: Colors.purple, size: 24),
      ),
    );

    temModuleList.add(
      CircleAnimatedButtonWithText(
          buttonName: "Cash Back",
          backgroundColor: Colors.purple.withOpacity(0.1),
          onTap: () => gotoNextRoute(RouteHelper.isicHistoryScreen),
          height: 56,
          width: 56,
          // child: const Icon(Icons.monetization_on_outlined, color: Colors.blueGrey, size: 24),
          child: const CustomSvgPicture(
            image: MyIcon.cashback,
            color: Colors.blueGrey,
            height: 24,
            width: 24,
          )),
    );

    // if (isCreateVoucherEnable) {
    //   temModuleList.add(
    //     CircleAnimatedButtonWithText(
    //       buttonName: MyStrings.redeemVoucher,
    //       backgroundColor: Colors.orange.withOpacity(0.1),
    //       onTap: () {
    //         Get.back();
    //         CustomBottomSheet(child: const RedeemVoucher()).customBottomSheet(Get.context!);
    //       },
    //       height: 56,
    //       width: 56,
    //       child: Image.asset(MyImages.voucherRedomImage, color: Colors.orange, height: 24, width: 24),
    //     ),
    //   );
    // }

  temModuleList.add(
  CircleAnimatedButtonWithText(
    buttonName: "Réserver un repas",
    backgroundColor: Colors.orange.withOpacity(0.1),
    onTap: () {
      Get.bottomSheet(
        MealReservationBottomSheet(),
        isScrollControlled: true,
      );
    },
    height: 56,
    width: 56,
    child: const Icon(
      Icons.restaurant,
      color: Colors.orange,
      size: 24,
    ),
  ),
);

temModuleList.add(
  CircleAnimatedButtonWithText(
    buttonName: "Historique repas",
    backgroundColor: Colors.green.withOpacity(0.1),
    onTap: () {
      // Ouvre la page historique des réservations
      Get.to(() => const MealReservationHistoryPage());
    },
    height: 56,
    width: 56,
    child: const Icon(
      Icons.history_toggle_off, // ou Icons.history pour l’icône
      color: Colors.green,
      size: 24,
    ),
  ),
);


    return temModuleList;
  }

  //Balance animation
  RxBool isAnimation = false.obs;
  RxBool isBalanceShown = false.obs;
  RxBool isBalance = true.obs;
  RxBool isClickable = true.obs; // Add this boolean flag

  void changeState() async {
    if (!isClickable.value) {
      return;
    }

    isClickable.value =
        false; // Disable clicking during animation and showing balance
    isAnimation.value = true;
    isBalance.value = false;

    // First animation: Show balance text
    await Future.delayed(const Duration(milliseconds: 500));
    isBalanceShown.value = true;

    // Third animation: Hide the circle
    await Future.delayed(const Duration(seconds: 3));
    isAnimation.value = false;
    isBalanceShown.value = false;
    // Fourth animation: Show balance text again
    await Future.delayed(const Duration(milliseconds: 500));
    isBalance.value = true;

    isClickable.value = true; // Re-enable clicking after the animation
  }

  bool showMoreWidget = false;
  changeShowMoreWidgetState() async {
    showMoreWidget = !showMoreWidget;
    update();
  }
}
