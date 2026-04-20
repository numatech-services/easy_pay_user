import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viserpay/core/utils/isic_constants.dart';
import 'package:viserpay/data/model/isic/isic_card_model.dart';

class IsicCacheService extends GetxService {
  SharedPreferences? _prefs;

  /// Initialisation manuelle
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Cache les données de la carte
  Future<void> cacheCardData(IsicCardModel cardData) async {
    if (_prefs == null) throw Exception('CacheService non initialisé');

    final jsonString = json.encode(cardData.toJson());
    await _prefs!.setString(IsicConstants.cacheKeyCardData, jsonString);
    await _prefs!.setString(
      '${IsicConstants.cacheKeyCardData}_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  /// Récupère les données en cache
  Future<IsicCardModel?> getCachedCardData() async {
    if (_prefs == null) return null;

    try {
      // Vérifier si le cache n'est pas trop vieux (24h)
      final timestamp =
          _prefs!.getString('${IsicConstants.cacheKeyCardData}_timestamp');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        if (DateTime.now().difference(cacheTime).inHours > 24) {
          return null;
        }
      }

      final jsonString = _prefs!.getString(IsicConstants.cacheKeyCardData);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return IsicCardModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      print('Erreur lecture cache: $e');
      return null;
    }
  }

  /// Cache l'URL du virtual ID
  Future<void> cacheVirtualIdUrl(String url) async {
    if (_prefs == null) return;
    await _prefs!.setString(IsicConstants.cacheKeyVirtualIdUrl, url);
  }

  /// Récupère l'URL du virtual ID en cache
  Future<String?> getVirtualIdUrl() async {
    if (_prefs == null) return null;
    return _prefs!.getString(IsicConstants.cacheKeyVirtualIdUrl);
  }

  /// Sauvegarde une image de carte localement
  Future<String> saveCardImage(List<int> imageBytes, String imageUrl) async {
    if (_prefs == null) throw Exception('CacheService non initialisé');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/isic_cards';

      // Créer le dossier s'il n'existe pas
      final folder = Directory(imagePath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      // Générer un nom de fichier unique
      final fileName = imageUrl.hashCode.toString();
      final extension = imageUrl.contains('.png') ? 'png' : 'jpg';
      final file = File('$imagePath/$fileName.$extension');

      // Écrire les bytes
      await file.writeAsBytes(imageBytes);

      // Sauvegarder le chemin en cache
      await _prefs!
          .setString('${IsicConstants.cacheKeyCardImage}_$fileName', file.path);

      return file.path;
    } catch (e) {
      throw Exception('Erreur sauvegarde image: $e');
    }
  }

  /// Récupère le chemin d'une image en cache
  Future<String?> getCachedImagePath(String imageUrl) async {
    if (_prefs == null) return null;

    final fileName = imageUrl.hashCode.toString();
    final path =
        _prefs!.getString('${IsicConstants.cacheKeyCardImage}_$fileName');

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        return path;
      }
    }
    return null;
  }

  /// Vide le cache des cartes
  Future<void> clearCardCache() async {
    if (_prefs == null) return;

    await _prefs!.remove(IsicConstants.cacheKeyCardData);
    await _prefs!.remove('${IsicConstants.cacheKeyCardData}_timestamp');
    await _prefs!.remove(IsicConstants.cacheKeyVirtualIdUrl);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/isic_cards';
      final folder = Directory(imagePath);

      if (await folder.exists()) {
        await folder.delete(recursive: true);
      }
    } catch (e) {
      print('Erreur suppression cache images: $e');
    }
  }

  /// Vide tout le cache ISIC
  Future<void> clearAllCache() async {
    if (_prefs == null) return;

    await clearCardCache();
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith('isic_')) {
        await _prefs!.remove(key);
      }
    }
  }
}
