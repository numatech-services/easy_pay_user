import 'dart:convert';
import 'package:viserpay/data/model/global/agent_exist/agent_model.dart';
import 'package:viserpay/data/model/global/meassage_model.dart';

AgentCheckResponseModal agentCheckResponseModalFromJson(String str) => AgentCheckResponseModal.fromJson(json.decode(str));

String agentCheckResponseModalToJson(AgentCheckResponseModal data) => json.encode(data.toJson());

class AgentCheckResponseModal {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  AgentCheckResponseModal({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory AgentCheckResponseModal.fromJson(Map<String, dynamic> json) => AgentCheckResponseModal(
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
  GlobalAgent? user;

  Data({
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["agent"] == null ? null : GlobalAgent.fromJson(json["agent"]),
      );

  Map<String, dynamic> toJson() => {
        "agent": user?.toJson(),
      };
}
