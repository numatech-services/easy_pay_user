// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:viserpay/core/helper/date_converter.dart';
// import 'package:viserpay/core/utils/dimensions.dart';
// import 'package:viserpay/core/utils/my_color.dart';
// import 'package:viserpay/core/utils/my_strings.dart';
// import 'package:viserpay/core/utils/style.dart';
// import 'package:viserpay/core/utils/user_inactivity.dart';
// import 'package:viserpay/data/services/api_service.dart';
// import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
// import 'package:viserpay/view/components/column_widget/card_column.dart';
// import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
// import 'package:viserpay/view/components/divider/custom_divider.dart';
// import 'package:viserpay/view/components/no_data.dart';


// class TikestScreen extends StatefulWidget {
//   const TikestScreen({super.key});

//   @override
//   State<TikestScreen> createState() => _TikestScreenState();
// }

// class _TikestScreenState extends State<TikestScreen> {
//   final ScrollController scrollController = ScrollController();
//   final InActivityTimer timer = InActivityTimer();

//   void scrollListener() {
//     if (scrollController.position.pixels ==
//         scrollController.position.maxScrollExtent) {
//       if (Get.find<CommissionLogController>().hasNext()) {
//         Get.find<CommissionLogController>().loadPaginationData();
//       }
//     }
//   }

//   @override
//   void initState() {
//     Get.put(ApiClient(sharedPreferences: Get.find()));
//     Get.put(CommissionLogRepo(apiClient: Get.find()));
//     final controller =
//         Get.put(CommissionLogController(commissionLogRepo: Get.find()));
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       controller.initialSelectedValue();
//       scrollController.addListener(scrollListener);
//     });
//     timer.startTimer(context);
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CommissionLogController>(
//       builder: (controller) => NotificationListener<ScrollNotification>(
//         onNotification: (_) {
//           timer.handleUserInteraction(context);
//           return false;
//         },
//         child: SafeArea(
//           child: GestureDetector(
//             onTap: () => timer.handleUserInteraction(context),
//             onPanUpdate: (_) => timer.handleUserInteraction(context),
//             child: Scaffold(
//               backgroundColor: MyColor.screenBgColor,
//               appBar: CustomAppBar(
//                 title: "Mes tickets",
//               ),
//               body: controller.isLoading
//                   ? const CustomLoader()
//                   : SingleChildScrollView(
//                       controller: scrollController,
//                       physics: const BouncingScrollPhysics(),
//                       child: controller.ticketsList.isEmpty
//                           ? const Center(
//                               child: NoDataWidget(),
//                             )
//                           : (() {
//                               Map<String, List<dynamic>> groupedTickets = {
//                                 "Petit déjeuner": [],
//                                 "Déjeuner": [],
//                                 "Dîner": [],
//                                 "Transport": [],
//                               };

// // Regrouper les tickets par type spécifique
//                               for (var ticket in controller.ticketsList) {
//                                 final type = ticket.ticketType ?? "Inconnu";

//                                 if (groupedTickets.containsKey(type)) {
//                                   groupedTickets[type]!.add(ticket);
//                                 }
//                               }

//                               final filteredGroups = groupedTickets.entries
//                                   .where((entry) => entry.value.isNotEmpty)
//                                   .toList();

//                               return ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 padding: EdgeInsets.zero,
//                                 itemCount: filteredGroups.length,
//                                 separatorBuilder: (context, index) =>
//                                     const SizedBox(height: Dimensions.space10),
//                                 itemBuilder: (context, index) {
//                                   final entry = filteredGroups[index];
//                                   final ticketType = entry.key;
//                                   final tickets = entry.value;
//                                   final firstTicket = tickets.first;

//                                   final color = ticketType == "Transport"
//                                       ? Colors.blue
//                                       : ticketType == "Petit déjeuner"
//                                           ? Colors.orange
//                                           : ticketType == "Déjeuner"
//                                               ? Colors.green
//                                               : ticketType == "Dîner"
//                                                   ? Colors.purple
//                                                   : Colors.grey;

//                                   return Container(
//                                     width: MediaQuery.of(context).size.width,
//                                     padding: const EdgeInsets.all(
//                                         Dimensions.space15),
//                                     decoration: BoxDecoration(
//                                       color: MyColor.getCardBgColor(),
//                                       borderRadius: BorderRadius.circular(
//                                           Dimensions.defaultRadius),
//                                       border: Border.all(
//                                           color: color.withOpacity(0.3)),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // Ligne supérieure avec type et badge
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Icon(Icons.confirmation_number,
//                                                     color: color),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   ticketType,
//                                                   style: semiBoldDefault
//                                                       .copyWith(color: color),
//                                                 ),
//                                               ],
//                                             ),
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8,
//                                                       vertical: 2),
//                                               decoration: BoxDecoration(
//                                                 color: color.withOpacity(0.1),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               child: Text(
//                                                 "${tickets.length} ticket(s)",
//                                                 style: semiBoldDefault.copyWith(
//                                                     color: color),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                             height: Dimensions.space10),

//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             CardColumn(
//                                               header: "Categorie",
//                                               body:
//                                                   firstTicket.ticketCategory ??
//                                                       "",
//                                             ),
//                                             CardColumn(
//                                               alignmentEnd: true,
//                                               header: MyStrings.date.tr,
//                                               body: DateConverter
//                                                   .isoStringToLocalDateOnly(
//                                                       firstTicket.createdAt ??
//                                                           ""),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                             height: Dimensions.space10),

//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             CardColumn(
//                                               alignmentEnd: false,
//                                               header: "Detail",
//                                               body: firstTicket.detailTicket ??
//                                                   "",
//                                             ),
//                                             CardColumn(
//                                               alignmentEnd: true,
//                                               header: "Université",
//                                               body:
//                                                   firstTicket.schoolName ?? "",
//                                             ),
//                                           ],
//                                         ),

//                                         const CustomDivider(
//                                             space: Dimensions.space15),

//                                         Container(
//                                           width:
//                                               MediaQuery.of(context).size.width,
//                                           padding: const EdgeInsets.all(
//                                               Dimensions.space10),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(
//                                                 Dimensions.defaultRadius),
//                                             color: MyColor.getScreenBgColor(),
//                                             border: Border.all(
//                                               color: MyColor.colorGrey
//                                                   .withOpacity(0.2),
//                                               width: 0.5,
//                                             ),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(
//                                                 "${MyStrings.amount.tr}/Ticket",
//                                                 style: semiBoldDefault.copyWith(
//                                                     color: MyColor.colorBlack),
//                                               ),
//                                               Text(
//                                                 "${Converter.formatNumber(firstTicket.ticketAmount?.toString() ?? "")} CFA",
//                                                 style: regularDefault.copyWith(
//                                                   color: MyColor.colorGreen,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               );
//                             })()),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
