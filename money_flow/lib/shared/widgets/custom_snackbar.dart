import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final descriptor = _descriptorFor(type, scheme);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + AppSpacing.step4,
        left: AppSpacing.step4,
        right: AppSpacing.step4,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: AppMotion.snackbarEnter,
            curve: AppMotion.easeOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.step4,
                      vertical: AppSpacing.step3,
                    ),
                    decoration: BoxDecoration(
                      color: descriptor.background,
                      borderRadius: AppRadius.allBase,
                      border: Border.all(
                        color: descriptor.iconColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: AppSpacing.step2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.step2),
                          decoration: BoxDecoration(
                            color: descriptor.iconColor.withValues(alpha: 0.1),
                            borderRadius: AppRadius.allSm,
                          ),
                          child: Icon(
                            descriptor.icon,
                            color: descriptor.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.step3),
                        Expanded(
                          child: Text(
                            message,
                            style: AppTypography.bodyMd.copyWith(
                              color: scheme.onSurface,
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
                            color: scheme.onSurface.withValues(alpha: 0.6),
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

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static _SnackBarDescriptor _descriptorFor(SnackBarType type, ColorScheme scheme) {
    switch (type) {
      case SnackBarType.error:
        return _SnackBarDescriptor(
          background: AppColors.errorSoft,
          iconColor: AppColors.error,
          icon: Icons.error_outline,
        );
      case SnackBarType.success:
        return _SnackBarDescriptor(
          background: AppColors.successSoft,
          iconColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case SnackBarType.warning:
        return _SnackBarDescriptor(
          background: AppColors.warningSoft,
          iconColor: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case SnackBarType.info:
        return _SnackBarDescriptor(
          background: AppColors.infoSoft,
          iconColor: AppColors.info,
          icon: Icons.info_outline,
        );
    }
  }

  static String _cleanErrorMessage(String message) {
    String cleaned = message;
    while (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring(11);
    }
    if (cleaned.startsWith('Error: ')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    return cleaned.isNotEmpty ? cleaned : 'Ha ocurrido un error';
  }
}

class _SnackBarDescriptor {
  final Color background;
  final Color iconColor;
  final IconData icon;

  const _SnackBarDescriptor({
    required this.background,
    required this.iconColor,
    required this.icon,
  });
}

enum SnackBarType {
  error,
  success,
  warning,
  info,
}
