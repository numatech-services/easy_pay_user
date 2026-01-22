// To parse this JSON data, do
//
//     final paymentLinkHistoryResponseModel = paymentLinkHistoryResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:viserpay/data/model/global/meassage_model.dart';

PaymentLinkHistoryResponseModel paymentLinkHistoryResponseModelFromJson(String str) => PaymentLinkHistoryResponseModel.fromJson(json.decode(str));

String paymentLinkHistoryResponseModelToJson(PaymentLinkHistoryResponseModel data) => json.encode(data.toJson());

class PaymentLinkHistoryResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  PaymentLinkHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory PaymentLinkHistoryResponseModel.fromJson(Map<String, dynamic> json) => PaymentLinkHistoryResponseModel(
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
  PaymentLinksData? paymentLinks;

  Data({
    this.paymentLinks,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        paymentLinks: json["payment_links"] == null ? null : PaymentLinksData.fromJson(json["payment_links"]),
      );

  Map<String, dynamic> toJson() => {
        "payment_links": paymentLinks?.toJson(),
      };
}

class PaymentLinksData {
  List<PaymentLink>? data;
  dynamic nextPageUrl;

  PaymentLinksData({
    this.data,
    this.nextPageUrl,
  });

  factory PaymentLinksData.fromJson(Map<String, dynamic> json) => PaymentLinksData(
        data: json["data"] == null ? [] : List<PaymentLink>.from(json["data"]!.map((x) => PaymentLink.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class PaymentLink {
  String? id; //str
  String? userId; //str
  String? amount;
  String? code;
  String? isPaid; //str
  String? paidBy; //str
  String? createdAt;
  String? updatedAt;

  PaymentLink({
    this.id,
    this.userId,
    this.amount,
    this.code,
    this.isPaid,
    this.paidBy,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) => PaymentLink(
        id: json["id"].toString(),
        userId: json["user_id"].toString(),
        amount: json["amount"].toString(),
        code: json["code"].toString(),
        isPaid: json["is_paid"].toString(),
        paidBy: json["paid_by"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "code": code,
        "is_paid": isPaid,
        "paid_by": paidBy,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
