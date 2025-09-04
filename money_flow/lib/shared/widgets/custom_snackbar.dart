import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: _cleanErrorMessage(message),
      type: SnackBarType.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      type: SnackBarType.success,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      type: SnackBarType.warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(
      context: context,
      message: message,
      type: SnackBarType.info,
    );
  }

  static void _showCustomSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    
    switch (type) {
      case SnackBarType.error:
        backgroundColor = isDark ? const Color(0xFF2D1B1B) : const Color(0xFFFEF2F2);
        iconColor = const Color(0xFFEF4444);
        icon = Icons.error_outline;
        break;
      case SnackBarType.success:
        backgroundColor = isDark ? const Color(0xFF1B2D1B) : const Color(0xFFF0FDF4);
        iconColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = isDark ? const Color(0xFF2D2A1B) : const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = isDark ? const Color(0xFF1B252D) : const Color(0xFFF0F9FF);
        iconColor = const Color(0xFF3B82F6);
        icon = Icons.info_outline;
        break;
    }

    // Crear overlay entry
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            overlayEntry.remove();
                          },
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                            size: 18,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Insertar en el overlay
    Overlay.of(context).insert(overlayEntry);

    // Remover automáticamente después de la duración
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static String _cleanErrorMessage(String message) {
    // Remover múltiples "Exception:" al inicio
    String cleaned = message;
    
    // Remover "Exception: " repetidos al inicio
    while (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring(11); // Remover "Exception: "
    }
    
    // Remover "Error: " al inicio si existe
    if (cleaned.startsWith('Error: ')) {
      cleaned = cleaned.substring(7);
    }
    
    // Capitalizar la primera letra
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    
    return cleaned.isNotEmpty ? cleaned : 'Ha ocurrido un error';
  }
}

enum SnackBarType {
  error,
  success,
  warning,
  info,
}
