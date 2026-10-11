import 'package:flutter_test/flutter_test.dart';
import 'package:money_flow/core/services/budget_onboarding_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

    test('a reconstructed service keeps a skipped user on home without a budget',
        () async {
      SharedPreferences.setMockInitialValues({});
      final originalService = BudgetOnboardingPreferenceService();
      await originalService.skipBudgetSetup(101);
      final reconstructedService = BudgetOnboardingPreferenceService();

      expect(
        await reconstructedService.shouldShowBudgetSetup(
          userId: 101,
          loadHasCurrentBudget: () async => throw StateError('should not run'),
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
    });

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

    test('hides the reminder unless the user skipped without a current budget',
        () async {
      SharedPreferences.setMockInitialValues({});
      final service = BudgetOnboardingPreferenceService();
      await service.skipBudgetSetup(101);

      expect(
        await service.shouldShowReminder(userId: 202, hasCurrentBudget: false),
        isFalse,
      );
      expect(
        await service.shouldShowReminder(userId: 101, hasCurrentBudget: true),
        isFalse,
      );
    });
  });
}
