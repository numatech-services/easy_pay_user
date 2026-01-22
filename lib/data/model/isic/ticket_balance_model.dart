class TicketBalance {
  int petitDejeuner;
  int dejeuner;
  int diner;
  int transport;

  TicketBalance({
    required this.petitDejeuner,
    required this.dejeuner,
    required this.diner,
    required this.transport,
  });

  factory TicketBalance.empty() {
    return TicketBalance(
      petitDejeuner: 0,
      dejeuner: 0,
      diner: 0,
      transport: 0,
    );
  }

  factory TicketBalance.fromJson(Map<String, dynamic> json) {
    return TicketBalance(
      petitDejeuner: json['petit_dejeuner'] is int
          ? json['petit_dejeuner']
          : int.tryParse(json['petit_dejeuner']?.toString() ?? '0') ?? 0,
      dejeuner: json['dejeuner'] is int
          ? json['dejeuner']
          : int.tryParse(json['dejeuner']?.toString() ?? '0') ?? 0,
      diner: json['diner'] is int
          ? json['diner']
          : int.tryParse(json['diner']?.toString() ?? '0') ?? 0,
      transport: json['transport'] is int
          ? json['transport']
          : int.tryParse(json['transport']?.toString() ?? '0') ?? 0,
    );
  }

  int byType(String type) {
    switch (type) {
      case 'petit_dejeuner':
        return petitDejeuner;
      case 'dejeuner':
        return dejeuner;
      case 'diner':
        return diner;
      case 'transport':
        return transport;
      default:
        return 0;
    }
  }
}
