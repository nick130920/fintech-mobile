import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../../features/budget/presentation/screens/category_management_screen.dart';
import '../../features/budget/presentation/screens/dashboard_screen.dart';
import '../../features/budget/presentation/screens/expense_history_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  
  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: widget.initialTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Desactivar swipe
        children: const [
          DashboardScreenContent(), // Sin Scaffold
          ExpenseHistoryScreenContent(), // Sin Scaffold
          CategoryManagementScreenContent(), // Sin Scaffold
          ProfileScreenContent(), // Placeholder
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        distance: 70,
        duration: const Duration(milliseconds: 400),
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.black.withValues(alpha: 0.1),
          blur: 2,
        ),
        openButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed, Animation<double> progress) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF367CFE), // MoneyFlow blue
                borderRadius: BorderRadius.circular(16), // Siempre cuadrado redondeado
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF367CFE).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: AnimatedRotation(
                      turns: progress.value * 0.125, // Solo rota el ícono (45°)
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 56,
          builder: (BuildContext context, void Function()? onPressed, Animation<double> progress) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF367CFE), // MoneyFlow blue
                borderRadius: BorderRadius.circular(16), // Siempre cuadrado redondeado
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF367CFE).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: AnimatedRotation(
                      turns: (1.0 - progress.value) * 0.125, // Rotación inversa para cierre
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        children: [
          // Opción Ingreso (verde)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Registrar Ingreso',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: 'income_fab',
                onPressed: () => Navigator.of(context).pushNamed('/add-income'),
                backgroundColor: const Color(0xFF10B981), // green-500
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          // Opción Gasto (rojo)
          Row( 
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Registrar Gasto',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: 'expense_fab',
                onPressed: () => Navigator.of(context).pushNamed('/add-expense'),
                backgroundColor: const Color(0xFFEF4444), // red-500
                child: const Icon(
                  Icons.trending_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 24,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            tooltip: 'Home',
            label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            tooltip: 'Reports',
            label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            tooltip: 'Budget',
            label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            tooltip: 'Profile',
            label: ''
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Animar a la nueva página
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

// Contenido del Dashboard sin Scaffold
class DashboardScreenContent extends StatelessWidget {
  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen(useScaffold: false);
  }
}

// Contenido del historial sin Scaffold
class ExpenseHistoryScreenContent extends StatelessWidget {
  const ExpenseHistoryScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpenseHistoryScreen(useScaffold: false);
  }
}

// Contenido de category management sin Scaffold
class CategoryManagementScreenContent extends StatelessWidget {
  const CategoryManagementScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryManagementScreen(useScaffold: false);
  }
}

// Placeholder para perfil
class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Perfil próximamente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
