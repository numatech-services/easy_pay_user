// import 'package:get/get.dart';
// import 'package:dio/dio.dart';
// import '../../model/isic/ticket_balance_model.dart';
// import '../auth/login_controller.dart';

// class TicketBalanceController extends GetxController {
//   final isLoading = false.obs;
//   final Rx<TicketBalanceModel?> balance = Rx<TicketBalanceModel?>(null);
//   final RxString rawJson = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchBalances();
//   }

//   Future<void> fetchBalances() async {
//     try {
//       final loginController = Get.find<LoginController>();
//       if (loginController.token == null || loginController.token!.isEmpty) {
//         return;
//       }

//       isLoading.value = true;

//       final dio = Dio(
//         BaseOptions(
//           baseUrl: "https://onecardpay-emig.campusniger.org/api",
//           headers: {
//             "Accept": "application/json",
//             "Authorization": "Bearer ${loginController.token}",
//           },
//         ),
//       );

//       final response = await dio.get('/user/tickets');
//       rawJson.value = response.data.toString();

//       if (response.statusCode == 200 &&
//           response.data['tickets'] is Map<String, dynamic>) {
//         balance.value =
//             TicketBalanceModel.fromJson(response.data['tickets']);
//       } else {
//         balance.value = null;
//       }
//     } catch (e) {
//       rawJson.value = e.toString();
//       balance.value = null;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   ///  MÉTHODE COMPATIBLE AVEC TOUT LE PROJET
//   int getBalance(String type) {
//     if (balance.value == null) return 0;

//     switch (type) {
//       case 'petit_dejeuner':
//         return balance.value!.petitDejeuner;
//       case 'dejeuner':
//         return balance.value!.dejeuner;
//       case 'diner':
//         return balance.value!.diner;
//       case 'transport':
//         return balance.value!.transport;
//       default:
//         return 0;
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../model/isic/ticket_balance_model.dart';
import '../auth/login_controller.dart';

class TicketBalanceController extends GetxController {
  final isLoading = false.obs;
  final balance = Rx<TicketBalance>(TicketBalance.empty());
  final rawJson = ''.obs;

  late final LoginController loginController;

  @override
  void onInit() {
    super.onInit();
    loginController = Get.find<LoginController>();
  }

  /// Chargement du solde depuis l'API
  Future<void> fetchBalances() async {
    final token = loginController.token;

    if (token.isEmpty) {
  return; // silencieux
  
  }

    isLoading.value = true;
    rawJson.value = '';

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://onecardpay-emig.campusniger.org/api',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.get('/user/tickets');

      rawJson.value = response.data.toString();

      balance.value = TicketBalance.fromJson(
        Map<String, dynamic>.from(response.data),
      );

    } on DioException catch (e) {
      if (e.response != null) {
        rawJson.value =
            "API ERROR ${e.response?.statusCode} : ${e.response?.data}";
      } else {
        rawJson.value = "NETWORK ERROR : ${e.message}";
      }
    } catch (e) {
      rawJson.value = "ERROR : $e";
    } finally {
      isLoading.value = false;
    }
    
  }

  /// Lecture du solde par type
  int getBalance(String type) {
    switch (type) {
      case 'petit_dejeuner':
        return balance.value.petitDejeuner;
      case 'dejeuner':
        return balance.value.dejeuner;
      case 'diner':
        return balance.value.diner;
      case 'transport':
        return balance.value.transport;
      default:
        return 0;
    }
  }

  /// Vérification avant réservation
  bool canReserve(String type, int quantity) {
    return getBalance(type) >= quantity;
  }
  
}


extension TicketBalanceExtension on TicketBalance {
  void decrement(String type, int quantity) {
    switch(type) {
      case 'petit_dejeuner':
        petitDejeuner -= quantity;
        break;
      case 'dejeuner':
        dejeuner -= quantity;
        break;
      case 'diner':
        diner -= quantity;
        break;
  
    }
  }
}

