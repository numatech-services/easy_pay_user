import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart';
import 'package:viserpay/core/utils/isic_constants.dart';
import 'package:viserpay/data/services/isic_token_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
class IsicTokenManager extends GetxService {
  SharedPreferences? _prefs;
  Dio? _dio;

  /// Initialisation manuelle
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: IsicConstants.amUrl,
      connectTimeout: IsicConstants.connectTimeout,
      receiveTimeout: IsicConstants.receiveTimeout,
    ));
  }

  /// Sauvegarde les tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    if (_prefs == null) throw Exception('TokenManager non initialisé');

    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));

    await _prefs!.setString(IsicConstants.cacheKeyAccessToken, accessToken);
    await _prefs!.setString(IsicConstants.cacheKeyRefreshToken, refreshToken);
    await _prefs!.setString(
      IsicConstants.cacheKeyTokenExpiry,
      expiryTime.toIso8601String(),
    );
  }

  /// Récupère l'access token
  Future<String?> getAccessToken() async {
    if (_prefs == null) return null;
    return _prefs!.getString(IsicConstants.cacheKeyAccessToken);
  }

  /// Récupère le refresh token
  Future<String?> getRefreshToken() async {
    if (_prefs == null) return null;
    return _prefs!.getString(IsicConstants.cacheKeyRefreshToken);
  }

  /// Vérifie si le token est encore valide
  Future<bool> isTokenValid() async {
    if (_prefs == null) return false;

    final expiryString = _prefs!.getString(IsicConstants.cacheKeyTokenExpiry);
    if (expiryString == null) return false;

    try {
      final expiryTime = DateTime.parse(expiryString);
      // Considérer invalide si expire dans moins de 5 minutes
      return expiryTime.isAfter(DateTime.now().add(const Duration(minutes: 5)));
    } catch (e) {
      return false;
    }
  }

  /// Rafraîchit l'access token
  Future<bool> refreshAccessToken() async {
    if (_prefs == null || _dio == null) return false;

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      // Récupérer client_id et client_secret depuis la config
      final clientId = _prefs!.getString('isic_client_id');
      final clientSecret = _prefs!.getString('isic_client_secret');

      if (clientId == null || clientSecret == null) {
        print('Configuration cliente manquante');
        return false;
      }

      final formData = FormData.fromMap({
        'grant_type': IsicConstants.grantTypeRefreshToken,
        'refresh_token': refreshToken,
        'client_id': clientId,
        'client_secret': clientSecret,
      });

      final response = await _dio!.post(
        IsicConstants.tokenEndpoint,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;
        final expiresIn = response.data['expires_in'] as int?;

        if (newAccessToken != null && newRefreshToken != null) {
          await saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiresIn: expiresIn ?? 3600,
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Erreur rafraîchissement token: $e');
      return false;
    }
  }

  /// Supprime tous les tokens
  Future<void> clearTokens() async {
    if (_prefs == null) return;

    await _prefs!.remove(IsicConstants.cacheKeyAccessToken);
    await _prefs!.remove(IsicConstants.cacheKeyRefreshToken);
    await _prefs!.remove(IsicConstants.cacheKeyTokenExpiry);
  }

  /// Sauvegarde la configuration cliente
  Future<void> saveClientConfig({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) async {
    if (_prefs == null) throw Exception('TokenManager non initialisé');

    await _prefs!.setString('isic_client_id', clientId);
    await _prefs!.setString('isic_client_secret', clientSecret);
    await _prefs!.setString('isic_redirect_uri', redirectUri);
  }

  /// Récupère la config cliente
  Map<String, String?> getClientConfig() {
    if (_prefs == null) return {};

    return {
      'client_id': _prefs!.getString('isic_client_id'),
      'client_secret': _prefs!.getString('isic_client_secret'),
      'redirect_uri': _prefs!.getString('isic_redirect_uri'),
    };
  }
}
