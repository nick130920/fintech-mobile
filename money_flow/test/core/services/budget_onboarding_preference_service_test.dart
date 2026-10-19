import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/core/services/budget_onboarding_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Exercise the real legacy cache separately from the durable platform store.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _PreferenceStore extends SharedPreferencesStorePlatform {
  final values = <String, Object>{};
  bool failReads = false;
  bool throwsOnSave = false;

  @override
  Future<Map<String, Object>> getAll() async {
    if (failReads) throw StateError('storage unavailable');
    return Map.of(values);
  }

  @override
  Future<bool> clear() async => throw StateError('must not clear preferences');

  @override
  Future<bool> remove(String key) async =>
      throw StateError('must not remove preferences');

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (throwsOnSave) throw StateError('write unavailable');
    return false;
  }
}

void main() {
  group('durable startup consent', () {
    late SharedPreferencesStorePlatform originalStore;
    late _PreferenceStore store;

    setUp(() {
      originalStore = SharedPreferencesStorePlatform.instance;
      store = _PreferenceStore();
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = store;
    });

    tearDown(() {
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = originalStore;
    });

    for (final throwsOnSave in [false, true]) {
      test(
        'failed write $throwsOnSave is not consent for a new service',
        () async {
          store.throwsOnSave = throwsOnSave;
          store.values['flutter.unrelated_setting'] = 'preserve';
          store.values['flutter.budget_onboarding_skipped_user_202'] = true;
          final service = BudgetOnboardingPreferenceService();
          if (throwsOnSave) {
            await expectLater(service.skipBudgetSetup(101), throwsStateError);
          } else {
            expect(await service.skipBudgetSetup(101), isFalse);
          }
          final singleton = await SharedPreferences.getInstance();
          expect(
            singleton.getBool('budget_onboarding_skipped_user_101'),
            isTrue,
          );
          var lookupCount = 0;

          expect(
            await BudgetOnboardingPreferenceService().shouldShowBudgetSetup(
              userId: 101,
              loadHasCurrentBudget: () async {
                lookupCount++;
                return false;
              },
            ),
            isTrue,
          );
          expect(lookupCount, 1);
          expect(await SharedPreferences.getInstance(), same(singleton));
          expect(singleton.getString('unrelated_setting'), 'preserve');
          expect(
            singleton.getBool('budget_onboarding_skipped_user_202'),
            isTrue,
          );
          expect(store.values, {
            'flutter.unrelated_setting': 'preserve',
            'flutter.budget_onboarding_skipped_user_202': true,
          });
        },
      );
    }

    for (final hasBudget in [false, true, null]) {
      test(
        'reload failure verifies budget result $hasBudget instead of cached consent',
        () async {
          store.values['flutter.budget_onboarding_skipped_user_101'] = true;
          await SharedPreferences.getInstance();
          store.failReads = true;
          var lookupCount = 0;
          final decision = BudgetOnboardingPreferenceService()
              .shouldShowBudgetSetup(
                userId: 101,
                loadHasCurrentBudget: () async {
                  lookupCount++;
                  if (hasBudget == null) throw StateError('budget offline');
                  return hasBudget;
                },
              );

          if (hasBudget == null) {
            await expectLater(decision, throwsStateError);
          } else {
            expect(await decision, !hasBudget);
          }
          expect(lookupCount, 1);
        },
      );
    }
  });

  group('BudgetOnboardingPreferenceService', () {
    test('persists a skipped decision for the authenticated user', () async {
      SharedPreferences.setMockInitialValues({});
      final service = BudgetOnboardingPreferenceService();

      expect(await service.skipBudgetSetup(101), isTrue);
      expect(await service.hasSkippedBudgetSetup(101), isTrue);
    });

    test('skipped startup does not invoke the budget lookup', () async {
      SharedPreferences.setMockInitialValues({});
      final service = BudgetOnboardingPreferenceService();
      await service.skipBudgetSetup(101);
      var lookupCount = 0;

      final needsSetup = await service.shouldShowBudgetSetup(
        userId: 101,
        loadHasCurrentBudget: () async {
          lookupCount++;
          throw StateError('offline budget lookup should not run');
        },
      );

      expect(needsSetup, isFalse);
      expect(lookupCount, 0);
    });

    test(
      'a reconstructed service keeps a skipped user on home without a budget',
      () async {
        SharedPreferences.setMockInitialValues({});
        final originalService = BudgetOnboardingPreferenceService();
        await originalService.skipBudgetSetup(101);
        final reconstructedService = BudgetOnboardingPreferenceService();

        expect(
          await reconstructedService.shouldShowBudgetSetup(
            userId: 101,
            loadHasCurrentBudget: () async =>
                throw StateError('should not run'),
          ),
          isFalse,
        );
        expect(
          await reconstructedService.shouldShowReminder(
            userId: 101,
            hasCurrentBudget: false,
          ),
          isTrue,
        );
      },
    );

    test('does not share a skipped decision with another user', () async {
      SharedPreferences.setMockInitialValues({});
      final service = BudgetOnboardingPreferenceService();
      await service.skipBudgetSetup(101);

      expect(await service.hasSkippedBudgetSetup(202), isFalse);
      expect(
        await service.shouldShowBudgetSetup(
          userId: 202,
          loadHasCurrentBudget: () async => false,
        ),
        isTrue,
      );
    });

    test('checks the budget for a user who has not skipped', () async {
      SharedPreferences.setMockInitialValues({});
      final service = BudgetOnboardingPreferenceService();
      var lookupCount = 0;

      final needsSetup = await service.shouldShowBudgetSetup(
        userId: 202,
        loadHasCurrentBudget: () async {
          lookupCount++;
          return true;
        },
      );

      expect(needsSetup, isFalse);
      expect(lookupCount, 1);
    });

    test(
      'hides the reminder unless the user skipped without a current budget',
      () async {
        SharedPreferences.setMockInitialValues({});
        final service = BudgetOnboardingPreferenceService();
        await service.skipBudgetSetup(101);

        expect(
          await service.shouldShowReminder(
            userId: 202,
            hasCurrentBudget: false,
          ),
          isFalse,
        );
        expect(
          await service.shouldShowReminder(userId: 101, hasCurrentBudget: true),
          isFalse,
        );
      },
    );
  });
}
