import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:money_flow/features/bank_accounts/presentation/widgets/pending_transactions_fab.dart';
import 'package:money_flow/features/budget/presentation/screens/category_management_screen.dart';
import 'package:money_flow/features/budget/presentation/screens/dashboard_screen.dart';
import 'package:money_flow/features/budget/presentation/screens/reports_screen.dart';
import 'package:money_flow/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  const MainScreen({super.key, this.initialTab = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Desactivar swipe
            children: const [
              DashboardScreenContent(), // Sin Scaffold
              ReportsScreenContent(), // Sin Scaffold
              CategoryManagementScreenContent(), // Sin Scaffold
              ProfileScreenContent(),
            ],
          ),
          _buildLiquidGlassBottomBar(),
          const PendingTransactionsFab(),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.fan,
        pos: ExpandableFabPos.center,
        fanAngle: 60,
        distance: 80,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
        ),
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.black.withValues(alpha: 0.3),
          blur: 5,
        ),
        children: [
          FloatingActionButton.small(
            heroTag: "income",
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            child: const Icon(Icons.trending_up),
            onPressed: () {
              debugPrint('DEBUG: Income button pressed - navigating to /add-income');
              Navigator.pushNamed(context, '/add-income');
            },
          ),
          FloatingActionButton.small(
            heroTag: "expense", 
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            child: const Icon(Icons.trending_down),
            onPressed: () {
              debugPrint('DEBUG: Expense button pressed - navigating to /add-expense');
              Navigator.pushNamed(context, '/add-expense');
            },
          ),
          FloatingActionButton.small(
            heroTag: "bank_account",
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.account_balance),
            onPressed: () {
              Navigator.pushNamed(context, '/add-bank-account');
            },
          ),
        ],
      ),
    );
  }



  Widget _buildLiquidGlassBottomBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      left: 60,
      right: 60,
      bottom: bottomPadding ,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.08),
              blurRadius: 50,
              offset: const Offset(0, 20),
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipPath(
          clipper: _BottomBarClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark ? [
                    const Color(0xFF1E3A8A).withValues(alpha: 0.3), // Blue-900 with transparency
                    const Color(0xFF1E40AF).withValues(alpha: 0.2), // Blue-800 with transparency
                  ] : [
                    const Color(0xFF3B82F6).withValues(alpha: 0.15), // Blue-500 with transparency
                    const Color(0xFF2563EB).withValues(alpha: 0.1), // Blue-600 with transparency
                  ],
                ),
              ),
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Inicio'),
                  _buildNavItem(1, Icons.bar_chart_rounded, 'Reportes'),
                  const SizedBox(width: 55), // Espacio para el FAB
                  _buildNavItem(2, Icons.category_rounded, 'Categorías'),
                  _buildNavItem(3, Icons.person_rounded, 'Perfil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          height: 65, // Altura fija igual al navbar
          alignment: Alignment.center, // Centrado perfecto
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ) : null,
              child: Icon(
                icon,
                size: 24,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    return const DashboardScreen();
  }
}

// Contenido de Reports sin Scaffold
class ReportsScreenContent extends StatelessWidget {
  const ReportsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportsScreen(useScaffold: false);
  }
}


// Contenido de Category Management sin Scaffold
class CategoryManagementScreenContent extends StatelessWidget {
  const CategoryManagementScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryManagementScreen();
  }
}

// Contenido del Profile sin Scaffold
class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

// Custom clipper para crear la forma del BottomNavigationBar con indentación
class _BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Comenzar desde la esquina superior izquierda
    path.moveTo(0, 30); // Empezar con border radius
    
    // Borde superior izquierdo redondeado
    path.quadraticBezierTo(0, 0, 30, 0);
    
    // Implementación basada en el artículo de Medium usando curvas Bézier cúbicas
    // Línea hasta P1 (inicio de la curva)
    path.lineTo(size.width * 0.35, 0);
    
    // Primera curva Bézier cúbica (P1 a P3) - lado izquierdo del hundimiento
    path.cubicTo(
      size.width * 0.40, 0,      // C1: Control point 1 (horizontal desde P1)
      size.width * 0.42, 25,     // C2: Control point 2 optimizado (más cerca del centro)
      size.width * 0.5, 25,      // P3: Punto central del hundimiento
    );
    
    // Segunda curva Bézier cúbica (P3 a P5) - lado derecho del hundimiento
    path.cubicTo(
      size.width * 0.58, 25,     // C3: Control point 3 (simétrico a C2)
      size.width * 0.60, 0,      // C4: Control point 4 optimizado (más cerca del centro)
      size.width * 0.65, 0,      // P5: Final de la curva
    );
    
    // Línea hasta el borde superior derecho
    path.lineTo(size.width - 30, 0);
    
    // Borde superior derecho redondeado
    path.quadraticBezierTo(size.width, 0, size.width, 30);
    
    // Línea hacia abajo (lado derecho)
    path.lineTo(size.width, size.height - 30);
    
    // Borde inferior derecho redondeado
    path.quadraticBezierTo(size.width, size.height, size.width - 30, size.height);
    
    // Línea inferior
    path.lineTo(30, size.height);
    
    // Borde inferior izquierdo redondeado
    path.quadraticBezierTo(0, size.height, 0, size.height - 30);
    
    // Cerrar el path
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}