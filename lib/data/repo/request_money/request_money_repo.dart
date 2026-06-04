import 'package:viserpay/core/utils/method.dart';
import 'package:viserpay/core/utils/url_container.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/services/api_service.dart';

class RequestMoneyRepo {
  ApiClient apiClient;
  RequestMoneyRepo({required this.apiClient});

  Future<ResponseModel> requestMoneygetData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.requestMoneyEndPoint}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getMyRequestHistory(String page) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.myRequestHistoryEndPoint}?page=$page";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> getRequestToMeHistory(String page) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.requestToMeEndPoint}?page=$page";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> acceptRequest({
    required String id,
    required String otpType,
    required String pin,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.requestAcceptUrl}";
    Map<String, String> params = {
      "request_id": id,
      "otp_type": otpType,
      "pin": pin,
    };

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> rejectRequest({
    required String id,
    required String otpType,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.requestRejectUrl}";
    Map<String, String> params = {
      "request_id": id,
      "otp_type": otpType,
    };

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> submitRequestMoney({
    required String amount,
    required String username,
    required String msg,
    required String pin,
     required String typeTicket,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.requestMoneySubmitEndPoint}";
    Map<String, String> params = {
      "amount": amount,
      "user": username.replaceAll('+', '').trim(),
      "note": msg,
      'pin': pin,
      'ticketType': typeTicket,
    };

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> checkUser({required String user}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.checkUserUrl}";
    Map<String, String> params = {"user": user.replaceAll('+', '').trim()};
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }
}
