import 'package:viserpay/core/utils/method.dart';
import 'package:viserpay/core/utils/url_container.dart';
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/services/api_service.dart';

class UserTicketRepo {
  ApiClient apiClient;
  UserTicketRepo({required this.apiClient});

  Future<ResponseModel> getUserTickets() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.userTicketsEndPoint}";
    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}
