import 'package:viserpay/data/model/global/meassage_model.dart';
import 'package:viserpay/data/model/global/user/user_model.dart';

class MyRequestMoneyHistoryResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  MyRequestMoneyHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });
  factory MyRequestMoneyHistoryResponseModel.fromJson(Map<String, dynamic> json) => MyRequestMoneyHistoryResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
}

class Data {
  MyRequestsData? requests;

  Data({
    this.requests,
  });
  factory Data.fromJson(Map<String, dynamic> json) => Data(
        requests: json["requests"] == null ? null : MyRequestsData.fromJson(json["requests"]),
      );
}

class MyRequestsData {
  List<MyRequest>? data;
  String? nextPageUrl;

  MyRequestsData({
    this.data,
    this.nextPageUrl,
  });

  factory MyRequestsData.fromJson(Map<String, dynamic> json) => MyRequestsData(
        data: json["data"] == null ? [] : List<MyRequest>.from(json["data"]!.map((x) => MyRequest.fromJson(x))),
        nextPageUrl: json["next_page_url"].toString(),
      );
}

class MyRequest {
  String? id;
  String? charge;
  String? requestAmount;
  String? senderId;
  String? receiverId;
  String? note;
  String? status;
  String? createdAt;
  String? updatedAt;
  GlobalUser? receiver;

  MyRequest({
    this.id,
    this.charge,
    this.requestAmount,
    this.senderId,
    this.receiverId,
    this.note,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.receiver,
  });

  factory MyRequest.fromJson(Map<String, dynamic> json) => MyRequest(
        id: json["id"].toString(),
        charge: json["charge"].toString(),
        requestAmount: json["request_amount"].toString(),
        senderId: json["sender_id"].toString(),
        receiverId: json["receiver_id"].toString(),
        note: json["note"].toString(),
        status: json["status"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        receiver: json["receiver"] == null ? null : GlobalUser.fromJson(json["receiver"]),
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
        "receiver": receiver?.toJson(),
      };
}
