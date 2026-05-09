import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/trip_models.dart';
import '../../data/repositories/trip_repository.dart';

class TripReportScreen extends StatefulWidget {
  final int tripId;
  const TripReportScreen({super.key, required this.tripId});

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  final TripRepository _repository = TripRepository();
  TripReport? _report;
  bool _isLoading = false;
  bool _exporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final report = await _repository.getReport(widget.tripId);
      if (!mounted) return;
      setState(() {
        _report = report;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _export(String format) async {
    setState(() => _exporting = true);
    try {
      final bytes = await _repository.downloadReport(widget.tripId, format);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/trip_${widget.tripId}_report.$format');
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
      if (!mounted) return;
      CustomSnackBar.showSuccess(
        context,
        'Reporte guardado en ${file.path}',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.showError(
        context,
        'No se pudo exportar: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_report == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Sin reporte'),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    final report = _report!;
    final formatter = NumberFormat.currency(
      name: report.trip.primaryCurrency,
      symbol: '${report.trip.primaryCurrency} ',
      decimalDigits: 2,
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildSummary(report, formatter),
          const SizedBox(height: 24),
          Text(
            'Por categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...report.totalsByCategory.map(
            (c) => _CategoryTile(category: c, formatter: formatter),
          ),
          const SizedBox(height: 24),
          Text(
            'Por miembro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...report.totalsByMember.map(
            (m) => _MemberTile(member: m, formatter: formatter),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exporting ? null : () => _export('csv'),
                  icon: const Icon(Icons.table_view),
                  label: const Text('Exportar CSV'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exporting ? null : () => _export('pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(TripReport report, NumberFormat formatter) {
    final color = report.overBudget
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.trip.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            report.trip.destination,
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCell(
                  label: 'Estimado',
                  value: formatter.format(report.estimatedTotal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCell(
                  label: 'Gastado',
                  value: formatter.format(report.spentTotal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(report.overBudget ? Icons.warning : Icons.check, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.overBudget
                        ? 'Excediste el presupuesto en ${formatter.format(report.variance.abs())}'
                        : 'Te quedas dentro del presupuesto',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
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

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontSize: 12,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final TripReportCategoryTotal category;
  final NumberFormat formatter;
  const _CategoryTile({required this.category, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final overBudget = category.variance < 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Estimado ${formatter.format(category.estimatedAmount)} '
                  '· Real ${formatter.format(category.spentAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            (category.variance >= 0 ? '+' : '') +
                formatter.format(category.variance),
            style: TextStyle(
              color: overBudget
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final TripReportMemberTotal member;
  final NumberFormat formatter;
  const _MemberTile({required this.member, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.memberName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Pagó ${formatter.format(member.paid)} · Debe ${formatter.format(member.owed)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            (member.net >= 0 ? '+' : '') + formatter.format(member.net),
            style: TextStyle(
              color: member.net < 0
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
