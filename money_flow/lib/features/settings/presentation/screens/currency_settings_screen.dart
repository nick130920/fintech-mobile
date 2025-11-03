import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/services/exchange_rate_service.dart';
import '../../../../shared/widgets/glassmorphism_widgets.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  bool _isLoadingRates = false;
  Map<String, double>? _exchangeRates;
  String? _error;
  CacheInfo? _cacheInfo;

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    if (!ExchangeRateService.isApiKeyConfigured()) {
      return;
    }

    setState(() {
      _isLoadingRates = true;
      _error = null;
    });

    try {
      final provider = context.read<CurrencyProvider>();
      final rates = await ExchangeRateService.getExchangeRates(
        baseCurrency: provider.currencyCode,
      );
      
      final cacheInfo = await ExchangeRateService.getCacheInfo(
        provider.currencyCode,
      );

      if (mounted) {
        setState(() {
          _exchangeRates = rates;
          _cacheInfo = cacheInfo;
          _isLoadingRates = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingRates = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configuración de Divisa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (ExchangeRateService.isApiKeyConfigured())
            IconButton(
              onPressed: _isLoadingRates ? null : _loadExchangeRates,
              icon: _isLoadingRates
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Actualizar tasas',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildCurrentCurrency(),
            const SizedBox(height: 24),
            if (!ExchangeRateService.isApiKeyConfigured())
              _buildApiKeyWarning(),
            if (ExchangeRateService.isApiKeyConfigured()) ...[
              if (_cacheInfo != null) _buildCacheInfo(),
              if (_error != null) _buildError(),
            ],
            const SizedBox(height: 24),
            _buildPopularCurrencies(),
            const SizedBox(height: 24),
            _buildAllCurrencies(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            Icons.attach_money,
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
                'Divisa de la Aplicación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Selecciona tu divisa preferida',
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

  Widget _buildCurrentCurrency() {
    return Consumer<CurrencyProvider>(
      builder: (context, provider, child) {
        return GlassmorphismCard(
          style: GlassStyles.medium,
          enableHoverEffect: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Divisa Actual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      provider.selectedCurrency.flag,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.selectedCurrency.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${provider.selectedCurrency.code} (${provider.selectedCurrency.symbol})',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            provider.selectedCurrency.country,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildApiKeyWarning() {
    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Key no configurada',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Para ver tasas de cambio en tiempo real, configura tu API key en exchange_rate_service.dart',
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
      ),
    );
  }

  Widget _buildCacheInfo() {
    if (_cacheInfo == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cacheInfo!.isExpired
              ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _cacheInfo!.isExpired ? Icons.warning_amber : Icons.check_circle,
              size: 16,
              color: _cacheInfo!.isExpired
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tasas actualizadas ${_cacheInfo!.formattedAge}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error al cargar tasas: $_error',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCurrencies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Divisas Populares',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...CurrencyService.popularCurrencies.map((currency) {
          return _buildCurrencyTile(currency);
        }),
      ],
    );
  }

  Widget _buildAllCurrencies() {
    final allCurrencies = CurrencyService.popularCurrencies;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Todas las Divisas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _showCurrencySearch,
              icon: const Icon(Icons.search, size: 16),
              label: const Text('Buscar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${allCurrencies.length} divisas disponibles',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyTile(CurrencyInfo currency) {
    return Consumer<CurrencyProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.currencyCode == currency.code;
        final exchangeRate = _exchangeRates?[currency.code];

        return GlassmorphismListItem(
          enableHoverEffect: true,
          index: CurrencyService.popularCurrencies.indexOf(currency),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                currency.flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            currency.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currency.code} (${currency.symbol})',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              if (exchangeRate != null && !isSelected)
                Text(
                  '1 ${provider.currencyCode} = ${exchangeRate.toStringAsFixed(4)} ${currency.code}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onTap: isSelected ? null : () => _selectCurrency(currency),
        );
      },
    );
  }

  void _showCurrencySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencySearchBottomSheet(
        onCurrencySelected: (currency) {
          Navigator.pop(context);
          _selectCurrency(currency);
        },
        exchangeRates: _exchangeRates,
      ),
    );
  }

  Future<void> _selectCurrency(CurrencyInfo currency) async {
    final provider = context.read<CurrencyProvider>();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar Divisa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas cambiar tu divisa a:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  currency.flag,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currency.code} (${currency.symbol})',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esto cambiará el formato de todos los montos en la aplicación.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.setCurrency(currency);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Divisa cambiada a ${currency.name}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recargar tasas de cambio con la nueva divisa base
        await _loadExchangeRates();
      }
    }
  }
}

/// Widget de búsqueda de divisas con filtrado en tiempo real
class _CurrencySearchBottomSheet extends StatefulWidget {
  final Function(CurrencyInfo) onCurrencySelected;
  final Map<String, double>? exchangeRates;

  const _CurrencySearchBottomSheet({
    required this.onCurrencySelected,
    this.exchangeRates,
  });

  @override
  State<_CurrencySearchBottomSheet> createState() => _CurrencySearchBottomSheetState();
}

class _CurrencySearchBottomSheetState extends State<_CurrencySearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CurrencyInfo> _filteredCurrencies = [];
  List<CurrencyInfo> _allCurrencies = [];

  @override
  void initState() {
    super.initState();
    _allCurrencies = CurrencyService.allCurrencies;
    _filteredCurrencies = _allCurrencies;
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = _allCurrencies;
      } else {
        _filteredCurrencies = _allCurrencies.where((currency) {
          return currency.name.toLowerCase().contains(query) ||
                 currency.code.toLowerCase().contains(query) ||
                 currency.country.toLowerCase().contains(query) ||
                 currency.symbol.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Buscar Divisa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, código o país...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                filled: true,
              ),
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredCurrencies.length} resultado${_filteredCurrencies.length != 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (_searchController.text.isNotEmpty) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Results list
          Expanded(
            child: _filteredCurrencies.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      return _buildCurrencySearchTile(_filteredCurrencies[index]);
                    },
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
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron divisas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySearchTile(CurrencyInfo currency) {
    return Consumer<CurrencyProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.currencyCode == currency.code;
        final exchangeRate = widget.exchangeRates?[currency.code];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => widget.onCurrencySelected(currency),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        currency.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currency.code} (${currency.symbol}) • ${currency.country}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (exchangeRate != null && !isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            '1 ${provider.currencyCode} = ${exchangeRate.toStringAsFixed(4)} ${currency.code}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

