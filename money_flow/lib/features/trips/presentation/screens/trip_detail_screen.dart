import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../providers/active_trip_provider.dart';
import 'trip_balance_screen.dart';
import 'trip_budget_screen.dart';
import 'trip_expenses_screen.dart';
import 'trip_itinerary_screen.dart';
import 'trip_members_screen.dart';
import 'trip_report_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = <Tab>[
    Tab(text: 'Resumen'),
    Tab(text: 'Presupuesto'),
    Tab(text: 'Gastos'),
    Tab(text: 'Grupo'),
    Tab(text: 'Itinerario'),
    Tab(text: 'Balance'),
    Tab(text: 'Reporte'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActiveTripProvider>().load(widget.tripId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<ActiveTripProvider>().load(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<ActiveTripProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasTrip) {
            return const Center(child: CircularProgressIndicator());
          }
          final trip = provider.trip;
          if (trip == null) {
            return _buildErrorState(provider.error);
          }
          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                backgroundColor: Theme.of(context).colorScheme.surface,
                actions: [
                  IconButton(
                    onPressed: () => _showStatusActions(trip),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(trip.name),
                  background: _buildHeaderBackground(trip),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _tabs,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _SummaryTab(trip: trip, onRefresh: _refresh),
                TripBudgetScreen(tripId: trip.id),
                TripExpensesScreen(tripId: trip.id),
                TripMembersScreen(tripId: trip.id),
                TripItineraryScreen(tripId: trip.id),
                TripBalanceScreen(tripId: trip.id),
                TripReportScreen(tripId: trip.id),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'No se pudo cargar el viaje',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _refresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground(Trip trip) {
    final hasCover = trip.coverImageUrl.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCover)
          Image.network(
            trip.coverImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildGradient(),
          )
        else
          _buildGradient(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trip.destination,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatRange(trip),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }

  String _formatRange(Trip trip) {
    final formatter = DateFormat('d MMM y', 'es');
    return '${formatter.format(trip.startDate)} - ${formatter.format(trip.endDate)}';
  }

  Future<void> _showStatusActions(Trip trip) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusActionsSheet(currentStatus: trip.status),
    );
    if (action == null || !mounted) return;
    final provider = context.read<ActiveTripProvider>();
    final ok = await provider.changeStatus(action);
    if (!mounted) return;
    if (ok) {
      CustomSnackBar.showSuccess(context, 'Viaje actualizado');
    } else {
      CustomSnackBar.showError(
          context, provider.error ?? 'No se pudo actualizar');
    }
  }
}

class _StatusActionsSheet extends StatelessWidget {
  final TripStatus currentStatus;
  const _StatusActionsSheet({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final available = <_StatusAction>[
      if (currentStatus == TripStatus.planning)
        const _StatusAction(label: 'Iniciar viaje', icon: Icons.play_arrow, action: 'start'),
      if (currentStatus == TripStatus.active)
        const _StatusAction(label: 'Marcar como completado', icon: Icons.flag, action: 'complete'),
      if (currentStatus != TripStatus.cancelled && currentStatus != TripStatus.completed)
        const _StatusAction(label: 'Cancelar viaje', icon: Icons.cancel, action: 'cancel'),
    ];

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (available.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No hay acciones disponibles para este estado.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              )
            else
              ...available.map(
                (a) => ListTile(
                  leading: Icon(a.icon),
                  title: Text(a.label),
                  onTap: () => Navigator.pop(context, a.action),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusAction {
  final String label;
  final IconData icon;
  final String action;
  const _StatusAction({required this.label, required this.icon, required this.action});
}

class _SummaryTab extends StatelessWidget {
  final Trip trip;
  final Future<void> Function() onRefresh;

  const _SummaryTab({required this.trip, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      name: trip.primaryCurrency,
      symbol: '${trip.primaryCurrency} ',
      decimalDigits: 2,
    );
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            title: 'Total estimado',
            value: formatter.format(trip.estimatedTotal),
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.savings,
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Gastado',
            value: formatter.format(trip.spentTotal),
            color: trip.progressPercent > 100
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.tertiary,
            icon: Icons.shopping_bag,
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Disponible',
            value: formatter.format(trip.remainingAmount),
            color: trip.remainingAmount < 0
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progreso del viaje',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (trip.progressPercent / 100).clamp(0.0, 1.5),
                    minHeight: 10,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHigh,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${trip.daysRemaining} días restantes',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${trip.progressPercent.toStringAsFixed(0)}% gastado',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (trip.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trip.notes,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }
}
