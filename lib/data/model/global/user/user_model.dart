class GlobalUser {
  GlobalUser({
    int? id,
    String? firstname,
    String? isic_num,
    String? matricule,
    String? lastname,
    String? username,
    String? email,
    String? countryCode,
    String? dialCode,
    String? mobile,
    String? refBy,
    String? pin,
    String? balance,
    String? image,
    String? getimage,
    String? isPinset,
    String? address,
    String? state,
    String? zip,
    String? country,
    String? city,
    String? status,
    String? ev,
    String? sv,
    String? kv,
    String? kycRejectionReason,
    dynamic verCode,
    dynamic verCodeSendAt,
    String? ts,
    String? tv,
    String? tsc,
    String? regStep,
    String? buyFreePackage,
    String? en,
    String? pn,
    String? allowPromotionalNotifications,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _firstname = firstname;
    _lastname = lastname;
    _username = username;
    _email = email;
    _countryCode = countryCode;
    _dialCode = dialCode;
    _mobile = mobile;
    _pin = pin;
    _balance = balance;
    _image = image;
    _getimage = getimage;
    _isPinset = isPinset;
    _address = address;
    _state = state;
    _zip = zip;
    isic_num = isic_num;
    matricule = matricule;
    _country = country;
    _city = city;
    _status = status;
    _ev = ev;
    _sv = sv;
    _kv = kv;
    _kycRejectionReason = kycRejectionReason;
    _ts = ts;
    _tv = tv;
    _tsc = tsc;
    _profileComplete = regStep;
    _buyFreePackage = buyFreePackage;
    _en = en;
    _pn = pn;
    _allowPromotionalNotifications = allowPromotionalNotifications;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  GlobalUser.fromJson(dynamic json) {
    _id = json['id'];
    _firstname = json['firstname'];
    _lastname = json['lastname'];
    _username = json['username'];
    isicNum = json['isic_num'];
    _matricule = json['matricule'];
    _email = json['email'];
    _pin = json['pin']?.toString();
    _countryCode = json['country_code'].toString();
    _dialCode = json['dial_code'].toString();
    _mobile = json['mobile'].toString();
    _balance = json['balance'] != null ? json['balance'].toString() : '0';
    _image = json['image'];
    _getimage = json['get_image'];
    _isPinset = json['is_pin_set'] != null ? json['is_pin_set'].toString() : "0";
    _address = json['address'];
    _state = json['state'];
    _zip = json['zip'] != null ? json['zip'].toString() : '';
    _country = json['country'];
    _city = json['city'];
    _status = json['status'].toString();

    _ev = json['ev'].toString();
    _sv = json['sv'].toString();

    _profileComplete = json['profile_complete'].toString();
    _ts = json['ts'].toString();
    _tv = json['tv'].toString();
    _kv = json['kv'].toString();
    _kycRejectionReason = json['kyc_rejection_reason'];
    _tsc = json['tsc'].toString();

    _allowPromotionalNotifications = json['is_allow_promotional_notify'].toString();
    _en = json['en'].toString();
    _pn = json['pn'].toString();

    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  int? _id;
  String? _firstname;
  String? _lastname;
  String? _username;
  String? isicNum;
  String? _matricule;
  String? _email;
  String? _countryCode;
  String? _dialCode;
  String? _mobile;
  String? _pin;
  String? _balance;
  String? _image;
  String? _getimage;
  String? _isPinset;
  String? _address;
  String? _state;
  String? _zip;
  String? _country;
  String? _city;
  String? _status;
  String? _ev;
  String? _kv;
  String? _kycRejectionReason;
  String? _sv;
  String? _profileComplete;
  String? _ts;
  String? _tv;
  String? _tsc;

  String? _en;
  String? _pn;
  String? _allowPromotionalNotifications;

  String? _buyFreePackage;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get username => _username;
  String? get isic_num => isicNum;
  String? get matricule => _matricule;
  String? get email => _email;
  String? get countryCode => _countryCode;
  String? get dialCode => _dialCode;
  String? get mobile => _mobile;
  String? get pin => _pin;

  String? get balance => _balance;
  String? get image => _image;
  String? get getImage => _getimage;
  String? get isPinSet => _isPinset;

  String? get status => _status;
  String? get ev => _ev;
  String? get kv => _kv;
  String? get kycRejectionReason => _kycRejectionReason;
  String? get sv => _sv;

  String? get address => _address;
  String? get state => _state;
  String? get zip => _zip;
  String? get country => _country;
  String? get city => _city;

  String? get ts => _ts;
  String? get tv => _tv;
  dynamic get tsc => _tsc;
  dynamic get profileComplete => _profileComplete;

  dynamic get en => _en;
  dynamic get pn => _pn;
  dynamic get allowPromotionalNotifications => _allowPromotionalNotifications;

  String? get buyFreePackage => _buyFreePackage;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['firstname'] = _firstname;
    map['lastname'] = _lastname;
    map['isic_num'] = isicNum;
    map['matricule'] = _matricule;
    map['username'] = _username;
    map['email'] = _email;
    map['country_code'] = _countryCode;
    map['dial_code'] = _dialCode;
    map['mobile'] = _mobile;

    map['balance'] = _balance;
    map['image'] = _image;
    map['profile_complete'] = _profileComplete;

    map['address'] = _address;
    map['state'] = _state;
    map['zip'] = _zip;
    map['country'] = _country;
    map['city'] = _city;

    map['status'] = _status;
    map['ev'] = _ev;
    map['sv'] = _sv;
    map['ts'] = _ts;
    map['tv'] = _tv;
    map['tsc'] = _tsc;

    map['buy_free_package'] = _buyFreePackage;

    map['is_allow_promotional_notify'] = _allowPromotionalNotifications;
    map['en'] = _en;
    map['pn'] = _pn;

    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
