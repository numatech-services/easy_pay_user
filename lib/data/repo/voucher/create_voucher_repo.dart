import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class CreateVoucherRepo {
  ApiClient apiClient;
  CreateVoucherRepo({required this.apiClient});

  Future<ResponseModel> getCreateVoucherData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.createVoucherEndPoint}";

    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> submitCreateVoucher({
    required String amount,
    required String otpType,
    required String pin,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.createVoucherEndPoint}";

    Map<String, String> params = {
      "amount": amount,
      "otp_type": otpType,
      "pin": pin,
    };

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }
}
