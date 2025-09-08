import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../providers/dashboard_provider.dart';

class SavingsProgressWidget extends StatelessWidget {
  const SavingsProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CurrencyProvider, DashboardProvider>(
      builder: (context, currencyProvider, dashboardProvider, child) {
        // Datos simulados para ahorros
        final savingsGoal = 500000.0; // Meta de ahorro mensual
        final currentSavings = 720000.0; // Ahorro actual del mes
        final progress = currentSavings / savingsGoal;
        final isOnTrack = progress >= 1.0;
        
        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableHoverEffect: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso de Ahorros',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isOnTrack ? Colors.green : Colors.orange).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnTrack ? Icons.trending_up : Icons.schedule,
                            size: 14,
                            color: isOnTrack ? Colors.green[600] : Colors.orange[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnTrack ? 'Meta alcanzada' : 'En camino',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOnTrack ? Colors.green[600] : Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: currencyProvider.formatAmount(currentSavings),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${currencyProvider.formatAmount(savingsGoal)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Barra de progreso
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOnTrack ? Colors.green[600]! : Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% de tu meta mensual',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
