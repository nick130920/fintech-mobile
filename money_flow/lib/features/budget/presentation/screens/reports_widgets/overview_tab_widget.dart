import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';

/// Decoración glass Stitch: fondo surface+3% claro, borde 6%, rounded-2xl.
BoxDecoration _stitchGlassDecoration(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark
        ? Color.lerp(theme.colorScheme.surface, theme.colorScheme.onSurface, 0.03)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
          : theme.colorScheme.outline.withValues(alpha: 0.15),
      width: 1,
    ),
  );
}

Widget _stitchGlassCard(BuildContext context, {required Widget child, EdgeInsetsGeometry? padding}) {
  final paddingResolved = padding ?? const EdgeInsets.all(24);
  return Container(
    decoration: _stitchGlassDecoration(context),
    padding: paddingResolved,
    child: child,
  );
}

/// Pestaña Resumen alineada con diseño Stitch: Balance Mensual, Tendencia de Gastos,
/// Categorías (scroll horizontal) y Detalle por categoría.
class OverviewTabWidget extends StatefulWidget {
  const OverviewTabWidget({super.key});

  @override
  State<OverviewTabWidget> createState() => _OverviewTabWidgetState();
}

class _OverviewTabWidgetState extends State<OverviewTabWidget> {
  CategoryModel? _selectedCategory;
  bool _showGastos = true; // pill activo: GASTOS

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StitchBalanceCard(),
          const SizedBox(height: 24),
          const _StitchTrendSection(),
          const SizedBox(height: 24),
          _StitchCategorySection(
            selectedCategory: _selectedCategory,
            showGastos: _showGastos,
            onCategorySelected: (c) => setState(() => _selectedCategory = c),
            onPillChanged: (showGastos) => setState(() => _showGastos = showGastos),
          ),
          const SizedBox(height: 24),
          _StitchDetalleSection(
            selectedCategory: _selectedCategory,
            onClearDetail: () => setState(() => _selectedCategory = null),
          ),
        ],
      ),
    );
  }
}

/// Card "Balance Mensual" estilo Stitch: rounded-2xl, barras h-1.5 (6px), track slate.
class _StitchBalanceCard extends StatelessWidget {
  const _StitchBalanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer4<ExpenseProvider, CurrencyProvider, DashboardProvider, IncomeProvider>(
      builder: (context, expenseProvider, currencyProvider, dashboardProvider, incomeProvider, _) {
        final monthlyIncome = incomeProvider.currentMonthIncome;
        final monthlyExpenses = expenseProvider.monthlyTotal;
        final netBalance = monthlyIncome - monthlyExpenses;
        final trend = dashboardProvider.spendingTrend;
        final maxAmount = monthlyIncome > monthlyExpenses ? monthlyIncome : (monthlyExpenses > 0 ? monthlyExpenses : 1.0);
        final incomeBar = maxAmount > 0 ? (monthlyIncome / maxAmount).clamp(0.0, 1.0) : 0.0;
        final expenseBar = maxAmount > 0 ? (monthlyExpenses / maxAmount).clamp(0.0, 1.0) : 0.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _stitchGlassCard(
            context,
            padding: const EdgeInsets.all(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -36,
                  right: -36,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance Mensual',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyProvider.formatAmount(netBalance.abs()),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trend > 0 ? Icons.trending_up : Icons.trending_down,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INGRESOS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyProvider.formatAmount(monthlyIncome),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildProgressBar(context, incomeBar, theme.colorScheme.primary, 6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'GASTOS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyProvider.formatAmount(monthlyExpenses),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildProgressBar(context, expenseBar, theme.colorScheme.error, 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, double value, Color color, double height) {
    final v = value.clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * v,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset.zero,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Sección "Tendencia de Gastos" con 10 barras usando datos reales del mes (ExpenseProvider).
class _StitchTrendSection extends StatelessWidget {
  const _StitchTrendSection();

  /// Opacidades tipo Stitch (de sutil a fuerte) para cada barra.
  static const List<double> _alphas = [0.1, 0.1, 0.2, 0.1, 0.4, 0.1, 0.3, 0.1, 0.6, 1.0];

  static void _showPeriodInfo(
    BuildContext context,
    int periodIndex,
    double amount,
    ExpenseProvider expenseProvider,
    CurrencyProvider currencyProvider,
  ) {
    final theme = Theme.of(context);
    final (startDay, endDay) = expenseProvider.getPeriodDayRange(periodIndex);
    final expenses = expenseProvider.getMonthlyExpensesInPeriod(periodIndex);
    final monthName = DateFormat('MMMM', 'es').format(DateTime(DateTime.now().year, DateTime.now().month, 1));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            left: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            right: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Días $startDay–$endDay de $monthName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total gastado',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  currencyProvider.formatAmount(amount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${expenses.length} transacciones',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (expenses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Detalle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: expenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final e = expenses[i];
                    return Row(
                      children: [
                        Icon(e.category.iconData, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '-${currencyProvider.formatAmount(e.amount)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ExpenseProvider, CurrencyProvider>(
      builder: (context, expenseProvider, currencyProvider, _) {
        final amounts = expenseProvider.monthlyExpensesByPeriod;
        final maxAmount = amounts.isEmpty
            ? 0.0
            : amounts.reduce((a, b) => a > b ? a : b);
        // Alturas normalizadas (0..1); mínimo 4% para que se vea la barra si hay algo.
        final heights = amounts.map((v) {
          if (maxAmount <= 0) return 0.04;
          final h = (v / maxAmount).clamp(0.0, 1.0);
          return h < 0.04 && v > 0 ? 0.04 : h;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendencia de Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gastos por tramos del mes (cada barra ≈ 3 días). Toca una barra para ver el detalle.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            _stitchGlassCard(
              context,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(10, (i) {
                        final isLastBar = i == 9;
                        final height = i < heights.length ? heights[i] : 0.04;
                        final amount = i < amounts.length ? amounts[i] : 0.0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GestureDetector(
                                    onTap: () => _showPeriodInfo(
                                      context,
                                      i,
                                      amount,
                                      expenseProvider,
                                      currencyProvider,
                                    ),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: double.infinity,
                                      height: constraints.maxHeight * height,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: _alphas[i]),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        boxShadow: isLastBar && amounts[9] > 0
                                            ? [
                                                BoxShadow(
                                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                                  blurRadius: 12,
                                                  spreadRadius: 0,
                                                  offset: Offset.zero,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inicio mes',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        'Fin mes',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Categorías: título, subtítulo, pills GASTOS/INGRESOS, scroll horizontal de cards.
class _StitchCategorySection extends StatelessWidget {
  const _StitchCategorySection({
    required this.selectedCategory,
    required this.showGastos,
    required this.onCategorySelected,
    required this.onPillChanged,
  });

  final CategoryModel? selectedCategory;
  final bool showGastos;
  final ValueChanged<CategoryModel?> onCategorySelected;
  final ValueChanged<bool> onPillChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ExpenseProvider, CurrencyProvider>(
      builder: (context, expenseProvider, currencyProvider, _) {
        final topCategories = expenseProvider.topCategories;
        final total = expenseProvider.monthlyTotal;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toca para filtrar transacciones',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _Pill(
                      label: 'GASTOS',
                      active: showGastos,
                      onTap: () => onPillChanged(true),
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      label: 'INGRESOS',
                      active: !showGastos,
                      onTap: () => onPillChanged(false),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topCategories.isEmpty)
              _stitchGlassCard(
                context,
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sin gastos este mes',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: topCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = topCategories[index];
                    final name = item['name'] as String;
                    final amount = item['amount'] as double;
                    final category = item['category'] as CategoryModel;
                    final pct = total > 0 ? ((amount / total) * 100).round() : 0;
                    final effectiveSelected = selectedCategory ?? (topCategories.isNotEmpty ? topCategories[0]['category'] as CategoryModel? : null);
                    final isActive = effectiveSelected?.id == category.id;
                    return _CategoryCard(
                      category: category,
                      name: name,
                      amount: currencyProvider.formatAmount(amount),
                      percent: pct,
                      isActive: isActive,
                      onTap: () => onCategorySelected(category),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : (theme.brightness == Brightness.dark
                    ? Color.lerp(theme.colorScheme.surface, theme.colorScheme.onSurface, 0.03)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)),
            borderRadius: BorderRadius.circular(999),
            border: active ? null : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.name,
    required this.amount,
    required this.percent,
    required this.isActive,
    required this.onTap,
  });

  final CategoryModel category;
  final String name;
  final String amount;
  final int percent;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: isActive
              ? _stitchGlassDecoration(context).copyWith(
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                )
              : _stitchGlassDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.iconData, color: category.color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$percent% de gastos',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detalle: "Detalle: [categoría]" + LIMPIAR + lista con dividers.
class _StitchDetalleSection extends StatelessWidget {
  const _StitchDetalleSection({
    this.selectedCategory,
    required this.onClearDetail,
  });

  final CategoryModel? selectedCategory;
  final VoidCallback onClearDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ExpenseProvider, CurrencyProvider>(
      builder: (context, expenseProvider, currencyProvider, _) {
        final topCategories = expenseProvider.topCategories;
        final effectiveCategory = selectedCategory ??
            (topCategories.isNotEmpty ? topCategories[0]['category'] as CategoryModel? : null);
        final categoryName = effectiveCategory?.displayName.isNotEmpty == true
            ? effectiveCategory!.displayName
            : effectiveCategory?.name ?? '—';
        final detailExpenses = effectiveCategory != null
            ? expenseProvider.monthlyExpenses
                .where((e) => e.category.id == effectiveCategory.id && e.isConfirmed)
                .toList()
            : <ExpenseModel>[];
        detailExpenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalle: $categoryName',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                GestureDetector(
                  onTap: onClearDetail,
                  child: Text(
                    'LIMPIAR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (detailExpenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    effectiveCategory == null
                        ? 'Selecciona una categoría'
                        : 'Sin transacciones en esta categoría',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              _stitchGlassCard(
                context,
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < detailExpenses.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      _DetalleRow(
                        expense: detailExpenses[i],
                        currencyProvider: currencyProvider,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DetalleRow extends StatelessWidget {
  const _DetalleRow({
    required this.expense,
    required this.currencyProvider,
  });

  final ExpenseModel expense;
  final CurrencyProvider currencyProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('d MMM, hh:mm a', 'es').format(expense.dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              expense.category.iconData,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${currencyProvider.formatAmount(expense.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
