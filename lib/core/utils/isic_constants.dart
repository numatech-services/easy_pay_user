import 'package:flutter/widgets.dart';

class IsicConstants {
  static const String clientId = 'VOTRE_CLIENT_ID';
  static const String clientSecret = 'VOTRE_CLIENT_SECRET';
  static const String redirectUri = 'votre-app://isic-callback';
  // API URLs
  static const String stagingApiUrl = 'https://staging-api.isic.org';
  static const String stagingAmUrl = 'https://staging-am.isic.org';
  static const String productionApiUrl = 'https://api.isic.org';
  static const String productionAmUrl = 'https://am.isic.org';

  // Environment (à changer selon le mode)
  static const bool isProduction = false;
  static String get apiUrl => isProduction ? productionApiUrl : stagingApiUrl;
  static String get amUrl => isProduction ? productionAmUrl : stagingAmUrl;

  // Endpoints
  static const String authorizationEndpoint =
      '/am/oauth2.0/authorization/card_info';
  static const String tokenEndpoint = '/am/oauth2.0/accessToken';
  static const String profileEndpoint = '/am/oauth2.0/profile';
  static const String virtualIdEndpoint = '/ccdb2/rest/1.0/virtualId';
  static const String photoEndpoint = '/ccdb2/rest/1.0/profilePhotos';

  // Colors (selon documentation ISIC)
  static const Color timestampValidBg = Color(0xFF4A4A4A);
  static const Color validDotColor = Color(0xFF22BB44);
  static const Color timestampExpiredBg = Color(0xFFFF0000);

  // OAuth
  static const String grantTypeAuthCode = 'authorization_code';
  static const String grantTypeRefreshToken = 'refresh_token';
  static const String tokenTypeBearer = 'Bearer';

  // Card Status
  static const String statusValid = 'VALID';
  static const String statusExpired = 'EXPIRED';
  static const String statusVoided = 'VOIDED';

  // Image Types
  static const String imageTypeFront = 'FRONT';
  static const String imageTypeBack = 'BACK';

  // Cache Keys
  static const String cacheKeyAccessToken = 'isic_access_token';
  static const String cacheKeyRefreshToken = 'isic_refresh_token';
  static const String cacheKeyTokenExpiry = 'isic_token_expiry';
  static const String cacheKeyCardData = 'isic_card_data';
  static const String cacheKeyCardImage = 'isic_card_image';
  static const String cacheKeyVirtualIdUrl = 'isic_virtual_id_url';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Validation
  static const String cardNumberPattern = 'r^[A-Z]\d{12}[A-Z]';
  static const int cardNumberLength = 14;
}
