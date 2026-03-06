package com.example.money_flow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {

    private val TAG = "SmsReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (messages == null) return

                for (sms in messages) {
                    val sender = sms.displayOriginatingAddress ?: "Unknown"
                    val messageBody = sms.messageBody ?: ""
                    
                    Log.d(TAG, "SMS received from: $sender")
                    
                    // Reutilizamos la acción PROCESS_BANK_NOTIFICATION que ya maneja el MainActivity
                    // Pasamos el remitente como título y nombre de paquete para que el parser lo intente identificar
                    val processIntent = Intent("PROCESS_BANK_NOTIFICATION").apply {
                        putExtra("title", sender)
                        putExtra("body", messageBody)
                        putExtra("packageName", sender)
                        setPackage(context.packageName) // Restringir al propio paquete por seguridad
                    }
                    
                    context.sendBroadcast(processIntent)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing SMS", e)
            }
        }
    }
}

