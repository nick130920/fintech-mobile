import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
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

  @override
  void dispose() {
    // Cancelar cualquier operación async pendiente
    super.dispose();
  }

  Future<void> _loadCurrentBudget() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final budget = await _budgetRepository.getCurrentBudget();
      
      if (!mounted) return;
      
      setState(() {
        _currentBudget = budget;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Error al cargar presupuesto: $e';
        _isLoading = false;
      });
      
      // Mostrar error con CustomSnackBar si el widget está montado
      if (mounted) {
        CustomSnackBar.showError(context, 'Error al cargar presupuesto: $e');
      }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Gestión de Categorías',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Expanded(
            child: Text(
              'Límites de Gastos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(
            Icons.add,
          ),
          label: const Text(
            'Agregar Nueva Categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay presupuesto configurado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configura tu presupuesto primero',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${currencyProvider.formatAmount(allocation.spentAmount)} / ${currencyProvider.formatAmount(allocation.allocatedAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
            onPressed: () {
              Navigator.of(context).pop();
              CustomSnackBar.showInfo(context, 'Funcionalidad próximamente disponible');
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(AllocationModel allocation) {
    showDialog(
      context: context,
      builder: (context) => _EditCategoryDialog(
        allocation: allocation,
        budgetRepository: _budgetRepository,
        onUpdate: _loadCurrentBudget,
      ),
    );
  }
}

class _EditCategoryDialog extends StatefulWidget {
  final AllocationModel allocation;
  final BudgetRepository budgetRepository;
  final VoidCallback onUpdate;

  const _EditCategoryDialog({
    required this.allocation,
    required this.budgetRepository,
    required this.onUpdate,
  });

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late TextEditingController amountController;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.allocation.allocatedAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _updateAllocation() async {
    try {
      // Validar entrada - remover espacios, comas y otros caracteres
      final cleanText = amountController.text
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .trim();
      
      if (cleanText.isEmpty) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Por favor ingresa un monto');
        }
        return;
      }

      final newAmount = double.tryParse(cleanText);
      if (newAmount == null || newAmount <= 0) {
        if (mounted) {
          CustomSnackBar.showError(context, 'Por favor ingresa un monto válido mayor a 0');
        }
        return;
      }

      if (mounted) {
        setState(() {
          isUpdating = true;
        });
      }

      // Actualizar en el backend
      await widget.budgetRepository.updateAllocation(widget.allocation.id, newAmount);

      // Cerrar diálogo
      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdate();
        CustomSnackBar.showSuccess(context, 'Límite actualizado exitosamente');
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
        CustomSnackBar.showError(context, 'Error al actualizar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.allocation.category.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.allocation.category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      widget.allocation.category.iconData,
                      color: widget.allocation.category.color,
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
                        widget.allocation.category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Text(
                            'Gastado: ${currencyProvider.formatAmount(widget.allocation.spentAmount)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: isUpdating ? null : _updateAllocation,
            child: isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Guardar'),
          ),
        ],
      );
  }
}
