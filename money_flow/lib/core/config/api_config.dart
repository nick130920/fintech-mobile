/// Configuración de API Keys y secrets usando dart-define
/// 
/// Esta configuración utiliza variables de entorno inyectadas en tiempo de compilación
/// para mantener las API keys seguras y fuera del código fuente.
/// 
/// DESARROLLO LOCAL:
/// flutter run --dart-define=FREECURRENCY_API_KEY=tu_api_key_aqui
/// 
/// PRODUCCIÓN (CodeMagic):
/// Las variables se configuran en el dashboard de CodeMagic y se inyectan automáticamente
/// 
/// Para más información, ver: CURRENCY_API_SETUP.md

class ApiConfig {
  // FreeCurrencyAPI Configuration
  // La API key se inyecta desde variables de entorno usando --dart-define
  // Si no está definida, usa una cadena vacía (la app funcionará con divisa por defecto)
  static const String freeCurrencyApiKey = String.fromEnvironment(
    'FREECURRENCY_API_KEY',
    defaultValue: '',
  );
  
  // Base URLs
  static const String freeCurrencyApiBaseUrl = 'https://api.freecurrencyapi.com/v1';
  
  // Otras configuraciones API que puedas necesitar en el futuro
  // static const String anotherApiKey = String.fromEnvironment('ANOTHER_API_KEY', defaultValue: '');
  
  /// Verifica si la API key está configurada correctamente
  static bool get isFreeCurrencyApiConfigured {
    return freeCurrencyApiKey.isNotEmpty && 
           freeCurrencyApiKey.length > 20; // Las keys de freecurrencyapi son largas
  }
  
  /// Información sobre el plan actual (para referencia)
  static const Map<String, dynamic> freeCurrencyApiLimits = {
    'requests_per_month': 5000,
    'requests_per_minute': 10,
    'cache_duration_hours': 1,
  };
  
  /// Para debugging - muestra si la key está configurada (sin revelarla)
  static String get apiKeyStatus {
    if (freeCurrencyApiKey.isEmpty) {
      return 'No configurada (usando divisa por defecto)';
    }
    return 'Configurada (${freeCurrencyApiKey.substring(0, 8)}...${freeCurrencyApiKey.substring(freeCurrencyApiKey.length - 4)})';
  }
}

