// To parse this JSON data, do
//
//     final requesToMeMoneyHistoryResponseModel = requesToMeMoneyHistoryResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:viserpay/data/model/global/meassage_model.dart';
import 'package:viserpay/data/model/global/user/user_model.dart';

RequesToMeMoneyHistoryResponseModel requesToMeMoneyHistoryResponseModelFromJson(String str) => RequesToMeMoneyHistoryResponseModel.fromJson(json.decode(str));

String requesToMeMoneyHistoryResponseModelToJson(RequesToMeMoneyHistoryResponseModel data) => json.encode(data.toJson());

class RequesToMeMoneyHistoryResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  RequesToMeMoneyHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory RequesToMeMoneyHistoryResponseModel.fromJson(Map<String, dynamic> json) => RequesToMeMoneyHistoryResponseModel(
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
  List<String>? otpType;
  RequestToMeData? requests;

  Data({
    this.otpType,
    this.requests,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        otpType: json["otp_type"] == null ? [] : List<String>.from(json["otp_type"]!.map((x) => x)),
        requests: json["requests"] == null ? null : RequestToMeData.fromJson(json["requests"]),
      );

  Map<String, dynamic> toJson() => {
        "otp_type": otpType == null ? [] : List<dynamic>.from(otpType!.map((x) => x)),
        "requests": requests?.toJson(),
      };
}

class RequestToMeData {
  List<RequestToMe>? data;
  String? nextPageUrl;

  RequestToMeData({
    this.data,
    this.nextPageUrl,
  });

  factory RequestToMeData.fromJson(Map<String, dynamic> json) => RequestToMeData(
        data: json["data"] == null ? [] : List<RequestToMe>.from(json["data"]!.map((x) => RequestToMe.fromJson(x))),
        nextPageUrl: json["next_page_url"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class RequestToMe {
  String? id; //str
  String? charge;
  String? requestAmount;
  String? senderId; //str
  String? receiverId; //str
  String? note;
  String? status; //str
  String? createdAt;
  String? updatedAt;
  GlobalUser? sender;

  RequestToMe({
    this.id,
    this.charge,
    this.requestAmount,
    this.senderId,
    this.receiverId,
    this.note,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.sender,
  });

  factory RequestToMe.fromJson(Map<String, dynamic> json) => RequestToMe(
        id: json["id"].toString(),
        charge: json["charge"].toString(),
        requestAmount: json["request_amount"].toString(),
        senderId: json["sender_id"].toString(),
        receiverId: json["receiver_id"].toString(),
        note: json["note"],
        status: json["status"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        sender: json["sender"] == null ? null : GlobalUser.fromJson(json["sender"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "charge": charge,
        "request_amount": requestAmount,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "note": note,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "sender": sender?.toJson(),
      };
}
