package org.campusniger.easypay

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.text.TextUtils
import android.webkit.MimeTypeMap
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.io.OutputStream

class ImageGallerySaverPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "image_gallery_saver")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "saveImageToGallery" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                val quality = call.argument<Int>("quality")
                val name = call.argument<String>("name")

                val bitmap = imageBytes?.let {
                    BitmapFactory.decodeByteArray(it, 0, it.size)
                }

                result.success(saveImage(bitmap, quality, name))
            }

            "saveFileToGallery" -> {
                val path = call.argument<String>("file")
                val name = call.argument<String>("name")
                result.success(saveFile(path, name))
            }

            else -> result.notImplemented()
        }
    }

    private fun saveImage(
        bitmap: Bitmap?,
        quality: Int?,
        name: String?
    ): HashMap<String, Any?> {

        if (bitmap == null || quality == null || context == null) {
            return SaveResultModel(false, null, "Invalid parameters").toMap()
        }

        var uri: Uri? = null

        return try {
            uri = generateUri("jpg", name)
            uri?.let {
                context!!.contentResolver.openOutputStream(it)?.use { stream ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
                }
            }

            sendBroadcast(uri)
            SaveResultModel(true, uri.toString(), null).toMap()

        } catch (e: Exception) {
            SaveResultModel(false, null, e.message).toMap()
        } finally {
            bitmap.recycle()
        }
    }

    private fun saveFile(path: String?, name: String?): HashMap<String, Any?> {
        if (path == null || context == null) {
            return SaveResultModel(false, null, "Invalid parameters").toMap()
        }

        val originalFile = File(path)
        if (!originalFile.exists()) {
            return SaveResultModel(false, null, "File not found").toMap()
        }

        var uri: Uri? = null

        return try {
            uri = generateUri(originalFile.extension, name)

            uri?.let {
                context!!.contentResolver.openOutputStream(it)?.use { output ->
                    FileInputStream(originalFile).use { input ->
                        input.copyTo(output)
                    }
                }
            }

            sendBroadcast(uri)
            SaveResultModel(true, uri.toString(), null).toMap()

        } catch (e: Exception) {
            SaveResultModel(false, null, e.message).toMap()
        }
    }

    private fun generateUri(extension: String, name: String?): Uri? {
        val fileName = name ?: System.currentTimeMillis().toString()
        val mime = getMimeType(extension)

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mime)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_PICTURES
                )
            }

            context?.contentResolver?.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                values
            )
        } else {
            val dir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES
            )
            if (!dir.exists()) dir.mkdirs()
            Uri.fromFile(File(dir, "$fileName.$extension"))
        }
    }

    private fun getMimeType(ext: String): String? {
        return if (!TextUtils.isEmpty(ext)) {
            MimeTypeMap.getSingleton()
                .getMimeTypeFromExtension(ext.lowercase())
        } else null
    }

    private fun sendBroadcast(uri: Uri?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q && uri != null) {
            val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            intent.data = uri
            context?.sendBroadcast(intent)
        }
    }
}

class SaveResultModel(
    private val success: Boolean,
    private val path: String?,
    private val error: String?
) {
    fun toMap(): HashMap<String, Any?> = hashMapOf(
        "isSuccess" to success,
        "filePath" to path,
        "errorMessage" to error
    )
}
