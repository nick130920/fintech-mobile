package com.example.money_flow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "notification_listener"
    private val TAG = "MainActivity"
    private var methodChannel: MethodChannel? = null
    
    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == "PROCESS_BANK_NOTIFICATION") {
                val title = intent.getStringExtra("title") ?: ""
                val body = intent.getStringExtra("body") ?: ""
                val packageName = intent.getStringExtra("packageName") ?: ""
                
                Log.d(TAG, "Received bank notification broadcast")
                
                // Enviar a Flutter
                methodChannel?.invokeMethod("onNotificationReceived", mapOf(
                    "title" to title,
                    "body" to body,
                    "packageName" to packageName
                ))
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkNotificationPermission" -> {
                    // Verificar si tenemos permiso de notificaciones
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        Log.d(TAG, "Flutter engine configured with notification channel")
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Registrar el receiver para notificaciones
        val filter = IntentFilter("PROCESS_BANK_NOTIFICATION")
        registerReceiver(notificationReceiver, filter)
        
        Log.d(TAG, "MainActivity created and receiver registered")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(notificationReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver", e)
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        if (intent.action == "PROCESS_BANK_NOTIFICATION") {
            val title = intent.getStringExtra("title") ?: ""
            val body = intent.getStringExtra("body") ?: ""
            val packageName = intent.getStringExtra("packageName") ?: ""
            
            Log.d(TAG, "Received bank notification via new intent")
            
            // Enviar a Flutter
            methodChannel?.invokeMethod("onNotificationReceived", mapOf(
                "title" to title,
                "body" to body,
                "packageName" to packageName
            ))
        }
    }
}
