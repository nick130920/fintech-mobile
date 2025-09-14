import 'package:flutter/foundation.dart';

import '../../data/models/bank_notification_pattern_model.dart';
import '../../data/repositories/bank_notification_pattern_repository.dart';

class BankNotificationPatternProvider with ChangeNotifier {
  final BankNotificationPatternRepository _repository;

  BankNotificationPatternProvider({BankNotificationPatternRepository? repository})
      : _repository = repository ?? BankNotificationPatternRepository();

  // Estado
  List<BankNotificationPatternModel> _patterns = [];
  PatternStatisticsModel? _statistics;
  ProcessedNotificationModel? _lastProcessedNotification;
  BankNotificationPatternModel? _selectedPattern;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BankNotificationPatternModel> get patterns => _patterns;
  PatternStatisticsModel? get statistics => _statistics;
  ProcessedNotificationModel? get lastProcessedNotification => _lastProcessedNotification;
  BankNotificationPatternModel? get selectedPattern => _selectedPattern;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Patrones activos
  List<BankNotificationPatternModel> get activePatterns =>
      _patterns.where((pattern) => pattern.isActive).toList();

  // Patrones por canal
  List<BankNotificationPatternModel> getPatternsByChannel(NotificationChannel channel) =>
      _patterns.where((pattern) => pattern.channel == channel).toList();

  // Patrones por cuenta bancaria
  List<BankNotificationPatternModel> getPatternsByBankAccount(int bankAccountId) =>
      _patterns.where((pattern) => pattern.bankAccountId == bankAccountId).toList();

  // Patrones con alta tasa de éxito
  List<BankNotificationPatternModel> get highPerformancePatterns =>
      _patterns.where((pattern) => pattern.hasHighSuccessRate).toList();

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Cargar todos los patrones
  Future<void> loadPatterns() async {
    _setLoading(true);
    _clearError();

    try {
      _patterns = await _repository.getPatterns();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Cargar patrón específico
  Future<void> loadPattern(int id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedPattern = await _repository.getPattern(id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Cargar patrones de cuenta bancaria
  Future<void> loadBankAccountPatterns(int bankAccountId, {bool activeOnly = false}) async {
    _setLoading(true);
    _clearError();

    try {
      final bankAccountPatterns = await _repository.getBankAccountPatterns(
        bankAccountId,
        activeOnly: activeOnly,
      );
      
      // Actualizar patrones de la cuenta específica
      _patterns.removeWhere((pattern) => pattern.bankAccountId == bankAccountId);
      _patterns.addAll(bankAccountPatterns);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Crear nuevo patrón
  Future<bool> createPattern(CreateBankNotificationPatternRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final newPattern = await _repository.createPattern(request);
      _patterns.add(newPattern);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar patrón
  Future<bool> updatePattern(int id, UpdateBankNotificationPatternRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedPattern = await _repository.updatePattern(id, request);
      
      // Actualizar en la lista
      final index = _patterns.indexWhere((pattern) => pattern.id == id);
      if (index != -1) {
        _patterns[index] = updatedPattern;
      }
      
      // Actualizar patrón seleccionado si es el mismo
      if (_selectedPattern?.id == id) {
        _selectedPattern = updatedPattern;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar patrón
  Future<bool> deletePattern(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deletePattern(id);
      
      // Remover de la lista
      _patterns.removeWhere((pattern) => pattern.id == id);
      
      // Limpiar patrón seleccionado si es el mismo
      if (_selectedPattern?.id == id) {
        _selectedPattern = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar estado del patrón
  Future<bool> setPatternStatus(int id, NotificationPatternStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.setPatternStatus(id, status);
      
      // Actualizar en la lista
      final index = _patterns.indexWhere((pattern) => pattern.id == id);
      if (index != -1) {
        _patterns[index] = _patterns[index].copyWith(status: status);
      }
      
      // Actualizar patrón seleccionado si es el mismo
      if (_selectedPattern?.id == id) {
        _selectedPattern = _selectedPattern!.copyWith(status: status);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Procesar notificación
  Future<bool> processNotification(ProcessNotificationRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      _lastProcessedNotification = await _repository.processNotification(request);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar estadísticas
  Future<void> loadStatistics() async {
    _setLoading(true);
    _clearError();

    try {
      _statistics = await _repository.getPatternStatistics();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar patrón
  void selectPattern(BankNotificationPatternModel? pattern) {
    _selectedPattern = pattern;
    notifyListeners();
  }

  // Limpiar selección
  void clearSelection() {
    _selectedPattern = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _clearError();
  }

  // Limpiar última notificación procesada
  void clearLastProcessedNotification() {
    _lastProcessedNotification = null;
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refresh() async {
    await Future.wait([
      loadPatterns(),
      loadStatistics(),
    ]);
  }

  // Activar patrón
  Future<bool> activatePattern(int id) async {
    return await setPatternStatus(id, NotificationPatternStatus.active);
  }

  // Desactivar patrón
  Future<bool> deactivatePattern(int id) async {
    return await setPatternStatus(id, NotificationPatternStatus.inactive);
  }

  // Poner patrón en modo aprendizaje
  Future<bool> setPatternLearning(int id) async {
    return await setPatternStatus(id, NotificationPatternStatus.learning);
  }

  // Duplicar patrón (crear uno nuevo basado en uno existente)
  Future<bool> duplicatePattern(BankNotificationPatternModel pattern) async {
    final request = CreateBankNotificationPatternRequest(
      bankAccountId: pattern.bankAccountId,
      name: '${pattern.name} (Copia)',
      description: pattern.description,
      channel: pattern.channel,
      messagePattern: pattern.messagePattern,
      exampleMessage: pattern.exampleMessage,
      keywordsTrigger: pattern.keywordsTrigger,
      keywordsExclude: pattern.keywordsExclude,
      amountRegex: pattern.amountRegex,
      dateRegex: pattern.dateRegex,
      descriptionRegex: pattern.descriptionRegex,
      merchantRegex: pattern.merchantRegex,
      requiresValidation: pattern.requiresValidation,
      confidenceThreshold: pattern.confidenceThreshold,
      autoApprove: pattern.autoApprove,
      priority: pattern.priority + 10, // Menor prioridad que el original
      isDefault: false, // La copia nunca es por defecto
      tags: pattern.tags,
      metadata: pattern.metadata,
    );

    return await createPattern(request);
  }
}
