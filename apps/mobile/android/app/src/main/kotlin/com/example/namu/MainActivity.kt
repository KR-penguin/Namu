package com.example.namu

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    private var storageChannel: MethodChannel? = null
    private var timeZoneChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        storageChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STORAGE_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method != ROOT_METHOD) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                try {
                    val root = applicationContext.noBackupFilesDir
                    if (!root.exists() && !root.mkdirs()) {
                        result.error(
                            "storage_unavailable",
                            "Could not prepare app storage.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    result.success(root.canonicalPath)
                } catch (_: Exception) {
                    result.error(
                        "storage_unavailable",
                        "Could not prepare app storage.",
                        null,
                    )
                }
            }
        }

        timeZoneChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TIME_ZONE_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method != TIME_ZONE_ID_METHOD) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                try {
                    result.success(TimeZone.getDefault().id)
                } catch (_: Exception) {
                    result.error(
                        "time_zone_unavailable",
                        "Could not resolve the system time zone.",
                        null,
                    )
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        storageChannel?.setMethodCallHandler(null)
        storageChannel = null
        timeZoneChannel?.setMethodCallHandler(null)
        timeZoneChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private companion object {
        const val STORAGE_CHANNEL = "namu/storage"
        const val ROOT_METHOD = "getRootPath"
        const val TIME_ZONE_CHANNEL = "namu/time_zone"
        const val TIME_ZONE_ID_METHOD = "getTimeZoneId"
    }
}
