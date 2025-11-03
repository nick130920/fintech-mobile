import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense; // Para edición
  final double? initialAmount;
  final String? initialDescription;
  final String? initialMerchant;
  final DateTime? initialDate;

  const AddExpenseScreen({
    super.key,
    this.expense,
    this.initialAmount,
    this.initialDescription,
    this.initialMerchant,
    this.initialDate,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    // Si estamos editando, pre-llenar con los datos existentes
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _descriptionController.text = widget.expense!.description;
      _locationController.text = widget.expense!.location;
      _merchantController.text = widget.expense!.merchant;
      _notesController.text = widget.expense!.notes;
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.dateTime;
    } else {
      // Si no, usar los valores iniciales si existen
      if (widget.initialAmount != null) {
        _amountController.text = widget.initialAmount!.toStringAsFixed(2);
      }
      if (widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
      if (widget.initialMerchant != null) {
        _merchantController.text = widget.initialMerchant!;
      }
      if (widget.initialDate != null) {
        _selectedDate = widget.initialDate!;
      }
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Editar Gasto' : 'Registrar Gasto'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<ExpenseProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isSubmitting ? null : _submitExpense,
                child: provider.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.expense != null ? 'Editar información' : '¿En qué gastaste?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              widget.expense != null 
                                ? 'Actualiza los detalles de tu gasto'
                                : 'Registra tu gasto y mantén control de tu presupuesto',
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

                  const SizedBox(height: 32),

                  // Monto
                  _buildAmountField(),

                  const SizedBox(height: 24),

                  // Categoría
                  _buildCategorySelector(provider),

                  const SizedBox(height: 24),

                  // Descripción
                  _buildDescriptionField(),

                  const SizedBox(height: 24),

                  // Fecha
                  _buildDateSelector(),

                  const SizedBox(height: 24),

                  // Campos opcionales
                  _buildOptionalFields(),

                  const SizedBox(height: 32),

                  // Botón de crear
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting ? null : _submitExpense,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.expense != null ? 'Actualizar Gasto' : 'Registrar Gasto',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountField() {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Row(
                children: [
                  Text(
                    currencyProvider.currencySymbol,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el monto del gasto';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector(ExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCategorySelector(provider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                if (_selectedCategory != null) ...[
                  Icon(
                    _selectedCategory!.iconData,
                    size: 24,
                    color: _selectedCategory!.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCategory!.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(Icons.category, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selecciona una categoría',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
                Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Ej: Almuerzo en restaurante',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa una descripción del gasto';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child:                   Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_selectedDate.day == DateTime.now().day)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalFields() {
    return ExpansionTile(
      title: Text(
        'Información adicional (opcional)',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        
        // Lugar
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Lugar',
            hintText: 'Ej: Centro Comercial',
            prefixIcon: const Icon(Icons.place),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Comercio
        TextFormField(
          controller: _merchantController,
          decoration: InputDecoration(
            labelText: 'Comercio',
            hintText: 'Ej: McDonald\'s',
            prefixIcon: const Icon(Icons.store),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Notas
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notas',
            hintText: 'Información adicional...',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            filled: true,
          ),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  void _showCategorySelector(ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Seleccionar Categoría',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  final isSelected = _selectedCategory?.id == category.id;
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          category.iconData,
                          size: 20,
                          color: category.color,
                        ),
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(category.description),
                    trailing: isSelected 
                        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      return;
    }

    final provider = context.read<ExpenseProvider>();
    bool success;

    if (widget.expense != null) {
      // Actualizar gasto existente
      final updates = {
        'category_id': _selectedCategory!.id,
        'amount': amount,
        'description': _descriptionController.text.trim(),
        'date': _selectedDate.toIso8601String(),
        'location': _locationController.text.trim(),
        'merchant': _merchantController.text.trim(),
        'notes': _notesController.text.trim(),
      };
      
      success = await provider.updateExpense(widget.expense!.id, updates);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gasto actualizado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      // Crear nuevo gasto
      success = await provider.createExpense(
        categoryId: _selectedCategory!.id,
        amount: amount,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        merchant: _merchantController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gasto registrado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
