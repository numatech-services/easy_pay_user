import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:viserpay/data/controller/auth/login_controller.dart';

class MealReservationHistoryPage extends StatefulWidget {
  const MealReservationHistoryPage({super.key});

  @override
  State<MealReservationHistoryPage> createState() =>
      _MealReservationHistoryPageState();
}

class _MealReservationHistoryPageState
    extends State<MealReservationHistoryPage> {
  bool isLoading = true;
  List reservations = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final loginController = Get.find<LoginController>();

      final dio = Dio(
        BaseOptions(
          baseUrl: "https://onecardpay-emig.campusniger.org/api",
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer ${loginController.token}",
          },
        ),
      );

      final response = await dio.get("/meal/history");

      setState(() {
        reservations = response.data;
        isLoading = false;
      });
    } on DioException catch (e) {
      Get.snackbar(
        "Erreur",
        e.response?.data?.toString() ?? "Erreur lors du chargement",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => isLoading = false);
    }
  }

  String formatMeal(String type) {
    switch (type) {
      case "petit_dejeuner":
        return "Petit déjeuner";
      case "dejeuner":
        return "Déjeuner";
      case "diner":
        return "Dîner";
      default:
        return type;
    }
  }

  Color mealColor(String type) {
    switch (type) {
      case "petit_dejeuner":
        return Colors.orange;
      case "dejeuner":
        return Colors.blue;
      case "diner":
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  bool isPast(String date) {
    return DateTime.parse(date)
        .isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des réservations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Afficher toutes les réservations",
            onPressed: () {
              setState(() {
                isLoading = true; // affiche le loader
              });
              fetchHistory(); // recharge les réservations
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(
                  child: Text("Aucune réservation trouvée"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final r = reservations[index];
                    final date = DateFormat('dd MMM yyyy').format(
                      DateTime.parse(r['meal_date']),
                    );

                    final past = isPast(r['meal_date']);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: mealColor(r['meal_service']),
                          child: Text(
                            r['quantity'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          formatMeal(r['meal_service']),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(date),
                        trailing: Chip(
                          label: Text(
                            past ? "Passé" : "À venir",
                            style: TextStyle(
                              color: past ? Colors.grey : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor:
                              past ? Colors.grey.shade200 : Colors.green.shade50,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

}
