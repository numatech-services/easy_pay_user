import 'dart:convert';

import 'package:get/get.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/model/airtime/airtime_history_response_model.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/repo/airtime/airtime_repo.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class AirtimeHistoryController extends GetxController {
  AirtimeRepo airtimeRepo;
  AirtimeHistoryController({required this.airtimeRepo});

  bool isLoading = false;
  String currency = '';
  String currencySym = '';

  void initialValue() {
    currency = airtimeRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = airtimeRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    isLoading = true;
    page = 0;
    airtTimeHistoryList = [];
    update();
    getAirTimeHistory();
  }

  int page = 0;
  String? nextPageUrl;

  List<AirtimeHistory> airtTimeHistoryList = [];
  Future<void> getAirTimeHistory() async {
    page = page + 1;
    if (page == 1) {
      airtTimeHistoryList.clear();
      isLoading = true;
      update();
    }
    try {
      ResponseModel responseModel = await airtimeRepo.getAirtimeHistory(page.toString());
      if (responseModel.statusCode == 200) {
        AirtimeHistoryResponseModel model = AirtimeHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          nextPageUrl = model.data?.transactions?.nextPageUrl;
          airtTimeHistoryList.addAll(model.data?.transactions?.data ?? []);
          update();
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? []);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      print('come only finaly---------');
    }

    print('come here---------');
    isLoading = false;
    update();
  }

  clearPageData() {
    page = 0;
    nextPageUrl = null;
    update();
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }
}
