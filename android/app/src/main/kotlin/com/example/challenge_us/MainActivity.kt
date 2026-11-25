package com.example.challenge_us

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "larecocha/updates"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "versionCode" -> {
                    val info = packageManager.getPackageInfo(packageName, 0)
                    val version = if (Build.VERSION.SDK_INT >= 28) {
                        info.longVersionCode
                    } else {
                        @Suppress("DEPRECATION")
                        info.versionCode.toLong()
                    }
                    result.success(version)
                }

                "downloadUpdate" -> {
                    try {
                        val url = call.argument<String>("url")
                            ?: throw IllegalArgumentException("URL invalida")

                        val uri = Uri.parse(url)

                        require(
                            uri.scheme == "https" &&
                            uri.host == "github.com" &&
                            uri.path.orEmpty().startsWith(
                                "/joserico3563-oss/challenge_us/releases/download/"
                            )
                        )

                        val version = call.argument<Int>("version")
                            ?: throw IllegalArgumentException("Version invalida")

                        require(version > 0)

                        val request = DownloadManager.Request(uri)
                            .setTitle("La Recocha")
                            .setDescription("Descargando nueva version")
                            .setMimeType("application/vnd.android.package-archive")
                            .setNotificationVisibility(
                                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
                            )
                            .setDestinationInExternalPublicDir(
                                Environment.DIRECTORY_DOWNLOADS,
                                "La_Recocha_v$version.apk"
                            )

                        val manager = getSystemService(
                            Context.DOWNLOAD_SERVICE
                        ) as DownloadManager

                        manager.enqueue(request)
                        result.success(true)

                    } catch (e: Exception) {
                        result.error("DOWNLOAD_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
