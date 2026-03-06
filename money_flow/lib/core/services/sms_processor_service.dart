import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';

import '../../features/bank_accounts/data/models/bank_notification_pattern_model.dart';
import '../../features/bank_accounts/data/repositories/bank_notification_pattern_repository.dart';
import 'sms_listener_service.dart';

/// Result of processing an SMS with AI
class SmsProcessingResult {
  final bool success;
  final bool transactionCreated;
  final int? transactionId;
  final double? amount;
  final String? description;
  final String? merchant;
  final double confidence;
  final String? error;
  final String rawMessage;
  final DateTime processedAt;

  SmsProcessingResult({
    required this.success,
    required this.transactionCreated,
    this.transactionId,
    this.amount,
    this.description,
    this.merchant,
    required this.confidence,
    this.error,
    required this.rawMessage,
    DateTime? processedAt,
  }) : processedAt = processedAt ?? DateTime.now();

  factory SmsProcessingResult.fromProcessedNotification(
    ProcessedNotificationModel model,
    String rawMessage,
  ) {
    return SmsProcessingResult(
      success: model.success,
      transactionCreated: model.transactionCreated,
      transactionId: null, // Not returned from this endpoint
      amount: model.extractedData?.amount,
      description: model.extractedData?.description,
      merchant: model.extractedData?.merchant,
      confidence: model.confidence ?? 0.0,
      rawMessage: rawMessage,
    );
  }

  factory SmsProcessingResult.error(String message, String rawMessage) {
    return SmsProcessingResult(
      success: false,
      transactionCreated: false,
      confidence: 0,
      error: message,
      rawMessage: rawMessage,
    );
  }
}

/// Callback when an SMS is processed
typedef OnSmsProcessedCallback = void Function(SmsProcessingResult result);

/// Service that combines SMS listening with AI processing.
/// This is the main entry point for automatic SMS transaction detection.
class SmsProcessorService {
  static final SmsProcessorService _instance = SmsProcessorService._internal();
  factory SmsProcessorService() => _instance;
  SmsProcessorService._internal();

  final SmsListenerService _listenerService = SmsListenerService();
  final BankNotificationPatternRepository _repository = BankNotificationPatternRepository();

  bool _isProcessing = false;
  OnSmsProcessedCallback? _onSmsProcessed;
  
  // Queue for SMS that need processing
  final List<SmsMessage> _processingQueue = [];
  
  // List of recent results
  final List<SmsProcessingResult> _recentResults = [];
  List<SmsProcessingResult> get recentResults => List.unmodifiable(_recentResults);

  /// Whether the service is currently active
  bool get isActive => _listenerService.isListening;

  /// Start automatic SMS processing
  /// 
  /// [onSmsProcessed] - Optional callback when an SMS is processed
  Future<bool> start({OnSmsProcessedCallback? onSmsProcessed}) async {
    _onSmsProcessed = onSmsProcessed;
    
    final started = await _listenerService.startListening(_handleIncomingSms);
    
    if (started) {
      debugPrint('SMS Processor Service started');
    }
    
    return started;
  }

  /// Stop automatic SMS processing
  void stop() {
    _listenerService.stopListening();
    _onSmsProcessed = null;
    debugPrint('SMS Processor Service stopped');
  }

  /// Handle incoming SMS
  void _handleIncomingSms(SmsMessage message) {
    // Add to queue
    _processingQueue.add(message);
    
    // Process queue
    _processQueue();
  }

  /// Process the SMS queue
  Future<void> _processQueue() async {
    if (_isProcessing || _processingQueue.isEmpty) return;
    
    _isProcessing = true;
    
    while (_processingQueue.isNotEmpty) {
      final message = _processingQueue.removeAt(0);
      await _processMessage(message);
    }
    
    _isProcessing = false;
  }

  /// Process a single SMS message with AI
  Future<void> _processMessage(SmsMessage message) async {
    final body = message.body;
    if (body == null || body.isEmpty) return;

    debugPrint('Processing SMS from: ${message.address}');
    
    try {
      // Call the AI endpoint
      final result = await _repository.processSMSWithAI(body);
      
      final processingResult = SmsProcessingResult.fromProcessedNotification(
        result,
        body,
      );
      
      // Add to recent results (keep last 50)
      _recentResults.insert(0, processingResult);
      if (_recentResults.length > 50) {
        _recentResults.removeLast();
      }
      
      // Notify callback
      _onSmsProcessed?.call(processingResult);
      
      debugPrint('SMS processed: success=${result.success}, confidence=${result.confidence}');
      
    } catch (e) {
      debugPrint('Error processing SMS: $e');
      
      final errorResult = SmsProcessingResult.error(e.toString(), body);
      _recentResults.insert(0, errorResult);
      _onSmsProcessed?.call(errorResult);
    }
  }

  /// Manually process an SMS message
  Future<SmsProcessingResult> processManually(String message) async {
    try {
      final result = await _repository.processSMSWithAI(message);
      
      final processingResult = SmsProcessingResult.fromProcessedNotification(
        result,
        message,
      );
      
      _recentResults.insert(0, processingResult);
      if (_recentResults.length > 50) {
        _recentResults.removeLast();
      }
      
      return processingResult;
      
    } catch (e) {
      final errorResult = SmsProcessingResult.error(e.toString(), message);
      _recentResults.insert(0, errorResult);
      return errorResult;
    }
  }

  /// Clear recent results
  void clearRecentResults() {
    _recentResults.clear();
  }
}
