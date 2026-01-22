import 'package:viserpay/core/utils/method.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/services/api_service.dart';

import '../../../core/utils/url_container.dart';

class AirtimeRepo {
  ApiClient apiClient;

  AirtimeRepo({required this.apiClient});

  Future<ResponseModel> getAirtimeHistory(String page) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.airtTimeHistory}?page=$page';
    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getAirtimeCountry() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.airtimeCountryEndPoint}';
    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getOperator({required String countryId}) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.operatorEndPoint}/$countryId';
    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<dynamic> getCountryList() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.countryEndPoint}';
    ResponseModel model = await apiClient.request(url, Method.getMethod, null);
    return model;
  }

  Future<ResponseModel> airtimeApply(Map<String, String> map) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.airtimeApplyEndPoint}";

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return responseModel;
  }
}
