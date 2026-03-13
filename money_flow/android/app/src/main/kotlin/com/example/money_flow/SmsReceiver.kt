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
                if (messages.isNullOrEmpty()) return

                // Group parts by sender and concatenate — handles multi-part SMS
                val grouped = mutableMapOf<String, StringBuilder>()
                for (sms in messages) {
                    val sender = sms.displayOriginatingAddress ?: "Unknown"
                    grouped.getOrPut(sender) { StringBuilder() }.append(sms.messageBody ?: "")
                }

                for ((sender, bodyBuilder) in grouped) {
                    val fullBody = bodyBuilder.toString()
                    Log.d(TAG, "SMS received from: $sender (${fullBody.length} chars)")

                    val processIntent = Intent("PROCESS_BANK_NOTIFICATION").apply {
                        putExtra("title", sender)
                        putExtra("body", fullBody)
                        putExtra("packageName", sender)
                        setPackage(context.packageName)
                    }
                    context.sendBroadcast(processIntent)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing SMS", e)
            }
        }
    }
}

