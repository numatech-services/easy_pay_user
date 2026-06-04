import 'dart:convert';
import 'package:get/get.dart';

import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/voucher/redeem_log_response_model.dart';
import '../../repo/voucher/redeem_log_repo.dart';

class RedeemLogController extends GetxController {
  RedeemLogRepo redeemLogRepo;
  RedeemLogController({required this.redeemLogRepo});

  bool isLoading = true;

  String? nextPageUrl;
  int page = 0;
  String currency = '';
  String currencySym = '';

  RedeemLogResponseModel model = RedeemLogResponseModel();
  List<Data> redeemLogList = [];

  void initialData() async {
    page = 0;
    redeemLogList.clear();
    currency = redeemLogRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = redeemLogRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    isLoading = true;
    update();

    await loadData();
    isLoading = false;
    update();
  }

  Future<void> loadData() async {
    page = page + 1;
    if (page == 1) {
      redeemLogList.clear();
    }

    ResponseModel responseModel = await redeemLogRepo.getRedeemLogData(page);
    if (responseModel.statusCode == 200) {
      model = RedeemLogResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        List<Data>? tempRedeemLogList = model.data?.logs?.data;
        if (tempRedeemLogList != null && tempRedeemLogList.isNotEmpty) {
          redeemLogList.addAll(tempRedeemLogList);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }
}
