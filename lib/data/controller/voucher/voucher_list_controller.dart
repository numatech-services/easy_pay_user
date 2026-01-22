import 'dart:convert';
import 'package:get/get.dart';

import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/voucher/voucher_list_response_model.dart';
import '../../repo/voucher/voucher_list_repo.dart';

class VoucherListController extends GetxController {
  VoucherListRepo voucherListRepo;
  VoucherListController({required this.voucherListRepo});

  bool isLoading = true;
  VoucherListResponseModel model = VoucherListResponseModel();

  List<Data> voucherList = [];
  String? nextPageUrl;
  int page = 0;
  String currency = "";
  String currencySym = "";

  void initialState() async {
    page = 0;
    currency = voucherListRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym = voucherListRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    voucherList.clear();
    isLoading = true;
    update();

    await loadData();
    isLoading = false;
    update();
  }

  Future<void> loadData() async {
    page = page + 1;

    if (page == 1) {
      voucherList.clear();
    }

    ResponseModel responseModel = await voucherListRepo.getVoucherListData(page);

    if (responseModel.statusCode == 200) {
      if (200 == 200) {
        model = VoucherListResponseModel.fromJson(jsonDecode(responseModel.responseJson));

        if (model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          nextPageUrl = model.data?.vouchers?.nextPageUrl;
          List<Data>? tempVoucherList = model.data?.vouchers?.data;
          if (tempVoucherList != null && tempVoucherList.isNotEmpty) {
            voucherList.addAll(tempVoucherList);
          }
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  int selectedIndex = -1;
  changeSelectedIndex(int selectedIndex) {
    if (selectedIndex == selectedIndex) {
      selectedIndex = -1;
    } else {
      selectedIndex = selectedIndex;
    }
    update();
  }
}
