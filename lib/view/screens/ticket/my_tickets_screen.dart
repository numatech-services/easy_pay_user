import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viserpay/core/utils/user_inactivity.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/data/controller/user_tickets/user_ticket_controller.dart';
import 'package:viserpay/data/repo/user_ticket/user_ticket.dart';
import 'package:viserpay/data/services/api_service.dart';
import 'package:viserpay/core/helper/date_converter.dart';
import 'package:viserpay/core/helper/string_format_helper.dart';
import 'package:viserpay/core/utils/dimensions.dart';
import 'package:viserpay/core/utils/my_color.dart';
import 'package:viserpay/core/utils/my_strings.dart';
import 'package:viserpay/core/utils/style.dart';
import 'package:viserpay/view/components/app-bar/custom_appbar.dart';
import 'package:viserpay/view/components/column_widget/card_column.dart';
import 'package:viserpay/view/components/custom_loader/custom_loader.dart';
import 'package:viserpay/view/components/divider/custom_divider.dart';
import 'package:viserpay/view/components/no_data.dart';

class UserTicketScreen extends StatefulWidget {
  const UserTicketScreen({super.key});

  @override
  State<UserTicketScreen> createState() => _UserTicketScreenState();
}

class _UserTicketScreenState extends State<UserTicketScreen> {
  final ScrollController scrollController = ScrollController();
  final InActivityTimer timer = InActivityTimer();

  // ─── Config centralisée des types de tickets ───────────────────────────────
  static const Map<String, _TicketConfig> _ticketConfig = {
    'Petit déjeuner': _TicketConfig(
      color: Color(0xFFFF9800), // orange
      icon: Icons.free_breakfast,
      category: 'Repas',
    ),
    'Déjeuner / Dîner': _TicketConfig(
      color: Color(0xFF4CAF50), // vert
      icon: Icons.restaurant,
      category: 'Repas',
    ),
    'Transport': _TicketConfig(
      color: Color(0xFF2196F3), // bleu
      icon: Icons.directions_bus,
      category: 'Transport',
    ),
    'Carte de transport': _TicketConfig(
      color: Color(0xFF7C4DFF), // violet
      icon: Icons.credit_card,
      category: 'Transport',
    ),
  };

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(UserTicketRepo(apiClient: Get.find()));
    final controller =
        Get.put(UserTicketController(userTicketRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
    timer.startTimer(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ─── Normalise les anciens types vers les nouveaux ─────────────────────────
  String _normalizeType(String? raw) {
    switch (raw?.trim()) {
      case 'Déjeuner':
      case 'Dîner':
      case 'Déjeuner / Dîner':
        return 'Déjeuner / Dîner';
      case 'Carte de transport':
        return 'Carte de transport';
      case 'Transport':
        return 'Transport';
      case 'Petit déjeuner':
        return 'Petit déjeuner';
      default:
        return raw ?? 'Autre';
    }
  }

  // ─── Regroupe les tickets en préservant l'ordre défini ────────────────────
  Map<String, List<dynamic>> _groupTickets(List<dynamic> tickets) {
    final Map<String, List<dynamic>> grouped = {
      for (final key in _ticketConfig.keys) key: [],
    };

    for (final ticket in tickets) {
      final normalized = _normalizeType(ticket.ticketType);
      grouped.putIfAbsent(normalized, () => []);
      grouped[normalized]!.add(ticket);
    }

    return Map.fromEntries(
      grouped.entries.where((e) => e.value.isNotEmpty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserTicketController>(
      builder: (controller) => NotificationListener<ScrollNotification>(
        onNotification: (_) {
          timer.handleUserInteraction(context);
          return false;
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () => timer.handleUserInteraction(context),
            onPanUpdate: (_) => timer.handleUserInteraction(context),
            child: Scaffold(
              backgroundColor: MyColor.screenBgColor,
              appBar: CustomAppBar(title: "Mes Tickets"),
              body: controller.isLoading
                  ? const CustomLoader()
                  : SingleChildScrollView(
                      controller: scrollController,
                      padding: Dimensions.screenPaddingHV,
                      physics: const BouncingScrollPhysics(),
                      child: controller.ticketsList.isEmpty
                          ? const Center(child: NoDataWidget())
                          : _buildTicketList(context, controller),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketList(
      BuildContext context, UserTicketController controller) {
    final grouped = _groupTickets(controller.ticketsList);
    final entries = grouped.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Résumé global ──────────────────────────────────────────────────
        _buildSummaryRow(grouped),
        const SizedBox(height: Dimensions.space15),

        // ── Liste par type ─────────────────────────────────────────────────
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: entries.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: Dimensions.space10),
          itemBuilder: (context, index) =>
              _buildTicketCard(context, entries[index]),
        ),
      ],
    );
  }

  // ─── Bandeau résumé en haut ────────────────────────────────────────────────
  Widget _buildSummaryRow(Map<String, List<dynamic>> grouped) {
    final total = grouped.values.fold<int>(0, (sum, l) => sum + l.length);

    return Container(
      padding: const EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Total', total.toString(), Icons.confirmation_number,
              Colors.white),
          ...grouped.entries.map((e) {
            final cfg = _ticketConfig[e.key];
            return _summaryItem(
              e.key.split(' ').first, // label court
              e.value.length.toString(),
              cfg?.icon ?? Icons.label,
              cfg?.color ?? Colors.grey,
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(count,
            style: semiBoldDefault.copyWith(color: Colors.white, fontSize: 16)),
        Text(label,
            style:
                regularDefault.copyWith(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // ─── Card par type de ticket ───────────────────────────────────────────────
  Widget _buildTicketCard(
      BuildContext context, MapEntry<String, List<dynamic>> entry) {
    final ticketType = entry.key;
    final tickets = entry.value;
    final firstTicket = tickets.first;
    final cfg = _ticketConfig[ticketType] ??
        const _TicketConfig(
            color: Colors.grey, icon: Icons.label, category: '');
    final totalAmount = (firstTicket.ticketAmount ?? 0) * tickets.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardBgColor(),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
        border: Border.all(color: cfg.color.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: cfg.color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête type + badge ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cfg.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(cfg.icon, color: cfg.color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(ticketType,
                      style: semiBoldDefault.copyWith(color: cfg.color)),
                ],
              ),
              ticketType == "Carte de transport"
                  ? _badge('Validité: ${firstTicket.cardValidity}', cfg.color)
                  : _badge('${tickets.length} ticket(s)', cfg.color),
            ],
          ),
          const SizedBox(height: Dimensions.space10),

          // ── Infos catégorie / date ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(header: 'Catégorie', body: cfg.category),
              CardColumn(
                alignmentEnd: true,
                header: MyStrings.date.tr,
                body: DateConverter.isoStringToLocalDateOnly(
                    firstTicket.createdAt ?? ''),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space10),

          // ── Détail / université ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                  header: 'Détail', body: firstTicket.detailTicket ?? ''),
              CardColumn(
                alignmentEnd: true,
                header: 'Université',
                body: firstTicket.schoolName ?? '',
              ),
            ],
          ),

          const CustomDivider(space: Dimensions.space15),

          // ── Montants ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.space10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
              color: MyColor.getScreenBgColor(),
              border: Border.all(
                  color: MyColor.colorGrey.withOpacity(0.2), width: 0.5),
            ),
            child: Column(
              children: [
                _amountRow(
                  '${MyStrings.amount.tr}/Ticket',
                  '${MyUtils.formatNumber(firstTicket.ticketAmount?.toString() ?? '')} CFA',
                ),
                const SizedBox(height: 4),
                _amountRow(
                  'Total',
                  '${MyUtils.formatNumber(totalAmount.toString())} CFA',
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: semiBoldDefault.copyWith(color: color, fontSize: 12)),
      );

  Widget _amountRow(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: semiBoldDefault.copyWith(color: MyColor.colorBlack)),
          Text(value,
              style: regularDefault.copyWith(
                color: MyColor.colorGreen,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              )),
        ],
      );
}

// ─── Classe de config immuable par type ────────────────────────────────────────
class _TicketConfig {
  final Color color;
  final IconData icon;
  final String category;

  const _TicketConfig({
    required this.color,
    required this.icon,
    required this.category,
  });
}
