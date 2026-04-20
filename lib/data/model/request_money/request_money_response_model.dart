import 'dart:convert';

import 'package:viserpay/data/model/global/meassage_model.dart';

RequestMoneyResponseModel sendMoneyResponseModelFromJson(String str) => RequestMoneyResponseModel.fromJson(json.decode(str));

String sendMoneyResponseModelToJson(RequestMoneyResponseModel data) => json.encode(data.toJson());

class RequestMoneyResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  RequestMoneyResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory RequestMoneyResponseModel.fromJson(Map<String, dynamic> json) => RequestMoneyResponseModel(
        remark: json["remark"],
        status: json["status"].toString(),
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
  List<String>? otpType;
  int? currentBalance;
  RequestedMoneyCharge? requestMoneyCharge;

  Data({
    this.otpType,
    this.currentBalance,
    this.requestMoneyCharge,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        otpType: json["otp_type"] == null ? [] : List<String>.from(json["otp_type"]!.map((x) => x)),
        currentBalance: json["current_balance"] ,
        requestMoneyCharge: json["transfer_charge"] == null ? null : RequestedMoneyCharge.fromJson(json["transfer_charge"]),
      );

  Map<String, dynamic> toJson() => {
        "otp_type": otpType == null ? [] : List<dynamic>.from(otpType!.map((x) => x)),
        "current_balance": currentBalance,
        "transfer_charge": requestMoneyCharge?.toJson(),
      };
}

class RequestedMoneyCharge {
  String? id;
  String? slug;
  String? fixedCharge;
  String? percentCharge;
  String? minLimit;
  String? maxLimit;
  String? agentCommissionFixed;
  String? agentCommissionPercent;
  String? merchantFixedCharge;
  String? merchantPercentCharge;
  String? monthlyLimit;
  String? dailyLimit;
  String? dailyRequestAcceptLimit;
  String? cap;
  String? createdAt;
  String? updatedAt;

  RequestedMoneyCharge({
    this.id,
    this.slug,
    this.fixedCharge,
    this.percentCharge,
    this.minLimit,
    this.maxLimit,
    this.agentCommissionFixed,
    this.agentCommissionPercent,
    this.merchantFixedCharge,
    this.merchantPercentCharge,
    this.monthlyLimit,
    this.dailyLimit,
    this.dailyRequestAcceptLimit,
    this.cap,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestedMoneyCharge.fromJson(Map<String, dynamic> json) => RequestedMoneyCharge(
        id: json["id"].toString(),
        slug: json["slug"],
        fixedCharge: json["fixed_charge"].toString(),
        percentCharge: json["percent_charge"].toString(),
        minLimit: json["min_limit"].toString(),
        maxLimit: json["max_limit"].toString(),
        agentCommissionFixed: json["agent_commission_fixed"].toString(),
        agentCommissionPercent: json["agent_commission_percent"].toString(),
        merchantFixedCharge: json["merchant_fixed_charge"].toString(),
        merchantPercentCharge: json["merchant_percent_charge"].toString(),
        monthlyLimit: json["monthly_limit"].toString(),
        dailyLimit: json["daily_limit"].toString(),
        dailyRequestAcceptLimit: json["daily_request_accept_limit"].toString(),
        cap: json["cap"].toString(),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "fixed_charge": fixedCharge,
        "percent_charge": percentCharge,
        "min_limit": minLimit,
        "max_limit": maxLimit,
        "agent_commission_fixed": agentCommissionFixed,
        "agent_commission_percent": agentCommissionPercent,
        "merchant_fixed_charge": merchantFixedCharge,
        "merchant_percent_charge": merchantPercentCharge,
        "monthly_limit": monthlyLimit,
        "daily_limit": dailyLimit,
        "daily_request_accept_limit": dailyRequestAcceptLimit,
        "cap": cap,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
      };
}

// class RelatedTransaction {
//   String? id;
//   String? setupDonationId;
//   String? userId;
//   String? userType;
//   String? receiverId;
//   String? receiverType;
//   String? beforeCharge;
//   String? amount;
//   String? charge;
//   String? postBalance;
//   String? trxType;
//   String? chargeType;
//   String? trx;
//   String? details;
//   String? remark;
//   dynamic reference;
//   String? hideIdentity;
//   String? createdAt;
//   String? updatedAt;
//   ReceiverUser? user;

//   RelatedTransaction({
//     this.id,
//     this.setupDonationId,
//     this.userId,
//     this.userType,
//     this.receiverId,
//     this.receiverType,
//     this.beforeCharge,
//     this.amount,
//     this.charge,
//     this.postBalance,
//     this.trxType,
//     this.chargeType,
//     this.trx,
//     this.details,
//     this.remark,
//     this.reference,
//     this.hideIdentity,
//     this.createdAt,
//     this.updatedAt,
//     this.user,
//   });

//   factory RelatedTransaction.fromJson(Map<String, dynamic> json) {
//     return RelatedTransaction(
//       id: json["id"].toString(),
//       setupDonationId: json["setup_donation_id"].toString(),
//       userId: json["user_id"].toString(),
//       userType: json["user_type"].toString(),
//       receiverId: json["receiver_id"].toString(),
//       receiverType: json["receiver_type"].toString(),
//       beforeCharge: json["before_charge"].toString(),
//       amount: json["amount"].toString(),
//       charge: json["charge"].toString(),
//       postBalance: json["post_balance"].toString(),
//       trxType: json["trx_type"].toString(),
//       chargeType: json["charge_type"].toString(),
//       trx: json["trx"].toString(),
//       details: json["details"].toString(),
//       remark: json["remark"].toString(),
//       reference: json["reference"].toString(),
//       hideIdentity: json["hide_identity"].toString(),
//       createdAt: json["created_at"].toString(),
//       updatedAt: json["updated_at"].toString(),
//       user: json["user"] == null ? null : ReceiverUser.fromJson(json["user"]),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "setup_donation_id": setupDonationId,
//         "user_id": userId,
//         "user_type": userType,
//         "receiver_id": receiverId,
//         "receiver_type": receiverType,
//         "before_charge": beforeCharge,
//         "amount": amount,
//         "charge": charge,
//         "post_balance": postBalance,
//         "trx_type": trxType,
//         "charge_type": chargeType,
//         "trx": trx,
//         "details": details,
//         "remark": remark,
//         "reference": reference,
//         "hide_identity": hideIdentity,
//         "created_at": createdAt,
//         "updated_at": updatedAt,
//         "user": user?.toJson(),
//       };
// }
