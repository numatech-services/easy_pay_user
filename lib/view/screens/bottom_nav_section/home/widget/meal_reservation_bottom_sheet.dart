import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:viserpay/core/helper/shared_preference_helper.dart';
import 'package:viserpay/data/controller/auth/login_controller.dart';
import 'package:viserpay/view/screens/bottom_nav_section/home/widget/meal_reservation_history_page.dart';
import 'package:viserpay/data/controller/isic/ticket_balance_controller.dart';

class MealReservationBottomSheet extends StatefulWidget {
  const MealReservationBottomSheet({super.key});

  @override
  State<MealReservationBottomSheet> createState() =>
      _MealReservationBottomSheetState();
}

class _MealReservationBottomSheetState
    extends State<MealReservationBottomSheet> {

  final TextEditingController isicController = TextEditingController();

  late final LoginController loginController;
  final TicketBalanceController ticketCtrl =
      Get.find<TicketBalanceController>();

  bool isLoading = false;
  bool reserveForMe = true;

  DateTime focusedDay = DateTime.now().add(const Duration(days: 1));
  Set<DateTime> selectedDays = {};

  String selectedType = "Petit déjeuner";

  final List<String> ticketTypes = [
    "Petit déjeuner",
    "Déjeuner",
    "Dîner",
  ];

  String mapMealType(String label) {
    switch (label) {
      case "Petit déjeuner":
        return "petit_dejeuner";
      case "Déjeuner":
        return "dejeuner";
      case "Dîner":
        return "diner";
      default:
        return "dejeuner";
    }
  }

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Vérifie si une date est déjà réservée pour ce type
 Future<bool> isDateBlocked(DateTime date) async {

  final isic = isicController.text.trim();

  if (isic.isEmpty) {
    return false; // on bloque pas tant que l’ISIC n’est pas connu
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: "https://onecardpay-emig.campusniger.org/api",
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${loginController.token}",
      },
    ),
  );

  try {
    final response = await dio.post(
      "/meal/check",
      data: {
        "meal_service": mapMealType(selectedType),
        "meal_date": date.toIso8601String().substring(0, 10),
        "isic_num": isic,
      },
    );

    return response.data['reserved'] == true;
  } catch (_) {
    return false;
  }
}


  Future<void> toggleDay(DateTime day) async {
     // 🔒 ISIC obligatoire si réservation pour un autre
  if (!reserveForMe && isicController.text.trim().isEmpty) {
    Get.snackbar(
      "ISIC requis",
      "Veuillez saisir le numéro ISIC avant de sélectionner une date",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }
    final normalizedDay = normalize(day);

    if (normalizedDay
        .isBefore(normalize(DateTime.now().add(const Duration(days: 1))))) {
      Get.snackbar(
        "Erreur",
        "La réservation doit être faite au moins 24h à l'avance",
      );
      return;
    }

    final blocked = await isDateBlocked(normalizedDay);

    if (blocked) {
      Get.snackbar(
        "Déjà réservé",
        "Ce repas est déjà réservé pour cette date",
      );
      return;
    }

    setState(() {
      if (selectedDays.contains(normalizedDay)) {
        selectedDays.remove(normalizedDay);
      } else {
        selectedDays.add(normalizedDay);
      }
    });
  }

  // bool reserveForMe = true;

@override
void initState() {
  super.initState();

  loginController = Get.find<LoginController>();

  isicController.text =
      loginController.loginRepo.apiClient.sharedPreferences
              .getString(SharedPreferenceHelper.isic_num) ??
          '';
}
                               
 Future<bool> verifyIsic(String isic) async {
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://onecardpay-emig.campusniger.org/api",
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${loginController.token}",
        },
      ),
    );

    final response = await dio.post(
      "/students/check-isic",
      data: {"isic_num": isic},
    );

    return response.data['exists'] == true;
  } catch (_) {
    return false;
  }
}

  Future<bool> reserveMeals() async {
   final isic = isicController.text.trim();

final loginController = Get.find<LoginController>();
final myIsic = loginController.loginRepo.apiClient.sharedPreferences
    .getString(SharedPreferenceHelper.isic_num) ?? '';

if (isic.isEmpty || selectedDays.isEmpty) {
  Get.snackbar(
    "Erreur",
    "Veuillez saisir l’ISIC et sélectionner au moins une date",
    backgroundColor: Colors.red,
    colorText: Colors.white,
  );
  return false;
}

if (!hasEnoughTickets()) {
  Get.snackbar("Solde insuffisant", "Tickets insuffisants");
  return false;
}
    setState(() => isLoading = true);

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

      final response = await dio.post(
        "/meal/reserve-multiple",
        data: {
          "isic_num": isic,
          "meal_service": mapMealType(selectedType),
          "dates": selectedDays
              .map((d) => d.toIso8601String().substring(0, 10))
              .toList(),
        },
      );

      if (response.data['status'] == 'success') {
        Get.snackbar(
          "Succès",
          response.data['message'] ??
              "Réservations enregistrées (${selectedDays.length})",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(seconds: 2));
        Get.back();

        return true; //  SUCCÈS CONFIRMÉ
      } else {
        Get.snackbar(
          "Erreur",
          response.data['message'] ?? "Erreur inconnue",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }
    } on DioException catch (e) {
      Get.snackbar(
        "Erreur",
        e.response?.data['message'] ?? "Erreur API",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool hasEnoughTickets() {
    final type = mapMealType(selectedType);
    final balance = ticketCtrl.getBalance(type);
    return balance >= selectedDays.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Réserver un repas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // TextField(
            //   controller: isicController,
            //   decoration: const InputDecoration(labelText: "Numéro ISIC"),
            // ),
           
Column(
  children: [
    CheckboxListTile(
      value: reserveForMe,
      onChanged: (val) {
        setState(() {
          reserveForMe = val!;
          if (reserveForMe) {
            isicController.text =
                loginController.loginRepo.apiClient.sharedPreferences
                    .getString(SharedPreferenceHelper.isic_num) ?? '';
          } else {
            isicController.clear();
          }
        });
      },
      title: const Text("Réserver pour moi-même"),
      controlAffinity: ListTileControlAffinity.leading,
    ),
    TextField(
      controller: isicController,
      enabled: !reserveForMe,
      decoration: const InputDecoration(
        labelText: "Numéro ISIC",
        hintText: "Ex : ISIC-2024-000123",
      ),
    ),
  ],
),

            

            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: selectedType,
              items: ticketTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedType = val!;
                  selectedDays.clear();
                });
              },
              decoration: const InputDecoration(labelText: "Type de repas"),
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.now().add(const Duration(days: 1)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) =>
                  selectedDays.contains(normalize(day)),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => this.focusedDay = focusedDay);
                toggleDay(selectedDay);
              },
              calendarStyle: CalendarStyle(
                selectedDecoration:
                    BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                    color: Colors.blue.shade200, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Dates sélectionnées : ${selectedDays.length}",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),

            Obx(() {
              final type = mapMealType(selectedType);
              final balance = ticketCtrl.getBalance(type);
              final quantity = selectedDays.length;

              final enoughTickets = balance >= quantity;
              final hasSelectedDays = quantity > 0;
              final canReserve = enoughTickets && hasSelectedDays;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || !canReserve
                      ? null
                      : () async {
                          final success = await reserveMeals(); //  IMPORTANT

                          if (success) {
                            ticketCtrl.balance.value!.decrement(
                                type, quantity); //  seulement après succès
                            selectedDays.clear();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canReserve ? Colors.green : Colors.grey,
                  ),
                  child: Text(
                    !hasSelectedDays
                        ? "Sélectionnez au moins une date"
                        : (enoughTickets
                            ? "Confirmer la réservation"
                            : "Solde insuffisant ($balance)"),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}