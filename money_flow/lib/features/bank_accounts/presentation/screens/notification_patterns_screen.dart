import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/bank_notification_pattern_model.dart';
import '../providers/bank_notification_pattern_provider.dart';
import '../widgets/notification_pattern_card.dart';
import 'add_notification_pattern_screen.dart';
import 'process_notification_screen.dart';

class NotificationPatternsScreen extends StatefulWidget {
  const NotificationPatternsScreen({super.key});

  @override
  State<NotificationPatternsScreen> createState() => _NotificationPatternsScreenState();
}

class _NotificationPatternsScreenState extends State<NotificationPatternsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BankNotificationPatternProvider>();
      provider.loadPatterns();
      provider.loadStatistics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Patrones de Notificación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showProcessNotificationDialog,
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Procesar Notificación',
          ),
          TextButton.icon(
            onPressed: _navigateToAddPattern,
            icon: const Icon(Icons.add),
            label: const Text(
              'Agregar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Activos'),
            Tab(text: 'Estadísticas'),
          ],
        ),
      ),
      body: Consumer<BankNotificationPatternProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.patterns.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllPatternsTab(provider),
              _buildActivePatternsTab(provider),
              _buildStatisticsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllPatternsTab(BankNotificationPatternProvider provider) {
    if (provider.patterns.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatternsHeader(provider.patterns.length),
            const SizedBox(height: 16),
            _buildPatternsList(provider.patterns),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePatternsTab(BankNotificationPatternProvider provider) {
    final activePatterns = provider.activePatterns;

    if (activePatterns.isEmpty) {
      return _buildEmptyActiveState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatternsHeader(activePatterns.length, title: 'Patrones Activos'),
            const SizedBox(height: 16),
            _buildPatternsList(activePatterns),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(BankNotificationPatternProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadStatistics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsOverview(provider),
            const SizedBox(height: 24),
            _buildChannelStatistics(provider),
            const SizedBox(height: 24),
            _buildPerformanceStatistics(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsHeader(int count, {String title = 'Mis Patrones'}) {
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
            Icons.pattern,
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
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '$count patrones configurados',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatternsList(List<BankNotificationPatternModel> patterns) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patterns.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return NotificationPatternCard(
          pattern: pattern,
          onTap: () => _showPatternDetails(pattern),
          onEdit: () => _editPattern(pattern),
          onDelete: () => _deletePattern(pattern),
          onToggleStatus: () => _togglePatternStatus(pattern),
        );
      },
    );
  }

  Widget _buildStatisticsOverview(BankNotificationPatternProvider provider) {
    final stats = provider.statistics;
    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GlassmorphismCard(
      style: GlassStyles.dynamic,
      enableHoverEffect: true,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    stats.totalPatterns.toString(),
                    Icons.pattern,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Activos',
                    stats.activePatterns.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Coincidencias',
                    stats.totalMatches.toString(),
                    Icons.search,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Éxito',
                    '${stats.overallSuccessRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    stats.overallSuccessRate >= 80 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelStatistics(BankNotificationPatternProvider provider) {
    final channels = NotificationChannel.values;
    
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patrones por Canal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...channels.map((channel) {
              final channelPatterns = provider.getPatternsByChannel(channel);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _getChannelIcon(channel),
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getChannelDisplayName(channel),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        channelPatterns.length.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStatistics(BankNotificationPatternProvider provider) {
    final highPerformancePatterns = provider.highPerformancePatterns;
    
    return GlassmorphismCard(
      style: GlassStyles.medium,
      enableEntryAnimation: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patrones de Alto Rendimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (highPerformancePatterns.isEmpty)
              Text(
                'No hay patrones con alta tasa de éxito aún',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...highPerformancePatterns.take(5).map((pattern) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pattern.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${pattern.successRate.toStringAsFixed(1)}% éxito',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.pattern,
                size: 60,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes patrones configurados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea patrones para procesar automáticamente las notificaciones bancarias',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            GlassmorphismButton(
              style: GlassButtonStyles.primary,
              enablePulseEffect: true,
              onPressed: _navigateToAddPattern,
              child: const Text('Crear Primer Patrón'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActiveState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay patrones activos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Activa algunos patrones para procesar notificaciones automáticamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar patrones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            GlassmorphismButton(
              style: GlassButtonStyles.secondary,
              onPressed: () => context.read<BankNotificationPatternProvider>().refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChannelIcon(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.sms:
        return Icons.sms;
      case NotificationChannel.push:
        return Icons.notifications;
      case NotificationChannel.email:
        return Icons.email;
      case NotificationChannel.app:
        return Icons.mobile_friendly;
    }
  }

  String _getChannelDisplayName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.sms:
        return 'SMS';
      case NotificationChannel.push:
        return 'Push';
      case NotificationChannel.email:
        return 'Email';
      case NotificationChannel.app:
        return 'App';
    }
  }

  void _navigateToAddPattern() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddNotificationPatternScreen(),
      ),
    );
  }

  void _showProcessNotificationDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProcessNotificationScreen(),
      ),
    );
  }

  void _showPatternDetails(BankNotificationPatternModel pattern) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              Icons.pattern,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pattern.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  pattern.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Estado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: pattern.isActive
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : pattern.isLearning
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pattern.isActive ? 'Activo' : pattern.isLearning ? 'Aprendiendo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pattern.isActive 
                                    ? Colors.green 
                                    : pattern.isLearning
                                        ? Colors.orange
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Información de la cuenta
                      _buildDetailSection(
                        context,
                        'Cuenta Bancaria',
                        Icons.account_balance,
                        'ID: ${pattern.bankAccountId}',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Patrón de mensaje
                      _buildDetailSection(
                        context,
                        'Patrón de Mensaje',
                        Icons.code,
                        pattern.messagePattern,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Canal de notificación
                      _buildDetailSection(
                        context,
                        'Canal',
                        Icons.notifications,
                        pattern.channel == NotificationChannel.sms ? 'SMS' : 
                        pattern.channel == NotificationChannel.push ? 'Push' :
                        pattern.channel == NotificationChannel.email ? 'Email' : 'App',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailSection(
                        context,
                        'Prioridad',
                        Icons.flag,
                        pattern.priority.toString(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Estadísticas
                      Text(
                        'Estadísticas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Coincidencias',
                              pattern.matchCount.toString(),
                              Icons.search,
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Éxitos',
                              pattern.successCount.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Tasa de Éxito',
                              '${pattern.successRate.toStringAsFixed(1)}%',
                              Icons.trending_up,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Palabras clave
                      if (pattern.keywordsTrigger.isNotEmpty) ...[
                        Text(
                          'Palabras Clave (Incluir)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pattern.keywordsTrigger.map((keyword) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                keyword,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      if (pattern.keywordsExclude.isNotEmpty) ...[
                        Text(
                          'Palabras Clave (Excluir)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: pattern.keywordsExclude.map((keyword) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                keyword,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _togglePatternStatus(pattern);
                              },
                              icon: Icon(pattern.isActive ? Icons.pause : Icons.play_arrow),
                              label: Text(pattern.isActive ? 'Desactivar' : 'Activar'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _editPattern(pattern);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deletePattern(pattern);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar Patrón'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(color: Theme.of(context).colorScheme.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailSection(BuildContext context, String label, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editPattern(BankNotificationPatternModel pattern) {
    // Navegación a pantalla de edición (implementación futura)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edición de "${pattern.name}" próximamente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deletePattern(BankNotificationPatternModel pattern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Patrón'),
        content: Text('¿Estás seguro de que quieres eliminar "${pattern.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = context.read<BankNotificationPatternProvider>();
              final success = await provider.deletePattern(pattern.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Patrón eliminado' : 'Error al eliminar patrón',
                    ),
                    backgroundColor: success
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePatternStatus(BankNotificationPatternModel pattern) async {
    final provider = context.read<BankNotificationPatternProvider>();
    final newStatus = pattern.isActive
        ? NotificationPatternStatus.inactive
        : NotificationPatternStatus.active;
    
    final success = await provider.setPatternStatus(pattern.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Patrón ${newStatus == NotificationPatternStatus.active ? 'activado' : 'desactivado'}'
                : 'Error al cambiar estado del patrón',
          ),
          backgroundColor: success
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
