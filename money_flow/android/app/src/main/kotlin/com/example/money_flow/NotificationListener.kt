package com.example.money_flow

import android.app.Notification
import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Servicio para escuchar notificaciones del sistema en tiempo real
 * Captura notificaciones bancarias y las envía a Flutter para su procesamiento
 */
class NotificationListener : NotificationListenerService() {
    
    companion object {
        private const val TAG = "NotificationListener"
        private const val CHANNEL_NAME = "notification_listener"
        
        // Paquetes de bancos colombianos que queremos monitorear
        private val BANK_PACKAGES = setOf(
            "co.com.bancolombia.personas.superapp",  // Bancolombia
            "com.nequi.MobileApp",                   // Nequi
            "com.davivienda.daviviendaapp",          // Davivienda
            "com.daviplata.daviplataapp",            // DaviPlata
            "com.grupoavalpo.bancamovil",            // Banco Popular
            "co.com.bbva.mb",                        // BBVA Colombia
            "com.grupoavalav1.bancamovil",           // AV Villas
            "co.com.bancofallabella.mobile.omc",     // Banco Falabella
            "com.bancodebogota.bancamovil",          // Banco de Bogotá
        )
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "NotificationListener service created")
    }
    
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        
        try {
            val packageName = sbn.packageName
            
            // Solo procesar notificaciones de bancos
            if (!BANK_PACKAGES.contains(packageName)) {
                return
            }
            
            Log.d(TAG, "Notification received from bank: $packageName")
            
            val notification = sbn.notification
            val extras = notification.extras
            
            // Extraer título y texto de la notificación
            val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: text
            
            if (title.isEmpty() && bigText.isEmpty()) {
                Log.d(TAG, "Notification is empty, ignoring")
                return
            }
            
            Log.d(TAG, "Notification - Title: $title, Text: $bigText")
            
            // Enviar la notificación a Flutter para procesamiento
            sendNotificationToFlutter(title, bigText, packageName)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification", e)
        }
    }
    
    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        super.onNotificationRemoved(sbn)
        Log.d(TAG, "Notification removed from: ${sbn.packageName}")
    }
    
    /**
     * Envía la notificación a Flutter para su procesamiento
     */
    private fun sendNotificationToFlutter(title: String, body: String, packageName: String) {
        try {
            // Crear un Intent para iniciar la actividad de Flutter si no está activa
            val intent = Intent(this, MainActivity::class.java).apply {
                action = "PROCESS_BANK_NOTIFICATION"
                putExtra("title", title)
                putExtra("body", body)
                putExtra("packageName", packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            
            // Enviar broadcast para que la app procese la notificación
            sendBroadcast(intent)
            
            Log.d(TAG, "Notification sent to Flutter")
        } catch (e: Exception) {
            Log.e(TAG, "Error sending notification to Flutter", e)
        }
    }
    
    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "NotificationListener connected")
    }
    
    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d(TAG, "NotificationListener disconnected")
    }
}

