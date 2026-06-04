// To parse this JSON data, do
//
//     final requesToMeMoneyHistoryResponseModel = requesToMeMoneyHistoryResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:viserpay/data/model/airtime/operator_response_model.dart';
import 'package:viserpay/data/model/global/meassage_model.dart';

AirtimeHistoryResponseModel requesToMeMoneyHistoryResponseModelFromJson(String str) => AirtimeHistoryResponseModel.fromJson(json.decode(str));

String requesToMeMoneyHistoryResponseModelToJson(AirtimeHistoryResponseModel data) => json.encode(data.toJson());

class AirtimeHistoryResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  AirtimeHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory AirtimeHistoryResponseModel.fromJson(Map<String, dynamic> json) => AirtimeHistoryResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "remark": remark,
        "status": status,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Data {
  AirtimeHistoryTransaction? transactions;

  Data({
    this.transactions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        transactions: json["transactions"] == null ? null : AirtimeHistoryTransaction.fromJson(json["transactions"]),
      );

  Map<String, dynamic> toJson() => {
        "transactions": transactions?.toJson(),
      };
}

class AirtimeHistoryTransaction {
  List<AirtimeHistory>? data;
  String? nextPageUrl;

  AirtimeHistoryTransaction({
    this.data,
    this.nextPageUrl,
  });

  factory AirtimeHistoryTransaction.fromJson(Map<String, dynamic> json) => AirtimeHistoryTransaction(
        data: json["data"] == null ? [] : List<AirtimeHistory>.from(json["data"]!.map((x) => AirtimeHistory.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class AirtimeHistory {
  String? id; //
  String? setupDonationId; //
  String? userId; //
  String? userType; //
  String? receiverId; //
  String? receiverType; //
  String? beforeCharge;
  String? amount;
  String? charge;
  String? postBalance;
  String? trxType;
  String? chargeType; //
  String? trx;
  String? details;
  String? remark;
  String? reference; //
  String? hideIdentity; //
  String? createdAt;
  String? updatedAt;
  Operator? operator;

  AirtimeHistory({
    this.id,
    this.setupDonationId,
    this.userId,
    this.userType,
    this.receiverId,
    this.receiverType,
    this.beforeCharge,
    this.amount,
    this.charge,
    this.postBalance,
    this.trxType,
    this.chargeType,
    this.trx,
    this.details,
    this.remark,
    this.reference,
    this.hideIdentity,
    this.createdAt,
    this.updatedAt,
    this.operator,
  });

  factory AirtimeHistory.fromJson(Map<String, dynamic> json) => AirtimeHistory(
        id: json["id"].toString(),
        setupDonationId: json["setup_donation_id"].toString(),
        userId: json["user_id"].toString(),
        userType: json["user_type"].toString(),
        receiverId: json["receiver_id"].toString(),
        receiverType: json["receiver_type"].toString(),
        beforeCharge: json["before_charge"].toString(),
        amount: json["amount"].toString(),
        charge: json["charge"].toString(),
        postBalance: json["post_balance"].toString(),
        trxType: json["trx_type"].toString(),
        chargeType: json["charge_type"].toString(),
        trx: json["trx"].toString(),
        details: json["details"].toString(),
        remark: json["remark"].toString(),
        reference: json["reference"].toString(),
        hideIdentity: json["hide_identity"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"],
        operator: json["operator"] == null ? null : Operator.fromJson(json["operator"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "setup_donation_id": setupDonationId,
        "user_id": userId,
        "user_type": userType,
        "receiver_id": receiverId,
        "receiver_type": receiverType,
        "before_charge": beforeCharge,
        "amount": amount,
        "charge": charge,
        "post_balance": postBalance,
        "trx_type": trxType,
        "charge_type": chargeType,
        "trx": trx,
        "details": details,
        "remark": remark,
        "reference": reference,
        "hide_identity": hideIdentity,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "operator": operator,
      };
}
