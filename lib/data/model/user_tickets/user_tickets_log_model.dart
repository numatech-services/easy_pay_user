import '../auth/sign_up_model/registration_response_model.dart';

class UserTicketsLogResponseModel {
  String? remark;
  String? status;
  Message? message;
  MainData? data;

  UserTicketsLogResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory UserTicketsLogResponseModel.fromJson(Map<String, dynamic> json) {
    return UserTicketsLogResponseModel(
      remark: json['remark'],
      status: json['status'],
      message:
          json['message'] != null ? Message.fromJson(json['message']) : null,
      data: json['data'] != null ? MainData.fromJson(json['data']) : null,
    );
  }
}

class MainData {
  Logs? logs;

  MainData({this.logs});

  factory MainData.fromJson(Map<String, dynamic> json) {
    return MainData(
      // ✅ json['logs'] est une liste, on la passe directement
      logs: json['logs'] != null ? Logs.fromJson(json['logs']) : null,
    );
  }
}

class Logs {
  List<Data>? data;

  Logs({this.data});

  factory Logs.fromJson(dynamic json) {
    List<Data> parsedLogs = [];

    if (json is List) {
      // ✅ logs est directement une liste — c'est ce cas ici
      parsedLogs =
          json.map((e) => Data.fromJson(e as Map<String, dynamic>)).toList();
    } else if (json is Map<String, dynamic>) {
      if (json['data'] != null) {
        parsedLogs = (json['data'] as List)
            .map((e) => Data.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['logs'] != null) {
        parsedLogs = (json['logs'] as List)
            .map((e) => Data.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return Logs(data: parsedLogs);
  }
}

class Data {
  int? id;
  String? ticketType;
  String? ticketCategory;
  int? ticketAmount;
  int? status;
  int? schoolId;
  String? detailTicket;
  String? schoolName;
  String? agentName;
  int? agentId;
  String? payedByUserName;
  int? payedByUserId;
  String? createdAt;
  String? updatedAt;
  String? crousName;
  String? cardValidity;

  Data({
    this.id,
    this.ticketType,
    this.ticketCategory,
    this.ticketAmount,
    this.status,
    this.schoolId,
    this.detailTicket,
    this.schoolName,
    this.agentName,
    this.agentId,
    this.payedByUserName,
    this.payedByUserId,
    this.createdAt,
    this.updatedAt,
    this.crousName,
    this.cardValidity,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticketType = json['ticket_type'];
    ticketCategory = json['ticket_category'];
    ticketAmount = json['ticket_amount'];
    status = json['status'];
    schoolId = json['school_id'];
    detailTicket = json['detail_ticket'];
    schoolName = json['school_name'];
    agentName = json['agent_name'];
    agentId = json['agent_id'];
    payedByUserName = json['payed_by_user_name'];
    payedByUserId = json['payed_by_user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    crousName = json['crous_name'];
    cardValidity = json['card_validity'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_type': ticketType,
      'ticket_category': ticketCategory,
      'ticket_amount': ticketAmount,
      'status': status,
      'school_id': schoolId,
      'detail_ticket': detailTicket,
      'school_name': schoolName,
      'agent_name': agentName,
      'agent_id': agentId,
      'payed_by_user_name': payedByUserName,
      'payed_by_user_id': payedByUserId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'crous_name': crousName,
      'card_validity': cardValidity,
    };
  }
}

class Currency {
  Currency({
    int? id,
    String? currencyCode,
    String? currencySymbol,
    String? currencyFullname,
    String? currencyType,
    String? rate,
    String? isDefault,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _currencyCode = currencyCode;
    _currencySymbol = currencySymbol;
    _currencyFullname = currencyFullname;
    _currencyType = currencyType;
    _rate = rate;
    _isDefault = isDefault;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Currency.fromJson(dynamic json) {
    _id = json['id'];
    _currencyCode = json['currency_code'].toString();
    _currencySymbol = json['currency_symbol'];
    _currencyFullname = json['currency_fullname'];
    _currencyType = json['currency_type'].toString();
    _rate = json['rate'].toString();
    _isDefault = json['is_default'].toString();
    _status = json['status'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  int? _id;
  String? _currencyCode;
  String? _currencySymbol;
  String? _currencyFullname;
  String? _currencyType;
  String? _rate;
  String? _isDefault;
  String? _status;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get currencyCode => _currencyCode;
  String? get currencySymbol => _currencySymbol;
  String? get currencyFullname => _currencyFullname;
  String? get currencyType => _currencyType;
  String? get rate => _rate;
  String? get isDefault => _isDefault;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['currency_code'] = _currencyCode;
    map['currency_symbol'] = _currencySymbol;
    map['currency_fullname'] = _currencyFullname;
    map['currency_type'] = _currencyType;
    map['rate'] = _rate;
    map['is_default'] = _isDefault;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
