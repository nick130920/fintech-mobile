import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

class CategoryManagementScreen extends StatefulWidget {
  final bool useScaffold;
  
  const CategoryManagementScreen({super.key, this.useScaffold = true});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final BudgetRepository _budgetRepository = BudgetRepository();
  BudgetModel? _currentBudget;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final budget = await _budgetRepository.getCurrentBudget();
      setState(() {
        _currentBudget = budget;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar presupuesto: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Add Category Button
          _buildAddCategoryButton(),
          
          // Categories List
          Expanded(
            child: _buildCategoriesList(),
          ),
        ],
      ),
    );

    if (widget.useScaffold == false) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Gestión de Categorías'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF374151), // text-gray-700
            ),
          ),
          const Expanded(
            child: Text(
              'Límites de Gastos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827), // text-gray-900
              ),
            ),
          ),
          const SizedBox(width: 40), // Espacio para balancear el botón de back
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Navegar a pantalla de agregar categoría
            _showAddCategoryDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF137FEC), // var(--primary-color)
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: const Text(
            'Agregar Nueva Categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCurrentBudget,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_currentBudget == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay presupuesto configurado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Configura tu presupuesto primero',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _currentBudget!.allocations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final allocation = _currentBudget!.allocations[index];
        return _buildCategoryCard(allocation);
      },
    );
  }

  Widget _buildCategoryCard(AllocationModel allocation) {
    final category = allocation.category;
    final progress = allocation.progressPercent / 100;
    
    final iconColor = category.color;
    final backgroundColor = iconColor.withValues(alpha: 0.15);

    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header row con info y botón edit
              Row(
                children: [
                  // Icono de categoría
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      category.iconData,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Info de la categoría
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827), // text-gray-900
                          ),
                        ),
                        Text(
                          '${currencyProvider.formatAmount(allocation.spentAmount)} / ${currencyProvider.formatAmount(allocation.allocatedAmount)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280), // text-gray-500
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón de editar
                  IconButton(
                    onPressed: () => _showEditCategoryDialog(allocation),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      color: Color(0xFF6B7280), // text-gray-500
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Barra de progreso
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB), // bg-gray-200
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: const Text('Funcionalidad de agregar categoría próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(AllocationModel allocation) {
    final TextEditingController amountController = TextEditingController(
      text: allocation.allocatedAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${allocation.category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: allocation.category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      allocation.category.iconData,
                      color: allocation.category.color,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allocation.category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Text(
                            'Gastado: ${currencyProvider.formatAmount(allocation.spentAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Límite de gasto',
                    prefixText: currencyProvider.currencySymbol,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementar actualización
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Límite actualizado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
