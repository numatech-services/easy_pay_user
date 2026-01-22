import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class VoucherListRepo{

  ApiClient apiClient;
  VoucherListRepo({required this.apiClient});

  Future<ResponseModel> getVoucherListData(int page) async{
    String url = "${UrlContainer.baseUrl}${UrlContainer.voucherListEndPoint}?page=$page";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}