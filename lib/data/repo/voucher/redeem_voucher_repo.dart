
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class RedeemVoucherRepo{

  ApiClient apiClient;
  RedeemVoucherRepo({required this.apiClient});

  Future<ResponseModel> submitRedeemVoucher({required String voucherCode}) async{
    String url = "${UrlContainer.baseUrl}${UrlContainer.voucherRedeemEndPoint}";
    final params = {"code": voucherCode};
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }
}