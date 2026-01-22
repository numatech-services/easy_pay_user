import 'package:flutter/services.dart';

class ScreenshotBlocker {
  static const MethodChannel _channel = MethodChannel('screenshot_blocker');

  /// Active le blocage de screenshots (Android uniquement)
  static Future<void> enableScreenshotBlock() async {
    try {
      await _channel.invokeMethod('enableScreenshotBlock');
    } catch (e) {
      print('Erreur activation blocage screenshots: $e');
    }
  }

  /// Désactive le blocage de screenshots
  static Future<void> disableScreenshotBlock() async {
    try {
      await _channel.invokeMethod('disableScreenshotBlock');
    } catch (e) {
      print('Erreur désactivation blocage screenshots: $e');
    }
  }
}
