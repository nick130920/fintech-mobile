import 'package:flutter/material.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'package:money_flow/features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'package:money_flow/shared/widgets/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';

class AutomaticTransactionsStatsWidget extends StatefulWidget {
  const AutomaticTransactionsStatsWidget({super.key});

  @override
  State<AutomaticTransactionsStatsWidget> createState() => _AutomaticTransactionsStatsWidgetState();
}

class _AutomaticTransactionsStatsWidgetState extends State<AutomaticTransactionsStatsWidget> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadStats();
        _hasLoaded = true;
      }
    });
  }

  void _loadStats() {
    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        
        if (stats == null) {
          return _buildLoadingState();
        }

        return GlassmorphismCard(
          style: GlassStyles.dynamic,
          enableHoverEffect: true,
          enableEntryAnimation: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, stats),
                const SizedBox(height: 20),
                _buildStatsGrid(context, stats),
                if (provider.pendingCount > 0) ...[
                  const SizedBox(height: 16),
                  _buildPendingAlert(context, provider.pendingCount),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return GlassmorphismCard(
      style: GlassStyles.medium,
      child: SizedBox(
        height: 160,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AutomaticTransactionStats stats) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transacciones Automáticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Últimos 30 días',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadStats,
          icon: Icon(
            Icons.refresh,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, AutomaticTransactionStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total',
                stats.totalAutomatic.toString(),
                Icons.receipt_long,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Aprobadas',
                stats.totalApproved.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Pendientes',
                stats.totalPending.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Confianza',
                '${(stats.averageConfidence * 100).round()}%',
                Icons.psychology,
                _getConfidenceColor(stats.averageConfidence),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildApprovalRateCard(context, stats),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRateCard(BuildContext context, AutomaticTransactionStats stats) {
    final approvalRate = stats.approvalRate;
    final percentage = (approvalRate * 100).round();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 20,
                color: _getApprovalRateColor(approvalRate),
              ),
              const SizedBox(width: 8),
              Text(
                'Tasa de Aprobación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getApprovalRateColor(approvalRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: approvalRate,
            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_getApprovalRateColor(approvalRate)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAlert(BuildContext context, int pendingCount) {
    return GlassmorphismButton(
      style: GlassButtonStyles.outline,
      onPressed: () {
        Navigator.of(context).pushNamed('/pending-transactions');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notification_important,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pendingCount transacciones pendientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Toca para revisar y aprobar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getApprovalRateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
