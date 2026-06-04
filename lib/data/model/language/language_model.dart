class LanguageModel {
  String languageName;
  String languageCode;
  String countryCode;
  String? imageUrl;

  LanguageModel({
    required this.languageName,
    required this.countryCode,
    required this.languageCode,
    this.imageUrl,
  });
}
