class UrlContainer {
  static const String domainUrl = 'https://onecardpay-emig.campusniger.org';
  static const String baseUrl = '$domainUrl/api/';
  

  static const String registrationEndPoint = 'register';
  static const String loginEndPoint = 'login';
  static const String logoutUrl = 'logout';

  static const String forgetPasswordEndPoint = 'password/mobile';
  static const String passwordVerifyEndPoint = 'password/verify-code';
  static const String resetPasswordEndPoint = 'password/reset';
  static const String verify2FAUrl = 'verify-g2fa';
  static const String otpVerify = 'otp-verify';
  static const String otpResend = 'otp-resend';
  static const String verifyEmailEndPoint = 'verify-email';
  static const String verifySmsEndPoint = 'verify-mobile';
  static const String resendVerifyCodeEndPoint = 'resend-verify/';

  static const String authorizationCodeEndPoint = 'authorization';
  static const String accountDisable = "account/delete";

  static const String dashBoardUrl = 'dashboard';
  static const String transactionEndpoint = 'transactions';
  static const String sendMoneyEndpoint = 'send/money';
  static const String sendMoneyHistoryEndpoint = 'send/money/history';
  static const String cashOutEndpoint = 'cash-out';
  static const String cashOutCancelEndpoint = 'cash-out/cancel';

  static const String mobilerechargeEndpoint = 'mobile/recharge';

  static const String withdrawHistoryUrl = 'withdraw/history';
  static const String withdrawMoneyUrl = 'withdraw/methods';
  static const String submitWithdrawMoneyUrl = 'withdraw/money';
  static const String withdrawPreviewUrl = 'withdraw/preview';
  static const String withdrawMoneySubmitUrl = 'withdraw/money/submit';
  static const String addWithdrawMethodUrl = 'withdraw/add-method';
  static const String withdrawMethodUrl = 'withdraw/methods';
  static const String withdrawMethodEdit = 'withdraw/edit-method';
  static const String withdrawMethodUpdate = 'withdraw/method/update';

  //kyc
  static const String kycFormUrl = 'kyc-form';
  static const String kycSubmitUrl = 'kyc-submit';

  static const String generalSettingEndPoint = 'general-setting';
  static const String moduleSettingEndPoint = 'module-setting';

  //privacy policy
  static const String privacyPolicyEndPoint = 'policies';

  //profile
  static const String getProfileEndPoint = 'user-info';
  static const String updateProfileEndPoint = 'profile-setting';
  static const String profileCompleteEndPoint = 'user-data-submit';

  //change password
  static const String changePasswordEndPoint = 'change-password';
  static const String countryEndPoint = 'get-countries';
  static const String deviceTokenEndPoint = 'add-device-token';
  static const String languageUrl = 'language/';

  // make payment
  static const String makePaymentCheckMerchantUrl = "merchant/exist";
  static const String makePaymentUrl = "make-payment";
  static const String makePaymentVerifyOtpUrl = "make-payment";

  // donation money
  static const String donationEndPoint = "donation";
  static const String donationHistoryEndPoint = "donation/history";

  // bank transfer money
  static const String addBankEndPoint = "add/bank";
  static const String bankTransferEndPoint = "bank/transfer";
  static const String bankDeleteEndPoint = "delete/bank";
  static const String bankTransferHistoryEndPoint =
      "$bankTransferEndPoint/history";

  // paybill
  static const String paybillEndPoint = "pay/bill";
  static const String paybillHistoryEndPoint = "$paybillEndPoint/history";
  static const String paybillDownLoad = "$paybillEndPoint/download";

  // add money
  static const String addMoneyHistoryEndPoint = "deposit/history";
  static const String addMoneyMethodEndPoint = "deposit/methods";
  static const String addMoneyInsertEndPoint = "deposit/insert";

  // money out
  static const String moneyOutUrl = "money-out";
  static const String submitMoneyOutUrl = "money-out";

  // request money
  static const String requestMoneyEndPoint = "request/money";
  static const String requestMoneySubmitEndPoint = "request/money";
  static const String requestToMeEndPoint = "requests";
  static const String myRequestHistoryEndPoint = "my/requested/history";
  static const String requestRejectUrl = "request/reject";
  static const String requestAcceptUrl = "request/accept";

  // voucher
  static const String voucherListEndPoint = "voucher/list";
  static const String createVoucherEndPoint = "voucher/create";
  static const String redeemLogEndPoint = "voucher/redeem/log";
  static const String voucherRedeemEndPoint = "voucher/redeem";

  //Exist check
  static const String checkAgentUrl = "agent/exist";
  static const String checkMerchantUrl = "merchant/exist";
  static const String checkUserUrl = "user/exist";

  static const String qrCodeEndPoint = "qr-code";
  static const String qrScanEndPoint = "qr-code/scan";
  static const String qrCodeImageDownload = "qr-code/download";

  static const String limit = "limit-charge";
  static const String faq = "faq";
  static const String notificationSettingsEndPoint = "notification/settings";

  static const String twoFactor = "twofactor";
  static const String twoFactorEnable = "twofactor/enable";
  static const String twoFactorDisable = "twofactor/disable";
  static const String pinEndPoint = "pin";
  static const String pinValidate = "pin/validate";

  //airtime
  static const String airtimeCountryEndPoint = 'airtime/countries';
  static const String operatorEndPoint = 'airtime/operators-by-country';
  static const String airtimeApplyEndPoint = 'airtime/top-up';
  static const String airtTimeHistory = 'airtime/history';
  static const String countryFlagImageLink =
      'https://flagpedia.net/data/flags/h24/{countryCode}.webp';

//payment link
  static const String paymentLinkHistory = 'payment/link/list';
  static const String paymentLinkPreview = 'payment/link/preview';
  static const String paymentLinkCreate = 'payment/link/create';
  static const String paymentLinkConfirm = 'payment/link/confirm';
//support
  static const String supportMethodsEndPoint = 'support/method';
  static const String supportListEndPoint = 'ticket';
  static const String storeSupportEndPoint = 'ticket/create';
  static const String supportViewEndPoint = 'ticket/view';
  static const String supportReplyEndPoint = 'ticket/reply';
  static const String supportCloseEndPoint = 'ticket/close';
  static const String supportDownloadEndPoint = 'ticket/download';

  static const String supportImagePath = '$domainUrl/assets/support/';
}
