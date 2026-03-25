/// Fallo al renovar sesión por red o servidor; los tokens locales pueden seguir siendo válidos.
class TemporaryAuthFailureException implements Exception {
  TemporaryAuthFailureException(this.message);
  final String message;

  @override
  String toString() => message;
}
