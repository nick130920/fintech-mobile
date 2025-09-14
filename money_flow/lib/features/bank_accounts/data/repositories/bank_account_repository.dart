import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/bank_account_model.dart';

class BankAccountRepository {
  BankAccountRepository();

  // Obtener todas las cuentas bancarias del usuario
  Future<List<BankAccountModel>> getBankAccounts({bool activeOnly = false}) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      String endpoint = '/bank-accounts';
      if (activeOnly) {
        endpoint += '?active_only=true';
      }
      final response = await ApiService.get(endpoint, token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BankAccountModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bank accounts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank accounts: $e');
    }
  }

  // Obtener una cuenta bancaria por ID
  Future<BankAccountModel> getBankAccount(int id) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.get('/bank-accounts/$id', token: token);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BankAccountModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Bank account not found');
      } else {
        throw Exception('Failed to load bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank account: $e');
    }
  }

  // Crear nueva cuenta bancaria
  Future<BankAccountModel> createBankAccount(CreateBankAccountRequest request) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.post('/bank-accounts', request.toJson(), token: token);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return BankAccountModel.fromJson(data);
      } else if (response.statusCode == 409) {
        throw Exception('Bank account with this number mask already exists');
      } else if (response.statusCode == 307) {
        // Redirect automático - reintenta sin barra final
        final redirectResponse = await ApiService.post('/bank-accounts', request.toJson(), token: token);
        if (redirectResponse.statusCode == 201 || redirectResponse.statusCode == 200) {
          final data = json.decode(redirectResponse.body);
          return BankAccountModel.fromJson(data);
        }
        throw Exception('Failed to create bank account after redirect: ${redirectResponse.statusCode}');
      } else {
        throw Exception('Failed to create bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating bank account: $e');
    }
  }

  // Actualizar cuenta bancaria
  Future<BankAccountModel> updateBankAccount(int id, UpdateBankAccountRequest request) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.put('/bank-accounts/$id', request.toJson(), token: token);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BankAccountModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Bank account not found');
      } else {
        throw Exception('Failed to update bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating bank account: $e');
    }
  }

  // Eliminar cuenta bancaria
  Future<void> deleteBankAccount(int id) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.delete('/bank-accounts/$id', token: token);

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Bank account not found');
        } else {
          throw Exception('Failed to delete bank account: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error deleting bank account: $e');
    }
  }

  // Cambiar estado activo de cuenta bancaria
  Future<void> setActiveStatus(int id, bool isActive) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      // Usar PUT ya que no hay método patch
      final response = await ApiService.put('/bank-accounts/$id/active', {'is_active': isActive}, token: token);

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Bank account not found');
        } else {
          throw Exception('Failed to update active status: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error updating active status: $e');
    }
  }

  // Actualizar balance de cuenta bancaria
  Future<void> updateBalance(int id, double balance) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      // Usar PUT ya que no hay método patch
      final response = await ApiService.put('/bank-accounts/$id/balance', {'balance': balance}, token: token);

      if (response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Bank account not found');
        } else {
          throw Exception('Failed to update balance: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error updating balance: $e');
    }
  }

  // Obtener resumen de cuentas bancarias
  Future<List<BankAccountSummaryModel>> getBankAccountSummary() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.get('/bank-accounts/summary', token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BankAccountSummaryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bank account summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank account summary: $e');
    }
  }

  // Obtener cuentas bancarias por tipo
  Future<List<BankAccountModel>> getBankAccountsByType(BankAccountType type) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) {
        throw Exception('Token de autenticación no encontrado');
      }

      final response = await ApiService.get('/bank-accounts/type/${type.name}', token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => BankAccountModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bank accounts by type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank accounts by type: $e');
    }
  }
}
