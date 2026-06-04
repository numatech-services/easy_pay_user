import 'dart:convert';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/data/model/user_tickets/user_tickets_log_model.dart'
    as com;
import 'package:viserpay/data/model/global/response_model/response_model.dart';
import 'package:viserpay/data/repo/user_ticket/user_ticket.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/view/components/snack_bar/show_custom_snackbar.dart';

class UserTicketController extends GetxController {
  UserTicketRepo userTicketRepo;
  UserTicketController({required this.userTicketRepo});

  bool isLoading = true;
  List<com.Data> ticketsList = [];

  // ❌ Supprimez onInit

  Future<void> loadData() async {
    isLoading = true;
    ticketsList.clear();
    update();

    ResponseModel responseModel = await userTicketRepo.getUserTickets();
    print("STATUS: ${responseModel.statusCode}");
    print("RAW JSON: ${responseModel.responseJson}");

    if (responseModel.statusCode == 200) {
      final jsonData = jsonDecode(responseModel.responseJson);
      final model = com.UserTicketsLogResponseModel.fromJson(jsonData);
      print("model logs: ${model.data?.logs?.data?.length}");

      if (model.status?.toLowerCase() == "success") {
        List<com.Data>? tempList = model.data?.logs?.data;
        if (tempList != null && tempList.isNotEmpty) {
          ticketsList.addAll(tempList);
          print("✅ Tickets chargés: ${ticketsList.length}");
        }
      } else {
        CustomSnackBar.error(
          errorList: model.message?.error ?? [MyStrings.somethingWentWrong],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    isLoading = false;
    update();
  }
}
