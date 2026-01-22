import 'dart:convert';

import 'package:get/get.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/model/payment_link/payment_link_history_response.dart';
import 'package:viserpay/data/repo/payment_link/payment_link_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class PaymentLinkHistoryController extends GetxController {
  PaymentLinkRepo repo;
  PaymentLinkHistoryController({required this.repo});

  bool isLoading = false;
  String currency = '';
  String currencySym = '';
  String? nextPageUrl;
  List<PaymentLink> paymentListHistory = [];
  int page = 0;

  void initailData() {
    currency = repo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = repo.apiClient.getCurrencyOrUsername(isSymbol: true);
    paymentListHistory = [];
    page = 0;
    nextPageUrl;
    isLoading = true;
    update();
    getPaymentHistory();
  }

  void getPaymentHistory() async {
    page = page + 1;
    if (page == 1) {
      paymentListHistory = [];
      isLoading = true;
      update();
    }
    try {
      ResponseModel responseModel = await repo.getAllInvoiceData(page);
      if (responseModel.statusCode == 200) {
        PaymentLinkHistoryResponseModel model = PaymentLinkHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          nextPageUrl = model.data?.paymentLinks?.nextPageUrl;
          paymentListHistory.addAll(model.data?.paymentLinks?.data ?? []);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }
    isLoading = false;
    update();
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }
}
