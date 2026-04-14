import 'dart:ui';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import 'reports_widgets/overview_tab_widget.dart';

/// Pantalla de Reportes: solo Overview, alineada con el diseño Stitch.
/// Las pestañas Ingresos y Gastos están desconectadas por ahora.
class ReportsScreen extends StatefulWidget {
  final bool useScaffold;

  const ReportsScreen({
    super.key,
    this.useScaffold = true,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().initialize();
      context.read<DashboardProvider>().initialize();
      context.read<IncomeProvider>().initialize();
    });
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    int tempYear = _selectedMonth.year;
    int tempMonth = _selectedMonth.month;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Navegación de año
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: tempYear > now.year - 2
                              ? () => setDialogState(() => tempYear--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          '$tempYear',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: tempYear < now.year
                              ? () => setDialogState(() => tempYear++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Grid de meses
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, i) {
                        final month = i + 1;
                        final isFuture = tempYear == now.year && month > now.month;
                        final isSelected = tempYear == _selectedMonth.year && month == _selectedMonth.month;
                        return InkWell(
                          onTap: isFuture ? null : () {
                            tempMonth = month;
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedMonth = DateTime(tempYear, tempMonth, 1);
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              DateFormat('MMM', 'es').format(DateTime(tempYear, month)),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : isFuture
                                        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showExportSheet() async {
    String format = 'csv';
    DateTime fromDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime toDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    bool includeCategories = true;
    bool includeNotes = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exportar Transacciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: format,
                      decoration: const InputDecoration(labelText: 'Formato'),
                      items: const [
                        DropdownMenuItem(value: 'csv', child: Text('CSV')),
                        DropdownMenuItem(value: 'xlsx', child: Text('Excel (.xlsx)')),
                        DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() => format = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: fromDate,
                                firstDate: DateTime(DateTime.now().year - 3),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setSheetState(() => fromDate = picked);
                              }
                            },
                            icon: const Icon(Icons.date_range),
                            label: Text(DateFormat('dd/MM/yyyy').format(fromDate)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: toDate,
                                firstDate: DateTime(DateTime.now().year - 3),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setSheetState(() => toDate = picked);
                              }
                            },
                            icon: const Icon(Icons.event),
                            label: Text(DateFormat('dd/MM/yyyy').format(toDate)),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: includeCategories,
                      onChanged: (value) => setSheetState(() => includeCategories = value ?? true),
                      title: const Text('Incluir categorías'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: includeNotes,
                      onChanged: (value) => setSheetState(() => includeNotes = value ?? false),
                      title: const Text('Incluir notas'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _exportTransactions(
                            format: format,
                            fromDate: fromDate,
                            toDate: toDate,
                            includeCategories: includeCategories,
                            includeNotes: includeNotes,
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Exportar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportTransactions({
    required String format,
    required DateTime fromDate,
    required DateTime toDate,
    required bool includeCategories,
    required bool includeNotes,
  }) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fileDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final filtered = expenseProvider.expenses.where((e) {
      final date = e.dateTime;
      final normalized = DateTime(date.year, date.month, date.day);
      final from = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final to = DateTime(toDate.year, toDate.month, toDate.day);
      return !normalized.isBefore(from) && !normalized.isAfter(to);
    }).toList();

    if (filtered.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay transacciones en el rango seleccionado.')),
      );
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final ext = format == 'pdf' ? 'pdf' : (format == 'xlsx' ? 'xlsx' : 'csv');
      final filePath = '${tempDir.path}/transactions_$fileDate.$ext';
      final file = File(filePath);

      if (format == 'pdf') {
        final pdf = pw.Document();
        final headers = <String>['Fecha', 'Descripción', 'Monto'];
        if (includeCategories) headers.add('Categoría');
        if (includeNotes) headers.add('Notas');

        final rows = filtered.map((e) {
          final row = <String>[
            dateFormat.format(e.dateTime),
            e.description,
            e.amount.toStringAsFixed(2),
          ];
          if (includeCategories) row.add(e.category.name);
          if (includeNotes) row.add(e.notes);
          return row;
        }).toList();

        pdf.addPage(
          pw.MultiPage(
            build: (context) => [
              pw.Text(
                'Exportación de transacciones',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Rango: ${dateFormat.format(fromDate)} - ${dateFormat.format(toDate)}'),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: rows,
              ),
            ],
          ),
        );
        await file.writeAsBytes(await pdf.save(), flush: true);
      } else {
        final rows = <List<dynamic>>[
          <String>[
            'Fecha',
            'Descripción',
            'Monto',
            if (includeCategories) 'Categoría',
            if (includeNotes) 'Notas',
          ],
          ...filtered.map((e) => <dynamic>[
                dateFormat.format(e.dateTime),
                e.description,
                e.amount.toStringAsFixed(2),
                if (includeCategories) e.category.name,
                if (includeNotes) e.notes,
              ]),
        ];
        final csv = const ListToCsvConverter().convert(rows);
        await file.writeAsString(csv, flush: true);
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exportación de transacciones ($format)',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exportación $format completada (${DateFormat('dd/MM').format(fromDate)} - ${DateFormat('dd/MM').format(toDate)}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: OverviewTabWidget(selectedMonth: _selectedMonth)),
        ],
      ),
    );

    if (widget.useScaffold == false) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: body,
    );
  }

  /// Header al estilo Stitch: título "Reportes" + selector de mes en pill glass.
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(
              alpha: isDark ? 0.6 : 0.85,
            ),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (widget.useScaffold)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.chevron_left,
                      color: theme.colorScheme.onSurface,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 48, height: 48),
              if (widget.useScaffold) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reportes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Material(
                color: theme.colorScheme.surface.withValues(alpha: 0),
                child: InkWell(
                  onTap: _pickMonth,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM', 'es').format(_selectedMonth),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Exportar transacciones',
                child: IconButton(
                  onPressed: _showExportSheet,
                  icon: const Icon(Icons.download_for_offline_outlined),
                  tooltip: 'Exportar transacciones',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
