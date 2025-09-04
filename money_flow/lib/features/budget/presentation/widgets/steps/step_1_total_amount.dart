import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/currency_provider.dart';
import '../../providers/budget_setup_provider.dart';
import '../currency_selector.dart';

class Step1TotalAmount extends StatefulWidget {
  const Step1TotalAmount({super.key});

  @override
  State<Step1TotalAmount> createState() => _Step1TotalAmountState();
}

class _Step1TotalAmountState extends State<Step1TotalAmount> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final provider = context.read<BudgetSetupProvider>();
    _controller = TextEditingController(
      text: provider.totalAmount > 0 ? provider.totalAmount.toInt().toString() : '',
    );
    _controller.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAmountChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _controller.text.replaceAll(',', '');
    final amount = double.tryParse(text) ?? 0.0;
    context.read<BudgetSetupProvider>().setTotalAmount(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetSetupProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).viewInsets.bottom - 200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Encabezado explicativo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '¿Cuánto planeas gastar este mes?',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Este será tu presupuesto total mensual. No te preocupes, puedes cambiarlo después.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

               const SizedBox(height: 24),

               // Selector de divisa
               Row(
                 children: [
                   Text(
                     'Divisa:',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                       color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                     ),
                   ),
                   const SizedBox(width: 12),
                   CurrencySelector(
                     onCurrencyChanged: () {
                       // Actualizar el display cuando cambie la divisa
                       setState(() {});
                     },
                   ),
                   const Spacer(),
                   Consumer<CurrencyProvider>(
                     builder: (context, currencyProvider, child) {
                       if (currencyProvider.isDetecting) {
                         return Row(
                           children: [
                             SizedBox(
                               width: 16,
                               height: 16,
                               child: CircularProgressIndicator(
                                 strokeWidth: 2,
                                 valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                               ),
                             ),
                             const SizedBox(width: 8),
                             Text(
                               'Detectando...',
                               style: TextStyle(
                                 fontSize: 12,
                                 color: Theme.of(context).colorScheme.primary,
                               ),
                             ),
                           ],
                         );
                       }
                       return const SizedBox();
                     },
                   ),
                 ],
               ),

               const SizedBox(height: 24),

              // Input principal del monto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _focusNode.hasFocus 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presupuesto mensual',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                                         Row(
                       children: [
                         Consumer<CurrencyProvider>(
                           builder: (context, currencyProvider, child) {
                             return Text(
                               currencyProvider.currencySymbol,
                               style: TextStyle(
                                 fontSize: 32,
                                 fontWeight: FontWeight.bold,
                                 color: Theme.of(context).colorScheme.primary,
                               ),
                             );
                           },
                         ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ThousandsFormatter(),
                            ],
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Montos sugeridos
              Text(
                'Sugerencias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  final suggestions = _getSuggestionsForCurrency(currencyProvider.selectedCurrency.code);
                  
                  return Row(
                    children: [
                      for (int i = 0; i < suggestions.length; i++) ...[
                        Expanded(
                          child: _buildSuggestionChip(suggestions[i]),
                        ),
                        if (i < suggestions.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Información adicional
              if (provider.totalAmount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                                             Expanded(
                         child: Consumer<CurrencyProvider>(
                           builder: (context, currencyProvider, child) {
                             final dailyAmount = provider.totalAmount / 30;
                             return Text(
                               'Esto representa aproximadamente ${currencyProvider.formatAmount(dailyAmount)} por día.',
                               style: TextStyle(
                                 fontSize: 14,
                                 color: Theme.of(context).colorScheme.onPrimaryContainer,
                               ),
                             );
                           },
                         ),
                       ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.canProceedFromStep1 
                      ? provider.proceedToStep2 
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: provider.canProceedFromStep1 ? 4 : 0,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Obtener sugerencias basadas en la divisa
  List<int> _getSuggestionsForCurrency(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
      case 'CAD':
        return [500, 1000, 2000, 3000];
      case 'EUR':
      case 'GBP':
        return [400, 800, 1500, 2500];
      case 'MXN':
        return [8000, 15000, 25000, 40000];
      case 'COP':
        return [500000, 1000000, 2000000, 3000000];
      case 'ARS':
        return [50000, 100000, 200000, 300000];
      case 'BRL':
        return [2000, 4000, 7000, 12000];
      case 'PEN':
        return [1500, 3000, 6000, 10000];
      case 'CLP':
        return [300000, 600000, 1000000, 1500000];
      case 'JPY':
        return [50000, 100000, 200000, 300000];
      case 'KRW':
        return [500000, 1000000, 2000000, 3000000];
      case 'INR':
        return [30000, 60000, 100000, 150000];
      case 'CNY':
        return [3000, 6000, 12000, 20000];
      default:
        return [500, 1000, 2000, 3000]; // USD por defecto
    }
  }

  Widget _buildSuggestionChip(int amount) {
    return Consumer2<BudgetSetupProvider, CurrencyProvider>(
      builder: (context, budgetProvider, currencyProvider, child) {
        final isSelected = budgetProvider.totalAmount.toInt() == amount;
        return InkWell(
          onTap: () {
            _controller.text = _formatNumber(amount);
            budgetProvider.setTotalAmount(amount.toDouble());
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ] : [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _formatAmountCompact(amount.toDouble(), currencyProvider),
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (!isSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                    currencyProvider.selectedCurrency.code,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Formatear número con comas
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  // Formateo compacto para las sugerencias
  String _formatAmountCompact(double amount, CurrencyProvider currencyProvider) {
    final symbol = currencyProvider.currencySymbol;
    
    // Para divisas sin decimales o con valores altos
    if (currencyProvider.selectedCurrency.code == 'COP' || 
        currencyProvider.selectedCurrency.code == 'CLP' ||
        currencyProvider.selectedCurrency.code == 'KRW') {
      if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      }
    }
    
    // Para JPY e INR
    if (currencyProvider.selectedCurrency.code == 'JPY' || 
        currencyProvider.selectedCurrency.code == 'INR') {
      if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      }
    }
    
    // Para otras divisas (USD, EUR, etc.)
    if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

// Formateador para agregar comas a los miles
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatNumber(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}
