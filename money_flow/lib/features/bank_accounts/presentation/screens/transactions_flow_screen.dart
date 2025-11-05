import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../providers/automatic_transactions_provider.dart';

class TransactionsFlowScreen extends StatefulWidget {
  const TransactionsFlowScreen({super.key});

  @override
  State<TransactionsFlowScreen> createState() => _TransactionsFlowScreenState();
}

class _TransactionsFlowScreenState extends State<TransactionsFlowScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadData();
        _hasLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    provider.loadStats();
    provider.loadPendingTransactions(refresh: true);
    provider.loadApprovedTransactions();
    provider.loadRejectedTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Flujo de Transacciones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'Resumen'),
            Tab(icon: Icon(Icons.pending_actions), text: 'Pendientes'),
            Tab(icon: Icon(Icons.check_circle), text: 'Aprobadas'),
            Tab(icon: Icon(Icons.cancel), text: 'Rechazadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildPendingTab(),
          _buildApprovedTab(),
          _buildRejectedTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        
        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFlowDiagram(context, stats),
              const SizedBox(height: 24),
              _buildProcessingMetrics(context, stats),
              const SizedBox(height: 24),
              _buildRecentActivity(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlowDiagram(BuildContext context, dynamic stats) {
    final total = stats.totalProcessed as int;
    final approved = stats.approved as int;
    final rejected = stats.rejected as int;
    final pending = stats.pending as int;

    return GlassmorphismCard(
      style: GlassStyles.dynamic,
      enableHoverEffect: true,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Flujo de Procesamiento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Diagrama visual del flujo
            _buildFlowStep(
              context,
              icon: Icons.sms,
              title: 'SMS Recibidos',
              count: total,
              color: Theme.of(context).colorScheme.primary,
              isFirst: true,
            ),
            
            _buildFlowArrow(context),
            
            _buildFlowStep(
              context,
              icon: Icons.smart_toy,
              title: 'Procesados con IA',
              count: total,
              subtitle: 'Gemini AI',
              color: Colors.purple,
            ),
            
            _buildFlowSplit(context),
            
            Row(
              children: [
                Expanded(
                  child: _buildFlowStep(
                    context,
                    icon: Icons.check_circle,
                    title: 'Aprobadas',
                    count: approved,
                    color: Colors.green[600]!,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFlowStep(
                    context,
                    icon: Icons.pending,
                    title: 'Pendientes',
                    count: pending,
                    color: Colors.orange[600]!,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFlowStep(
                    context,
                    icon: Icons.cancel,
                    title: 'Rechazadas',
                    count: rejected,
                    color: Theme.of(context).colorScheme.error,
                    compact: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    String? subtitle,
    bool isFirst = false,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: compact ? 28 : 36),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: compact ? 20 : 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(
          Icons.arrow_downward,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFlowSplit(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_downward,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_downward,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_downward,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingMetrics(BuildContext context, dynamic stats) {
    final avgConfidence = (stats.averageConfidence as num).toDouble();
    final approvalRate = stats.approvalRate as double;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.psychology,
                title: 'Confianza IA',
                value: '${(avgConfidence * 100).toStringAsFixed(1)}%',
                color: _getConfidenceColor(avgConfidence),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.check_circle_outline,
                title: 'Tasa Aprobación',
                value: '${approvalRate.toStringAsFixed(1)}%',
                color: approvalRate > 75 ? Colors.green[600]! : Colors.orange[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green[600]!;
    if (confidence >= 0.7) return Colors.blue[600]!;
    if (confidence >= 0.5) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  Widget _buildRecentActivity(BuildContext context, AutomaticTransactionsProvider provider) {
    final allTransactions = [
      ...provider.pendingTransactions,
      ...provider.approvedTransactions.take(5),
      ...provider.rejectedTransactions.take(5),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (allTransactions.isEmpty)
              Center(
                child: Text(
                  'No hay actividad reciente',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              ...allTransactions.take(10).map((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem(context, transaction),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, dynamic transaction) {
    final date = DateTime.parse(transaction.createdAt);
    final formattedDate = DateFormat('dd/MM HH:mm').format(date);
    
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (transaction.status.toString().split('.').last) {
      case 'pending':
        statusIcon = Icons.pending;
        statusColor = Colors.orange[600]!;
        statusText = 'Pendiente';
        break;
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green[600]!;
        statusText = 'Aprobada';
        break;
      case 'cancelled':
        statusIcon = Icons.cancel;
        statusColor = Theme.of(context).colorScheme.error;
        statusText = 'Rechazada';
        break;
      default:
        statusIcon = Icons.help;
        statusColor = Colors.grey;
        statusText = 'Desconocido';
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description ?? 'Sin descripción',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (transaction.aiConfidence != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${(transaction.aiConfidence * 100).toInt()}% 🤖',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getConfidenceColor(transaction.aiConfidence),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Text(
          '\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.pendingTransactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.pendingTransactions.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.check_circle,
            title: 'No hay transacciones pendientes',
            subtitle: 'Todas las transacciones han sido procesadas',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.pendingTransactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.pendingTransactions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionCard(context, transaction, 'pending'),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedTab() {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.approvedTransactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.approvedTransactions.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.approval,
            title: 'No hay transacciones aprobadas',
            subtitle: 'Las transacciones aprobadas aparecerán aquí',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.approvedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.approvedTransactions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionCard(context, transaction, 'approved'),
            );
          },
        );
      },
    );
  }

  Widget _buildRejectedTab() {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.rejectedTransactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.rejectedTransactions.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.info_outline,
            title: 'No hay transacciones rechazadas',
            subtitle: 'Las transacciones rechazadas aparecerán aquí',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.rejectedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.rejectedTransactions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionCard(context, transaction, 'rejected'),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, dynamic transaction, String type) {
    final date = DateTime.parse(transaction.transactionDate);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    Color cardColor;
    IconData cardIcon;
    
    switch (type) {
      case 'pending':
        cardColor = Colors.orange[600]!;
        cardIcon = Icons.pending_actions;
        break;
      case 'approved':
        cardColor = Colors.green[600]!;
        cardIcon = Icons.check_circle;
        break;
      case 'rejected':
        cardColor = Theme.of(context).colorScheme.error;
        cardIcon = Icons.cancel;
        break;
      default:
        cardColor = Colors.grey;
        cardIcon = Icons.help;
    }

    return GlassmorphismCard(
      style: GlassStyles.light,
      enableHoverEffect: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cardIcon, color: cardColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'Sin descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (transaction.aiConfidence != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 16,
                    color: _getConfidenceColor(transaction.aiConfidence),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Confianza IA: ${(transaction.aiConfidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getConfidenceColor(transaction.aiConfidence),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

