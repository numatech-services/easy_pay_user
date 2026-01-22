import 'package:dio/dio.dart';

class MealApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://onecardpay-emig.campusniger.org/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Accept": "application/json",
      },
    ),
  );

  /// Réserver un repas
  Future<void> reserveMeal({
    required String token,
    required String isic,
    required String mealService,
    required int quantity,
  }) async {
    await _dio.post(
      "/meal/reserve",
      data: {
        "isic_num": isic,
        "meal_service": mealService,
        "quantity": quantity,
      },
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  /// Historique des réservations
  Future<List<dynamic>> getMealHistory(String token) async {
    final response = await _dio.get(
      "/meal/history",
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    return response.data;
  }
}
