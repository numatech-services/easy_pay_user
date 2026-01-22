package org.campusniger.easypay

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "screenshot_blocker"

    // --- CONFIGURATION POS OBLIGATOIRE ---
    // Ceci force Flutter à utiliser une vue "Surface" opaque.
    // C'est la configuration la plus performante pour les appareils à faible GPU (POS).
    override fun getRenderMode(): RenderMode {
        return RenderMode.surface
    }

    override fun getTransparencyMode(): TransparencyMode {
        return TransparencyMode.opaque
    }
    // -------------------------------------

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableScreenshotBlock" -> {
                    // ATTENTION : Sur certains POS, cette ligne fait crasher l'app au démarrage.
                    // Je l'ai commentée pour le test. Si l'app s'ouvre, c'est que c'était le problème.
                    
                    /* 
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    ) 
                    */
                    result.success(null)
                }
                "disableScreenshotBlock" -> {
                    // window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}