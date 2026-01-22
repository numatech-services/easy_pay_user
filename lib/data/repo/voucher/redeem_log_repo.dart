
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class RedeemLogRepo{

  ApiClient apiClient;
  RedeemLogRepo({required this.apiClient});

  Future<ResponseModel> getRedeemLogData(int page) async{
    String url = "${UrlContainer.baseUrl}${UrlContainer.redeemLogEndPoint}?page=$page";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}