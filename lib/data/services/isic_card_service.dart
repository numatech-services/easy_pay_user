import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:viserpay/core/utils/isic_constants.dart';
import 'package:viserpay/data/model/isic/isic_card_model.dart';
import 'package:viserpay/data/services/isic_cache_service.dart';
import 'package:viserpay/data/services/isic_token_manager.dart';

class IsicCardService extends GetxService {
  late final Dio _dio;
  late final IsicTokenManager _tokenManager;
  late final IsicCacheService _cacheService;

  @override
  void onInit() {
    super.onInit();
    _tokenManager = Get.find<IsicTokenManager>();
    _cacheService = Get.find<IsicCacheService>();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: IsicConstants.apiUrl,
      connectTimeout: IsicConstants.connectTimeout,
      receiveTimeout: IsicConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Intercepteur pour ajouter le token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Si erreur 401, essayer de rafraîchir le token
        if (error.response?.statusCode == 401) {
          final refreshed = await _tokenManager.refreshAccessToken();
          if (refreshed) {
            // Réessayer la requête
            final token = await _tokenManager.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// Récupère les informations de la carte virtuelle
  Future<IsicCardModel> getVirtualCard() async {
    try {
      // Vérifier le cache d'abord
      final cachedData = await _cacheService.getCachedCardData();
      if (cachedData != null) {
        return cachedData;
      }

      // Récupérer l'URL du virtual ID
      final virtualIdUrl = await _getVirtualIdUrl();

      // Récupérer les données de la carte
      final response = await _dio.get(virtualIdUrl);

      if (response.statusCode == 200) {
        final cardData = IsicCardModel.fromJson(response.data);

        // Mettre en cache
        await _cacheService.cacheCardData(cardData);

        return cardData;
      } else {
        throw Exception(
            'Erreur lors de la récupération de la carte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Carte non trouvée');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé à la carte');
      } else if (e.response?.statusCode == 410) {
        throw Exception('Cette carte a été annulée');
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère l'URL du virtual ID depuis le profil
  Future<String> _getVirtualIdUrl() async {
    // Vérifier le cache
    final cached = await _cacheService.getVirtualIdUrl();
    if (cached != null) return cached;

    try {
      final response = await _dio.post(
        '${IsicConstants.amUrl}${IsicConstants.profileEndpoint}',
      );

      if (response.statusCode == 200) {
        final virtualIdUrl = response.data['virtualIdUrl'] as String?;
        if (virtualIdUrl == null) {
          throw Exception('virtualIdUrl non trouvé dans la réponse');
        }

        // Mettre en cache
        await _cacheService.cacheVirtualIdUrl(virtualIdUrl);

        return virtualIdUrl;
      } else {
        throw Exception('Erreur profil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  /// Télécharge l'image de la carte
  Future<String?> downloadCardImage(String imageUrl) async {
    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'image/*'},
        ),
      );

      if (response.statusCode == 200) {
        // Sauvegarder l'image localement
        final imagePath = await _cacheService.saveCardImage(
          response.data as List<int>,
          imageUrl,
        );
        return imagePath;
      }
      return null;
    } catch (e) {
      print('Erreur téléchargement image: $e');
      return null;
    }
  }

  /// Upload une photo pour la carte
  Future<bool> uploadPhoto(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        IsicConstants.photoEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Photo déjà uploadée ou format invalide');
      }
      throw Exception('Erreur upload: ${e.message}');
    }
  }

  /// Rafraîchit les données de la carte
  Future<IsicCardModel> refreshCardData() async {
    // Vider le cache
    await _cacheService.clearCardCache();
    // Récupérer les nouvelles données
    return await getVirtualCard();
  }
}
