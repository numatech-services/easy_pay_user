import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart';
import 'package:viserpay/core/utils/isic_constants.dart';
import 'package:viserpay/data/services/isic_cache_service.dart';
import 'package:viserpay/data/services/isic_token_manager.dart';

class IsicAuthService extends GetxService {
  late final Dio _dio;
  late final IsicTokenManager _tokenManager;

  IsicAuthService() {
    _tokenManager = Get.find<IsicTokenManager>();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: IsicConstants.amUrl,
      connectTimeout: IsicConstants.connectTimeout,
      receiveTimeout: IsicConstants.receiveTimeout,
    ));
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await _tokenManager.getAccessToken();
    if (token == null) return false;

    final isValid = await _tokenManager.isTokenValid();
    if (!isValid) {
      return await _tokenManager.refreshAccessToken();
    }

    return true;
  }

  /// Autorise une carte avec numéro et nom
  Future<String> authorizeCard({
    required String clientId,
    required String cardNumber,
    String? personName,
    String? dateOfBirth,
  }) async {
    try {
      if (personName == null && dateOfBirth == null) {
        throw Exception('Le nom ou la date de naissance est requis');
      }

      final formData = FormData.fromMap({
        'client_id': clientId,
        'isic_number': cardNumber,
        if (personName != null) 'person_name': personName,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      });

      final response = await _dio.post(
        IsicConstants.authorizationEndpoint,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final code = response.data['code'];
        final error = response.data['error'];
        final errorDescription = response.data['error_description'];

        if (error != null) {
          throw Exception(errorDescription ?? error);
        }

        if (code == null) {
          throw Exception('Code d\'autorisation non reçu');
        }

        return code as String;
      } else {
        throw Exception('Erreur d\'autorisation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errorDesc = e.response?.data['error_description'];
        throw Exception(errorDesc ?? 'Erreur lors de l\'autorisation');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Échange le code d'autorisation contre des tokens
  Future<bool> exchangeCodeForTokens({
    required String code,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) async {
    try {
      final formData = FormData.fromMap({
        'grant_type': IsicConstants.grantTypeAuthCode,
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
      });

      final response = await _dio.post(
        IsicConstants.tokenEndpoint,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'] as String?;
        final refreshToken = response.data['refresh_token'] as String?;
        final expiresIn = response.data['expires_in'] as int?;

        if (accessToken == null || refreshToken == null) {
          throw Exception('Tokens non reçus');
        }

        await _tokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn ?? 3600,
        );

        return true;
      } else {
        throw Exception('Erreur d\'échange de token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erreur lors de l\'échange du code: ${e.message}');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _tokenManager.clearTokens();
    final cacheService = Get.find<IsicCacheService>();
    await cacheService.clearAllCache();
  }
}
