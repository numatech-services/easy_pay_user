class IsicCardModel {
  final String cardNumber;
  final String status;
  final String validTo;
  final String lastModifiedOn;
  final bool photo;
  final List<IsicImageModel> images;

  IsicCardModel({
    required this.cardNumber,
    required this.status,
    required this.validTo,
    required this.lastModifiedOn,
    required this.photo,
    required this.images,
  });

  factory IsicCardModel.fromJson(Map<String, dynamic> json) {
    return IsicCardModel(
      cardNumber: json['cardNumber'] ?? '',
      status: json['status'] ?? '',
      validTo: json['validTo'] ?? '',
      lastModifiedOn: json['lastModifiedOn'] ?? '',
      photo: json['photo'] ?? false,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => IsicImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'status': status,
      'validTo': validTo,
      'lastModifiedOn': lastModifiedOn,
      'photo': photo,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  bool get isValid {
    return status == 'VALID' && DateTime.parse(validTo).isAfter(DateTime.now());
  }

  bool get hasPhoto => photo;
}

class IsicImageModel {
  final String type;
  final String url;
  final String orientation;

  IsicImageModel({
    required this.type,
    required this.url,
    required this.orientation,
  });

  factory IsicImageModel.fromJson(Map<String, dynamic> json) {
    return IsicImageModel(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      orientation: json['orientation'] ?? 'HORIZONTAL',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'orientation': orientation,
    };
  }

  bool get isFront => type == 'FRONT';
  bool get isBack => type == 'BACK';
}
