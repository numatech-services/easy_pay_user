import 'dart:developer';

import 'package:viserpay/core/utils/method.dart';
import 'package:viserpay/core/utils/url_container.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/services/api_service.dart';

class SendMoneyRepo {
  ApiClient apiClient;
  SendMoneyRepo({required this.apiClient});

  Future<ResponseModel> sendMoneygetData() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.sendMoneyEndpoint}';
    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> checkUser({required String usernameOrmobile, required String type}) async {
    log(usernameOrmobile);
    String url = '${UrlContainer.baseUrl}${UrlContainer.checkUserUrl}';
    Map<String, String> params = {'user': usernameOrmobile, 'type_payment': type};
    final responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> sendMoney({
    required String amount,
    required String usernameOrmobile,
    required bool statusFeeIncluded,
    required String otpType,
    required String type,
    required String pin,
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.sendMoneyEndpoint}';
    log(usernameOrmobile);
    Map<String, String> params = {
      'user': usernameOrmobile,
      'amount': amount,
      'statusFeeIncluded': statusFeeIncluded ? "1" : "0",
      'otp_type': otpType,
      "type_payment":type,
      'pin': pin,
    };
    log(params.toString());
    final responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> history({required String page}) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.sendMoneyHistoryEndpoint}?page=$page';

    final responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}
