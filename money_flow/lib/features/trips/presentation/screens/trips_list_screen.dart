import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/glassmorphism_widgets.dart';
import '../../data/models/trip_models.dart';
import '../providers/trips_provider.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';

/// Pantalla principal del módulo de viajes: lista los viajes del usuario
class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen> {
  TripStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripsProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<TripsProvider>().load(
          status: _statusFilter?.apiValue ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mis viajes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTrip,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo viaje'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Consumer<TripsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.trips.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final trips = provider.filterByStatus(_statusFilter);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  _buildStatusFilters(),
                  if (provider.error != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorBanner(provider.error!),
                  ],
                  const SizedBox(height: 16),
                  if (trips.isEmpty)
                    _buildEmptyState()
                  else
                    ...trips.map(_buildTripCard),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    final filters = [
      _StatusFilter(label: 'Todos', value: null),
      _StatusFilter(label: 'Planificando', value: TripStatus.planning),
      _StatusFilter(label: 'Activos', value: TripStatus.active),
      _StatusFilter(label: 'Completados', value: TripStatus.completed),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _statusFilter == filter.value;
          return ChoiceChip(
            label: Text(filter.label),
            selected: selected,
            onSelected: (_) {
              setState(() => _statusFilter = filter.value);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes viajes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Planifica tu próxima aventura, define un presupuesto estimado y comparte gastos con tus compañeros.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openCreateTrip,
            icon: const Icon(Icons.add),
            label: const Text('Crear mi primer viaje'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final dateFormat = DateFormat('d MMM y', 'es');
    final dates = '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}';
    final progress = (trip.progressPercent / 100).clamp(0.0, 1.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphismCard(
        style: GlassmorphismStyle.medium,
        enableHoverEffect: true,
        onTap: () => _openTrip(trip.id),
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
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.beach_access,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          trip.destination,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(trip.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dates,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${trip.daysTotal} días',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress > 1.5 ? 1.5 : progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_formatCurrency(trip.spentTotal, trip.primaryCurrency)} / '
                    '${_formatCurrency(trip.estimatedTotal, trip.primaryCurrency)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${trip.progressPercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TripStatus status) {
    Color background;
    Color foreground;
    String label;
    switch (status) {
      case TripStatus.planning:
        background = Theme.of(context).colorScheme.tertiaryContainer;
        foreground = Theme.of(context).colorScheme.onTertiaryContainer;
        label = 'Planificando';
        break;
      case TripStatus.active:
        background = Theme.of(context).colorScheme.primaryContainer;
        foreground = Theme.of(context).colorScheme.onPrimaryContainer;
        label = 'Activo';
        break;
      case TripStatus.completed:
        background = Theme.of(context).colorScheme.secondaryContainer;
        foreground = Theme.of(context).colorScheme.onSecondaryContainer;
        label = 'Completado';
        break;
      case TripStatus.cancelled:
        background = Theme.of(context).colorScheme.errorContainer;
        foreground = Theme.of(context).colorScheme.onErrorContainer;
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  String _formatCurrency(double value, String currency) {
    final format = NumberFormat.currency(name: currency, symbol: '$currency ', decimalDigits: 2);
    return format.format(value);
  }

  Future<void> _openCreateTrip() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateTripScreen()),
    );
    if (created == true && mounted) {
      await _refresh();
    }
  }

  Future<void> _openTrip(int id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: id)),
    );
    if (!mounted) return;
    await _refresh();
  }
}

class _StatusFilter {
  final String label;
  final TripStatus? value;

  const _StatusFilter({required this.label, required this.value});
}
