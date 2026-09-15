package io.github.wizsk.salah_times_v2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.widget.Toast
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    // private val CHANNELTIMEZONE = "app.timezone/native"
    private val CHANNELTOAST = "app/toast"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNELTIMEZONE)
        // .setMethodCallHandler { call, result ->
        //     if (call.method == "getTimeZoneId") {
        //         result.success(TimeZone.getDefault().id)
        //     } else {
        //         result.notImplemented()
        //     }
        // }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNELTOAST)
            .setMethodCallHandler { call, result ->
                if (call.method == "showToast") {
                    val message = call.argument<String>("message") ?: ""
                    val short = call.argument<Boolean>("short") ?: true
                    Toast.makeText(
                        applicationContext,
                        message,
                        if (short) Toast.LENGTH_SHORT else Toast.LENGTH_LONG
                    ).show()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
