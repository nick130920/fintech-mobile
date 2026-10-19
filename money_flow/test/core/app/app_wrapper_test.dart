import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_flow/core/app/app_wrapper.dart';
import 'package:money_flow/core/providers/currency_provider.dart';
import 'package:money_flow/features/auth/data/models/user_model.dart';
import 'package:money_flow/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_flow/features/bank_accounts/presentation/providers/automatic_transactions_provider.dart';
import 'package:money_flow/features/budget/presentation/providers/budget_setup_provider.dart';
import 'package:money_flow/features/budget/presentation/providers/budget_suggestions_provider.dart';
import 'package:money_flow/features/budget/presentation/providers/dashboard_provider.dart';
import 'package:money_flow/features/budget/presentation/providers/expense_provider.dart';
import 'package:money_flow/features/budget/presentation/screens/budget_setup_choice_screen.dart';
import 'package:money_flow/shared/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The platform seam lets tests control actual persistence completion, not cache.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

// No native notification implementation is registered in widget tests.
class _NotificationsPlatform extends FlutterLocalNotificationsPlatform {}

class _AuthProvider extends AuthProvider {
  int userId = 101;
  AuthStatus authStatus = AuthStatus.authenticated;

  @override
  AuthStatus get status => authStatus;

  @override
  UserModel get user => UserModel(
    id: userId,
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.invalid',
    isActive: true,
    isVerified: true,
    locale: 'es',
    timezone: 'UTC',
    createdAt: '2026-01-01',
  );

  void changeUser(int id) {
    userId = id;
    notifyListeners();
  }

  void signOut() {
    authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void signIn() {
    authStatus = AuthStatus.authenticated;
    notifyListeners();
  }
}

class _CurrencyProvider extends CurrencyProvider {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> syncFromUser(String currencyCode) async {}
}

class _BudgetSetupProvider extends BudgetSetupProvider {
  Future<bool> Function() lookup = () async => throw StateError('offline');
  int lookupCount = 0;

  @override
  Future<bool> checkExistingBudget() {
    lookupCount++;
    return lookup();
  }
}

// Keep unrelated dashboard work idle while mounting the real MainScreen.
class _DashboardProvider extends DashboardProvider {
  @override
  bool get isLoading => true;

  @override
  Future<void> initialize() async {}
}

class _ExpenseProvider extends ExpenseProvider {
  @override
  Future<void> initialize() async {}
}

class _AutomaticTransactionsProvider extends AutomaticTransactionsProvider {
  @override
  Future<void> initializeIfNeeded() async {}
}

class _PreferenceStore extends SharedPreferencesStorePlatform {
  final values = <String, Object>{};
  final writes = <String>[];
  Future<bool> Function() save = () async => true;

  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes.add(key);
    final persisted = await save();
    if (persisted) values[key] = value;
    return persisted;
  }
}

void main() {
  late _AuthProvider auth;
  late _BudgetSetupProvider budget;
  late _PreferenceStore preferences;
  late SharedPreferencesStorePlatform originalStore;

  setUpAll(() {
    FlutterLocalNotificationsPlatform.instance = _NotificationsPlatform();
  });

  setUp(() {
    auth = _AuthProvider();
    budget = _BudgetSetupProvider();
    preferences = _PreferenceStore();
    originalStore = SharedPreferencesStorePlatform.instance;
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = preferences;
  });

  tearDown(() {
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = originalStore;
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<CurrencyProvider>(
            create: (_) => _CurrencyProvider(),
          ),
          ChangeNotifierProvider<BudgetSetupProvider>.value(value: budget),
          ChangeNotifierProvider(create: (_) => BudgetSuggestionsProvider()),
          ChangeNotifierProvider<DashboardProvider>(
            create: (_) => _DashboardProvider(),
          ),
          ChangeNotifierProvider<ExpenseProvider>(
            create: (_) => _ExpenseProvider(),
          ),
          ChangeNotifierProvider<AutomaticTransactionsProvider>(
            create: (_) => _AutomaticTransactionsProvider(),
          ),
        ],
        child: const MaterialApp(home: AppWrapper()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  void expectLookupError() {
    expect(find.byType(AppErrorScreen), findsOneWidget);
    expect(find.text('No pudimos verificar tu presupuesto.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Omitir por ahora'), findsOneWidget);
    expect(find.byType(BudgetSetupChoiceScreen), findsNothing);
    expect(find.byType(MainScreen), findsNothing);
  }

  testWidgets(
    'lookup error offers an accessible 48px Omitir por ahora action',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await mount(tester);

      expectLookupError();
      final skip = find.widgetWithText(TextButton, 'Omitir por ahora');
      expect(tester.getSize(skip).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(skip).width, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(skip),
        matchesSemantics(
          label: 'Omitir por ahora',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(preferences.writes, isEmpty);
      semantics.dispose();
    },
  );

  testWidgets('enters MainScreen only after the user skip is persisted', (
    tester,
  ) async {
    final persistence = Completer<bool>();
    preferences.save = () => persistence.future;
    await mount(tester);
    expectLookupError();

    await tester.tap(find.text('Omitir por ahora'));
    await tester.pump();
    expect(preferences.writes, ['flutter.budget_onboarding_skipped_user_101']);
    expect(preferences.values, isEmpty);
    expect(find.byType(MainScreen), findsNothing);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    persistence.complete(true);
    await tester.pump();
    await tester.pump();
    expect(
      preferences.values['flutter.budget_onboarding_skipped_user_101'],
      true,
    );
    expect(find.byType(MainScreen), findsOneWidget);
    expect(budget.lookupCount, 1);
    expect(tester.takeException(), isNull);
  });

  for (final throwsOnSave in [false, true]) {
    testWidgets(
      'persistence ${throwsOnSave ? 'exception' : 'false'} keeps Spanish feedback and lookup retry available',
      (tester) async {
        final semantics = tester.ensureSemantics();
        preferences.save = () async {
          if (throwsOnSave) throw StateError('storage unavailable');
          return false;
        };
        await mount(tester);
        await tester.tap(find.text('Omitir por ahora'));
        await tester.pump();
        await tester.pump();
        expectLookupError();
        final feedback = find.text(
          'No pudimos guardar tu decisión. Inténtalo de nuevo.',
        );
        expect(feedback, findsOneWidget);
        expect(
          tester
              .getSemantics(feedback)
              .getSemanticsData()
              .flagsCollection
              .isLiveRegion,
          isTrue,
        );
        expect(preferences.values, isEmpty);
        semantics.dispose();

        // Failed writes may still update SharedPreferences' in-memory cache.
        // Retrying the lookup must not mistake that cache for saved consent.
        await tester.tap(find.text('Reintentar'));
        await tester.pump();
        await tester.pump();
        expect(budget.lookupCount, 2);
        expectLookupError();

        preferences.save = () async => true;
        await tester.tap(find.text('Omitir por ahora'));
        await tester.pump();
        await tester.pump();
        expect(find.byType(MainScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final throwsOnSave in [false, true]) {
    for (final signOut in [false, true]) {
      testWidgets(
        'failed skip ${throwsOnSave ? 'exception' : 'false'} cannot bypass lookup after ${signOut ? 'same-user sign-in' : 'remount'}',
        (tester) async {
          preferences.save = () async {
            if (throwsOnSave) throw StateError('storage unavailable');
            return false;
          };
          await mount(tester);
          final singleton = await SharedPreferences.getInstance();
          await tester.tap(find.text('Omitir por ahora'));
          await tester.pump();
          await tester.pump();
          expectLookupError();
          expect(preferences.values, isEmpty);
          // Prove the legacy singleton still contains optimistic consent.
          expect(
            singleton.getBool('budget_onboarding_skipped_user_101'),
            isTrue,
          );

          if (signOut) {
            auth.signOut();
            await tester.pump();
            auth.signIn();
            await tester.pump();
          } else {
            await tester.pumpWidget(const SizedBox.shrink());
            await mount(tester);
          }
          await tester.pump();
          await tester.pump();

          expect(await SharedPreferences.getInstance(), same(singleton));
          expect(budget.lookupCount, 2);
          expectLookupError();
          expect(preferences.writes, [
            'flutter.budget_onboarding_skipped_user_101',
          ]);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('lookup retry can recover without writing skip consent', (
    tester,
  ) async {
    await mount(tester);
    budget.lookup = () async => true;
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(preferences.writes, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmed absence of budget still offers setup', (tester) async {
    budget.lookup = () async => false;
    await mount(tester);
    expect(find.byType(BudgetSetupChoiceScreen), findsOneWidget);
    expect(find.text('Omitir por ahora'), findsOneWidget);
    expect(find.byType(AppErrorScreen), findsNothing);
    expect(find.byType(MainScreen), findsNothing);
    expect(preferences.writes, isEmpty);
  });

  for (final lookupThrows in [false, true]) {
    testWidgets(
      'user change ignores stale lookup ${lookupThrows ? 'error' : 'success'}',
      (tester) async {
        final lookup = Completer<bool>();
        budget.lookup = () => lookup.future;
        await mount(tester);
        expect(find.byType(AppLoadingScreen), findsOneWidget);

        auth.changeUser(202);
        budget.lookup = () async => throw StateError('new user offline');
        await tester.pump();
        await tester.pump();
        if (lookupThrows) {
          lookup.completeError(StateError('old user offline'));
        } else {
          lookup.complete(true);
        }
        await tester.pump();
        await tester.pump();
        expectLookupError();
        expect(preferences.writes, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final signOut in [false, true]) {
    testWidgets(
      'stale error action cannot persist after ${signOut ? 'sign out' : 'user change'}',
      (tester) async {
        await mount(tester);
        expectLookupError();
        if (signOut) {
          auth.signOut();
        } else {
          auth.changeUser(202);
        }
        // The old action can still run before the next frame replaces it.
        final skip = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Omitir por ahora'),
        );
        skip.onPressed!();
        expect(preferences.writes, isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(preferences.writes, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final persisted in [false, true]) {
    testWidgets(
      'user change while skip is pending ignores stale result $persisted',
      (tester) async {
        final persistence = Completer<bool>();
        preferences.save = () => persistence.future;
        await mount(tester);
        await tester.tap(find.text('Omitir por ahora'));
        await tester.pump();
        expect(preferences.writes, [
          'flutter.budget_onboarding_skipped_user_101',
        ]);

        auth.changeUser(202);
        await tester.pump();
        await tester.pump();
        persistence.complete(persisted);
        await tester.pump();
        await tester.pump();
        expectLookupError();
        expect(preferences.writes, [
          'flutter.budget_onboarding_skipped_user_101',
        ]);
        expect(
          preferences.values['flutter.budget_onboarding_skipped_user_202'],
          isNull,
        );
        expect(
          find.text('No pudimos guardar tu decisión. Inténtalo de nuevo.'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('disposed handler ignores pending skip result $persisted', (
      tester,
    ) async {
      final persistence = Completer<bool>();
      preferences.save = () => persistence.future;
      await mount(tester);
      await tester.tap(find.text('Omitir por ahora'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      persistence.complete(persisted);
      await tester.pump();
      expect(find.byType(MainScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('previously skipped users still bypass the initial lookup', (
    tester,
  ) async {
    preferences.values['flutter.budget_onboarding_skipped_user_101'] = true;
    await mount(tester);

    expect(find.byType(MainScreen), findsOneWidget);
    expect(budget.lookupCount, 0);
    expect(preferences.writes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
