import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_flow/core/theme/app_theme.dart';
import 'package:money_flow/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:money_flow/features/budget/presentation/providers/budget_suggestions_provider.dart';
import 'package:money_flow/features/budget/presentation/screens/budget_setup_choice_screen.dart';
import 'package:money_flow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';

typedef ScreenshotScenarioFactory = Widget Function();

const screenshotReadinessDelay = Duration(milliseconds: 500);

class PlayStoreScreenshotScenario {
  const PlayStoreScreenshotScenario({
    required this.name,
    required this.visibleMarker,
    required this.factory,
  });

  final String name;
  final String visibleMarker;
  final ScreenshotScenarioFactory factory;
}

const Locale playStoreScreenshotLocale = Locale.fromSubtags(
  languageCode: 'es',
  countryCode: '419',
);

final List<PlayStoreScreenshotScenario> playStoreScreenshotScenarios = [
  PlayStoreScreenshotScenario(
    name: '01-welcome',
    visibleMarker: 'MoneyFlow',
    factory: () => WelcomeScreen(onAuthSuccess: () {}),
  ),
  PlayStoreScreenshotScenario(
    name: '02-onboarding',
    visibleMarker: 'Toma Control de tu Dinero',
    factory: () => OnboardingScreen(onComplete: () {}),
  ),
  PlayStoreScreenshotScenario(
    name: '03-budget-setup-choice',
    visibleMarker: 'Configura tu presupuesto',
    factory: () => ChangeNotifierProvider(
      create: (_) => BudgetSuggestionsProvider(),
      child: BudgetSetupChoiceScreen(onSetupComplete: () {}),
    ),
  ),
];

void configurePlayStoreScreenshotHarness() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

Widget buildPlayStoreScreenshotShell(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: playStoreScreenshotLocale,
    supportedLocales: const [playStoreScreenshotLocale],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.light,
    home: child,
  );
}
