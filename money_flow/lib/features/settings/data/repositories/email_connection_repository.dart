import 'dart:convert';

import 'package:money_flow/core/services/api_service.dart';
import 'package:money_flow/core/services/storage_service.dart';

/// Estado de la conexión Gmail (API `/email-connections`).
class EmailConnectionStatusDto {
  final bool connected;
  final String? provider;
  final String? emailAddress;
  final String? lastSyncedAt;

  const EmailConnectionStatusDto({
    required this.connected,
    this.provider,
    this.emailAddress,
    this.lastSyncedAt,
  });

  factory EmailConnectionStatusDto.fromJson(Map<String, dynamic> json) {
    final last = json['last_synced_at'];
    String? lastStr;
    if (last is String) {
      lastStr = last;
    } else if (last != null) {
      lastStr = last.toString();
    }
    return EmailConnectionStatusDto(
      connected: json['connected'] == true,
      provider: json['provider'] as String?,
      emailAddress: json['email_address'] as String?,
      lastSyncedAt: lastStr,
    );
  }
}

/// Repositorio para vincular Gmail vía OAuth (backend).
class EmailConnectionRepository {
  /// GET `/email-connections/gmail/authorize` → `{ auth_url, state }`.
  static Future<String> fetchGmailAuthUrl() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('No hay sesión');
    }
    final res = await ApiService.get(
      '/email-connections/gmail/authorize',
      token: token,
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo iniciar Gmail: ${res.statusCode}');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    final url = map['auth_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Respuesta sin auth_url');
    }
    return url;
  }

  static Future<EmailConnectionStatusDto> fetchStatus() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('No hay sesión');
    }
    final res = await ApiService.get('/email-connections', token: token);
    if (res.statusCode != 200) {
      throw Exception('Error estado correo: ${res.statusCode}');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    return EmailConnectionStatusDto.fromJson(map);
  }

  static Future<void> disconnectGmail() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('No hay sesión');
    }
    final res = await ApiService.delete('/email-connections/gmail', token: token);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Error al desconectar: ${res.statusCode}');
    }
  }

  /// POST sync; devuelve cuerpo decodificado o lanza.
  static Future<Map<String, dynamic>> syncGmail() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      throw Exception('No hay sesión');
    }
    final res = await ApiService.post(
      '/email-connections/gmail/sync',
      {},
      token: token,
      timeout: const Duration(minutes: 5),
    );
    if (res.statusCode != 200) {
      throw Exception('Error sync: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }
}
