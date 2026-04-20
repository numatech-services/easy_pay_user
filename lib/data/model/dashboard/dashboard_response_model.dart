// To parse this JSON data, do
//
//     final dashboardResponseModel = dashboardResponseModelFromJson(jsonString);

// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

import 'package:viserpay/data/model/global/agent_exist/agent_model.dart';
import 'package:viserpay/data/model/global/meassage_model.dart';
import 'package:viserpay/data/model/global/user/user_model.dart';

// import 'package:viserpay/data/model/global/meassage_model.dart';

DashboardResponseModel dashboardResponseModelFromJson(String str) =>
    DashboardResponseModel.fromJson(json.decode(str));

String dashboardResponseModelToJson(DashboardResponseModel data) =>
    json.encode(data.toJson());

class DashboardResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  DashboardResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      DashboardResponseModel(
        remark: json["remark"],
        status: json["status"].toString(),
        message:
            json["message"] == null ? null : Message.fromJson(json["message"]),
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
  GlobalUser? user;
  List<AllUtility>? allUtility;
  List<AppBanner>? appBanners;
  List<Merchant>? merchants;
  List<LatestTransaction>? latestTransactions;

  Data({
    this.user,
    this.allUtility,
    this.appBanners,
    this.merchants,
    this.latestTransactions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : GlobalUser.fromJson(json["user"]),
        allUtility: json["all_utility"] == null
            ? []
            : List<AllUtility>.from(
                json["all_utility"]!.map((x) => AllUtility.fromJson(x))),
        appBanners: json["app_banners"] == null
            ? []
            : List<AppBanner>.from(
                json["app_banners"]!.map((x) => AppBanner.fromJson(x))),
        merchants: json["merchants"] == null
            ? []
            : List<Merchant>.from(
                json["merchants"]!.map((x) => Merchant.fromJson(x))),
        latestTransactions: json["latest_transactions"] == null
            ? []
            : List<LatestTransaction>.from(json["latest_transactions"]!
                .map((x) => LatestTransaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "all_utility": allUtility == null
            ? []
            : List<dynamic>.from(allUtility!.map((x) => x.toJson())),
        "app_banners": appBanners == null
            ? []
            : List<dynamic>.from(appBanners!.map((x) => x.toJson())),
        "merchants": merchants == null
            ? []
            : List<dynamic>.from(merchants!.map((x) => x.toJson())),
        "latest_transactions": latestTransactions == null
            ? []
            : List<dynamic>.from(latestTransactions!.map((x) => x.toJson())),
      };
}

class AllUtility {
  String? id;
  String? name;
  String? formId;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? getImage;

  AllUtility({
    this.id,
    this.name,
    this.formId,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.getImage,
  });

  factory AllUtility.fromJson(Map<String, dynamic> json) => AllUtility(
        id: json["id"].toString(),
        name: json["name"],
        formId: json["form_id"].toString(),
        image: json["image"].toString(),
        status: json["status"].toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        getImage: json["get_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "form_id": formId,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "get_image": getImage,
      };
}

class AppBanner {
  String? id;
  String? dataKeys;
  DataValues? dataValues;

  String? getImage;

  AppBanner({
    this.id,
    this.dataKeys,
    this.dataValues,
    this.getImage,
  });

  factory AppBanner.fromJson(Map<String, dynamic> json) => AppBanner(
        id: json["id"].toString(),
        dataKeys: json["data_keys"].toString(),
        dataValues: json["data_values"] == null
            ? null
            : DataValues.fromJson(json["data_values"]),
        getImage: json["get_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "data_keys": dataKeys,
        "data_values": dataValues?.toJson(),
        "get_image": getImage,
      };
}

class DataValues {
  String? hasImage;
  String? link;
  String? image;

  DataValues({
    this.hasImage,
    this.link,
    this.image,
  });

  factory DataValues.fromJson(Map<String, dynamic> json) => DataValues(
        hasImage: json["has_image"],
        link: json["link"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "has_image": hasImage,
        "link": link,
        "image": image,
      };
}

class LatestTransaction {
  String? id;
  String? setupDonationId;
  String? userId;
  String? userType;
  String? receiverId;
  String? receiverType;
  //
  GlobalUser? receiverUser;
  GlobalAgent? receiverAgent;
  GlobalAgent? receiverMerchant;
//
  String? beforeCharge;
  String? amount;
  String? charge;
  String? postBalance;
  String? trxType;
  String? ticketNumber;
  String? chargeType;
  String? trx;
  String? details;
  String? remark;
  String? payment_type;
  String? reference;
  String? hideIdentity;
  String? createdAt;
  String? updatedAt;
  DonationFor? donationFor;
  String? mobileRecharge;
  RelatedTransaction? relatedTransaction;
  LatestTransaction({
    this.id,
    this.setupDonationId,
    this.userId,
    this.userType,
    this.receiverId,
    this.receiverType,
    this.receiverUser,
    this.receiverAgent,
    this.receiverMerchant,
    this.beforeCharge,
    this.amount,
    this.charge,
    this.postBalance,
    this.trxType,
    this.ticketNumber,
    this.chargeType,
    this.trx,
    this.details,
    this.remark,
    this.payment_type,
    this.reference,
    this.hideIdentity,
    this.createdAt,
    this.updatedAt,
    this.donationFor,
    this.mobileRecharge,
    this.relatedTransaction,
  });

  factory LatestTransaction.fromJson(Map<String, dynamic> json) =>
      LatestTransaction(
        id: json["id"].toString(),
        setupDonationId: json["setup_donation_id"].toString(),
        userId: json["user_id"].toString(),
        userType: json["user_type"].toString(),
        receiverId: json["receiver_id"].toString(),
        receiverType: json["receiver_type"].toString(),
        receiverUser: json["receiver_user"] == null
            ? null
            : GlobalUser.fromJson(json["receiver_user"]),
        receiverAgent: json["receiver_agent"] == null
            ? null
            : GlobalAgent.fromJson(json["receiver_agent"]),
        receiverMerchant: json["receiver_merchant"] == null
            ? null
            : GlobalAgent.fromJson(json["receiver_merchant"]),
        beforeCharge: json["before_charge"].toString(),
        amount: json["amount"].toString(),
        ticketNumber: json["nombre_ticket"].toString(),
        charge: json["charge"].toString(),
        postBalance: json["post_balance"].toString(),
        trxType: json["trx_type"].toString(),
        chargeType: json["charge_type"].toString(),
        trx: json["trx"].toString(),
        details: json["details"].toString(),
        remark: json["remark"].toString(),
        payment_type: json["payment_type"].toString(),
        reference: json["reference"].toString(),
        hideIdentity: json["hide_identity"].toString(),
        createdAt: json["created_at"] == null ? null : json["created_at"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        donationFor: json["donation_for"] == null
            ? null
            : DonationFor.fromJson(json["donation_for"]),
        mobileRecharge: json["mobile_recharge"] == null
            ? null
            : jsonEncode(json["mobile_recharge"]),
        relatedTransaction: json["related_transaction"] == null
            ? null
            : RelatedTransaction.fromJson(json["related_transaction"]),
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
        "nombre_ticket": ticketNumber,
        "charge_type": chargeType,
        "trx": trx,
        "details": details,
        "remark": remark,
        "payment_type": payment_type,
        "reference": reference,
        "hide_identity": hideIdentity,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "mobile_recharge": mobileRecharge
      };
}

class Merchant {
  String? id;
  String? firstname;
  String? lastname;
  String? username;
  String? email;
  String? countryCode;
  String? mobile;
  String? refBy;
  MerchantAddress? address;
  String? image;
  String? status;
  String? kv;
  String? ev;
  String? sv;
  String? profileComplete;
  String? verCodeSendAt;
  String? ts;
  String? tv;
  String? tsc;
  String? banReason;
  String? balance;
  String? createdAt;
  String? updatedAt;
  String? getImage;
  Merchant({
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.countryCode,
    this.mobile,
    this.refBy,
    this.balance,
    this.image,
    this.address,
    this.status,
    this.kv,
    this.ev,
    this.sv,
    this.profileComplete,
    this.verCodeSendAt,
    this.ts,
    this.tv,
    this.tsc,
    this.banReason,
    this.createdAt,
    this.updatedAt,
    this.getImage,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
        id: json["id"].toString(),
        firstname: json["firstname"],
        lastname: json["lastname"],
        username: json["username"],
        email: json["email"],
        countryCode: json["country_code"].toString(),
        mobile: json["mobile"].toString(),
        refBy: json["ref_by"].toString(),
        balance: json["balance"].toString(),
        image: json["image"].toString(),
        address: json["address"] == null
            ? null
            : MerchantAddress.fromJson(json["address"]),
        status: json["status"].toString(),
        kv: json["kv"].toString(),
        ev: json["ev"].toString(),
        sv: json["sv"].toString(),
        profileComplete: json["profile_complete"].toString(),
        ts: json["ts"].toString(),
        tv: json["tv"].toString(),
        tsc: json["tsc"].toString(),
        banReason: json["ban_reason"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        getImage: json["get_image"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "username": username,
        "email": email,
        "country_code": countryCode,
        "mobile": mobile,
        "ref_by": refBy,
        "balance": balance,
        "image": image,
        "address": address?.toJson(),
        "status": status,
        "kv": kv,
        "ev": ev,
        "sv": sv,
        "profile_complete": profileComplete,
        "ts": ts,
        "tv": tv,
        "tsc": tsc,
        "ban_reason": banReason,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
        "get_image": getImage,
      };
}

class MerchantAddress {
  String? address;
  String? state;
  String? zip;
  String? country;
  String? city;

  MerchantAddress({
    this.address,
    this.state,
    this.zip,
    this.country,
    this.city,
  });

  factory MerchantAddress.fromJson(Map<String, dynamic> json) =>
      MerchantAddress(
        address: json["address"],
        state: json["state"],
        zip: json["zip"].toString(),
        country: json["country"],
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "state": state,
        "zip": zip,
        "country": country,
        "city": city,
      };
}

class DonationFor {
  String? id;
  String? name;
  String? address;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? getImage;

  DonationFor({
    this.id,
    this.name,
    this.address,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.getImage,
  });

  factory DonationFor.fromJson(Map<String, dynamic> json) => DonationFor(
        id: json["id"].toString(),
        name: json["name"],
        address: json["address"],
        image: json["image"],
        status: json["status"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        getImage: json["get_image"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "image": image,
        "status": status,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
        "get_image": getImage,
      };
}

class RelatedTransaction {
  String? id;
  String? setupDonationId;
  String? userId;
  String? userType;
  String? receiverId;
  String? receiverType;
  String? beforeCharge;
  String? amount;
  String? charge;
  String? postBalance;
  String? trxType;
  String? chargeType;
  String? trx;
  String? details;
  String? remark;
  dynamic reference;
  String? hideIdentity;
  String? createdAt;
  String? updatedAt;
  GlobalUser? user;

  RelatedTransaction({
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
    this.user,
  });

  factory RelatedTransaction.fromJson(Map<String, dynamic> json) {
    return RelatedTransaction(
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
      updatedAt: json["updated_at"].toString(),
      user: json["user"] == null ? null : GlobalUser.fromJson(json["user"]),
    );
  }

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
        "user": user?.toJson(),
      };
}
