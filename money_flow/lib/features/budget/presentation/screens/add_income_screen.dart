import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/currency_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/income_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  final bool useScaffold;
  
  const AddIncomeScreen({super.key, this.useScaffold = true});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedSource;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _selectedFrequency = 'monthly';
  DateTime? _endDate;
  double? _taxDeducted;
  
  bool _isLoading = false;

  final List<Map<String, String>> _incomeSources = [
    {'value': 'salary', 'label': 'Salario', 'icon': '💼'},
    {'value': 'freelance', 'label': 'Freelance', 'icon': '💻'},
    {'value': 'investment', 'label': 'Inversiones', 'icon': '📈'},
    {'value': 'business', 'label': 'Negocio', 'icon': '🏢'},
    {'value': 'rental', 'label': 'Renta', 'icon': '🏠'},
    {'value': 'bonus', 'label': 'Bono', 'icon': '🎁'},
    {'value': 'gift', 'label': 'Regalo', 'icon': '🎉'},
    {'value': 'other', 'label': 'Otros', 'icon': '💰'},
  ];

  final List<Map<String, String>> _frequencies = [
    {'value': 'weekly', 'label': 'Semanal'},
    {'value': 'biweekly', 'label': 'Quincenal'},
    {'value': 'monthly', 'label': 'Mensual'},
    {'value': 'yearly', 'label': 'Anual'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      color: const Color(0xFFF9FAFB), // bg-gray-50
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount input
                      _buildAmountInput(),
                        
                      const SizedBox(height: 24),
                      
                      // Source selection
                      _buildSourceSelection(),
                      
                      const SizedBox(height: 24),
                      
                      // Date selection
                      _buildDateSelection(),
                      
                      const SizedBox(height: 24),
                      
                      // Description input
                      _buildDescriptionInput(),
                      
                      const SizedBox(height: 24),
                      
                      // Notes input
                      _buildNotesInput(),
                      
                      const SizedBox(height: 24),
                      
                      // Recurring income section
                      _buildRecurringSection(),
                      
                      const SizedBox(height: 100), // Space for fixed button
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Fixed save button
          _buildSaveButton(),
        ],
      ),
    );

    if (widget.useScaffold == false) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: _buildAppBar(),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: body,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Registrar Ingreso',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937), // text-gray-800
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF6B7280), // text-gray-500
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monto del ingreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280), // text-gray-500
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // text-gray-800
                ),
                decoration: InputDecoration(
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      currencyProvider.currencySymbol,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9CA3AF), // text-gray-400
                      ),
                    ),
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9CA3AF), // text-gray-400
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF367CFE), // moneyflow-blue
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Por favor ingresa un monto válido';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSourceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría del ingreso',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280), // text-gray-500
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedSource,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(
                Icons.expand_more,
                color: Color(0xFF6B7280), // text-gray-500
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF367CFE), // moneyflow-blue
                  width: 2,
                ),
              ),
            ),
            hint: const Text(
              'Seleccionar categoría',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF), // text-gray-400
              ),
            ),
            items: _incomeSources.map((source) {
              return DropdownMenuItem<String>(
                value: source['value'],
                child: Row(
                  children: [
                    Text(
                      source['icon']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      source['label']!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937), // text-gray-800
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSource = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona una categoría';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha del ingreso',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280), // text-gray-500
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF6B7280), // text-gray-500
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937), // text-gray-800
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280), // text-gray-500
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Ej: Salario de enero',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF), // text-gray-400
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF367CFE), // moneyflow-blue
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280), // text-gray-500
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Añadir una nota...',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF), // text-gray-400
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF367CFE), // moneyflow-blue
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Recurring toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.autorenew,
                    color: Color(0xFF6B7280), // text-gray-500
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Ingreso recurrente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937), // text-gray-800
                    ),
                  ),
                ],
              ),
                              Switch(
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                  activeTrackColor: const Color(0xFF367CFE), // moneyflow-blue
                  activeThumbColor: Colors.white,
                ),
            ],
          ),
          
          // Recurring options
          if (_isRecurring) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE5E7EB)), // border-gray-200
            const SizedBox(height: 16),
            
            // Frequency selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frecuencia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280), // text-gray-500
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB), // bg-gray-50
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)), // border-gray-200
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFrequency,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: Icon(
                        Icons.expand_more,
                        color: Color(0xFF6B7280), // text-gray-500
                      ),
                    ),
                    items: _frequencies.map((frequency) {
                      return DropdownMenuItem<String>(
                        value: frequency['value'],
                        child: Text(
                          frequency['label']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F2937), // text-gray-800
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // End date selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha de finalización (opcional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280), // text-gray-500
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB), // bg-gray-50
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)), // border-gray-200
                  ),
                  child: InkWell(
                    onTap: _selectEndDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF6B7280), // text-gray-500
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              fontSize: 16,
                              color: _endDate != null 
                                  ? const Color(0xFF1F2937) // text-gray-800
                                  : const Color(0xFF9CA3AF), // text-gray-400
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB), // bg-gray-50
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveIncome,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF367CFE), // moneyflow-blue
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF9CA3AF), // text-gray-400
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();

      final success = await context.read<IncomeProvider>().createIncome(
        amount: amount,
        description: description,
        source: _selectedSource!,
        date: _selectedDate,
        notes: notes.isNotEmpty ? notes : null,
        taxDeducted: _taxDeducted,
        isRecurring: _isRecurring,
        frequency: _isRecurring ? _selectedFrequency : null,
        endDate: _isRecurring ? _endDate : null,
      );

      if (success && mounted) {
        // Update dashboard data
        context.read<DashboardProvider>().updateAvailableBalance();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingreso registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back
        Navigator.of(context).pop();
      } else if (mounted) {
        // Show error message
        final error = context.read<IncomeProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al registrar el ingreso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
