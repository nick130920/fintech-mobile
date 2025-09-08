import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../providers/expense_provider.dart';
import 'dashboard_widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final bool useScaffold;
  
  const DashboardScreen({super.key, this.useScaffold = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().initialize();
      context.read<DashboardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aplicar gradiente solo en tema oscuro
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    Widget scaffoldWidget = Scaffold(
      backgroundColor: isDarkTheme ? Colors.transparent : Theme.of(context).colorScheme.surface,
      body: const DashboardContentWidget(),
    );

    if (widget.useScaffold == false) {
      if (isDarkTheme) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground,
                AppColors.darkBackgroundGradient,
              ],
            ),
          ),
          child: scaffoldWidget,
        );
      } else {
        return scaffoldWidget;
      }
    }

    if (isDarkTheme) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.darkBackgroundGradient,
            ],
          ),
        ),
        child: scaffoldWidget,
      );
    } else {
      return scaffoldWidget;
    }
  }

}
