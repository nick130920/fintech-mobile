import 'package:flutter/material.dart';
import 'package:money_flow/features/bank_accounts/data/models/transaction_model.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/automatic_transactions_repository.dart';
import 'package:money_flow/features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'package:money_flow/features/bank_accounts/presentation/widgets/pending_transaction_card.dart';
import 'package:money_flow/shared/widgets/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';

class PendingTransactionsScreen extends StatefulWidget {
  const PendingTransactionsScreen({super.key});

  @override
  State<PendingTransactionsScreen> createState() => _PendingTransactionsScreenState();
}

class _PendingTransactionsScreenState extends State<PendingTransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;
  bool _isSelectionMode = false;
  final Set<int> _selectedTransactions = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadData();
        _hasLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    provider.loadPendingTransactions(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
      provider.loadMorePendingTransactions();
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTransactions.clear();
      }
    });
  }

  void _toggleTransactionSelection(int transactionId) {
    setState(() {
      if (_selectedTransactions.contains(transactionId)) {
        _selectedTransactions.remove(transactionId);
      } else {
        _selectedTransactions.add(transactionId);
      }
    });
  }

  Future<void> _processBatchTransactions(String action) async {
    if (_selectedTransactions.isEmpty) return;

    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    
    // Mostrar diálogo de confirmación
    final confirmed = await _showBatchConfirmationDialog(action);
    if (!confirmed) return;

    final result = await provider.processBatchTransactions(
      _selectedTransactions.toList(),
      action,
    );

    if (result != null && mounted) {
      _showBatchResultDialog(result);
      setState(() {
        _isSelectionMode = false;
        _selectedTransactions.clear();
      });
    }
  }

  Future<bool> _showBatchConfirmationDialog(String action) async {
    final actionText = action == 'approve' ? 'aprobar' : 'rechazar';
    final count = _selectedTransactions.length;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar acción'),
        content: Text('¿Estás seguro de que quieres $actionText $count transacciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText.toUpperCase()),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showBatchResultDialog(BatchProcessResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado del procesamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total procesadas: ${result.totalProcessed}'),
            Text('Exitosas: ${result.successful}'),
            if (result.failed > 0) ...[
              Text('Fallidas: ${result.failed}'),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Errores:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...result.errors.map((error) => Text('• $error')),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transacciones Pendientes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<AutomaticTransactionsProvider>(
            builder: (context, provider, child) {
              if (provider.hasPendingTransactions) {
                return IconButton(
                  icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
                  onPressed: _toggleSelectionMode,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          if (_isSelectionMode && _selectedTransactions.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _processBatchTransactions('approve'),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _processBatchTransactions('reject'),
            ),
          ],
        ],
      ),
      body: Consumer<AutomaticTransactionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pendingTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          if (!provider.hasPendingTransactions) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPendingTransactions(refresh: true),
            child: Column(
              children: [
                if (_isSelectionMode) _buildSelectionHeader(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.pendingTransactions.length + (provider.hasMorePending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.pendingTransactions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final transaction = provider.pendingTransactions[index];
                      final isSelected = _selectedTransactions.contains(transaction.id);

                      return PendingTransactionCard(
                        transaction: transaction,
                        isSelectionMode: _isSelectionMode,
                        isSelected: isSelected,
                        onTap: _isSelectionMode 
                          ? () => _toggleTransactionSelection(transaction.id)
                          : null,
                        onApprove: _isSelectionMode 
                          ? null 
                          : () => _approveTransaction(transaction),
                        onReject: _isSelectionMode 
                          ? null 
                          : () => _rejectTransaction(transaction),
                        onEdit: _isSelectionMode 
                          ? null 
                          : () => _editTransaction(transaction),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return GlassmorphismCard(
      style: GlassStyles.light,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_selectedTransactions.length} transacciones seleccionadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTransactions.clear();
                });
              },
              child: const Text('Limpiar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassmorphismCard(
        style: GlassStyles.medium,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Todo al día!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No tienes transacciones pendientes de revisión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: GlassmorphismCard(
        style: GlassStyles.medium,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approveTransaction(TransactionModel transaction) async {
    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    final success = await provider.approveTransaction(transaction.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción aprobada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectTransaction(TransactionModel transaction) async {
    final reason = await _showRejectReasonDialog();
    if (reason == null) return;

    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    final success = await provider.rejectTransaction(transaction.id, reason: reason);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción rechazada'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final controller = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo del rechazo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Opcional: Explica por qué rechazas esta transacción',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _editTransaction(TransactionModel transaction) {
    Navigator.of(context).pushNamed(
      '/edit-pending-transaction',
      arguments: transaction,
    );
  }
}
