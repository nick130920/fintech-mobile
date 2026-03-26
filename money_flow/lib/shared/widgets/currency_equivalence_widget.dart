import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/currency_provider.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/exchange_rate_service.dart';

/// Muestra una equivalencia informativa debajo de un monto.
/// Ejemplo: "~ $12.50 USD"
/// Solo se muestra si la moneda del recurso es diferente a la del usuario.
class CurrencyEquivalenceWidget extends StatefulWidget {
  final double amount;
  final String sourceCurrency;
  final TextStyle? style;

  const CurrencyEquivalenceWidget({
    super.key,
    required this.amount,
    required this.sourceCurrency,
    this.style,
  });

  @override
  State<CurrencyEquivalenceWidget> createState() => _CurrencyEquivalenceWidgetState();
}

class _CurrencyEquivalenceWidgetState extends State<CurrencyEquivalenceWidget> {
  double? _convertedAmount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEquivalence();
  }

  @override
  void didUpdateWidget(CurrencyEquivalenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount || oldWidget.sourceCurrency != widget.sourceCurrency) {
      _loadEquivalence();
    }
  }

  Future<void> _loadEquivalence() async {
    final userCurrency = context.read<CurrencyProvider>().currencyCode;
    if (widget.sourceCurrency == userCurrency) {
      setState(() => _convertedAmount = null);
      return;
    }

    setState(() => _isLoading = true);

    final converted = await ExchangeRateService.tryConvert(
      amount: widget.amount,
      fromCurrency: widget.sourceCurrency,
      toCurrency: userCurrency,
    );

    if (mounted) {
      setState(() {
        _convertedAmount = converted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userCurrency = context.watch<CurrencyProvider>().currencyCode;

    if (widget.sourceCurrency == userCurrency) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Text(
        '...',
        style: widget.style ?? TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    if (_convertedAmount == null) {
      return const SizedBox.shrink();
    }

    final formatted = CurrencyService.formatAmountByCode(_convertedAmount!, userCurrency);

    return Text(
      '~ $formatted',
      style: widget.style ?? TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
