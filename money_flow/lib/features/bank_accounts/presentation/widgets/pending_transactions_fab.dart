import 'package:flutter/material.dart';
import 'package:money_flow/features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'package:money_flow/shared/widgets/glassmorphism_widgets.dart';
import 'package:provider/provider.dart';

class PendingTransactionsFab extends StatefulWidget {
  const PendingTransactionsFab({super.key});

  @override
  State<PendingTransactionsFab> createState() => _PendingTransactionsFabState();
}

class _PendingTransactionsFabState extends State<PendingTransactionsFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Inicializar datos si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _loadData();
        _hasLoaded = true;
      }
    });

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    final provider = Provider.of<AutomaticTransactionsProvider>(context, listen: false);
    provider.initializeIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutomaticTransactionsProvider>(
      builder: (context, provider, child) {
        // Solo mostrar si hay transacciones pendientes
        if (provider.pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 100, // Encima del BottomNavigationBar
          right: 16,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: GlassmorphismButton(
                    style: GlassButtonStyles.floating,
                    enablePulseEffect: true,
                    enableRippleEffect: true,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/pending-transactions');
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withValues(alpha: 0.8),
                            Colors.deepOrange.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.pending_actions,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 18),
                              height: 18,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  provider.pendingCount > 99 
                                    ? '99+' 
                                    : provider.pendingCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
          ),
        );
      },
    );
  }
}
