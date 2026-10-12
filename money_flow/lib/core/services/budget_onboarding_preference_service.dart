import 'package:shared_preferences/shared_preferences.dart';

/// Stores the optional budget-onboarding decision separately for each user.
class BudgetOnboardingPreferenceService {
  static const _keyPrefix = 'budget_onboarding_skipped_user_';

  Future<bool> skipBudgetSetup(int userId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(_keyFor(userId), true);
  }

  Future<bool> hasSkippedBudgetSetup(int userId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_keyFor(userId)) ?? false;
  }

  /// Resolves the startup gate without looking up a budget for skipped users.
  Future<bool> shouldShowBudgetSetup({
    required int userId,
    required Future<bool> Function() loadHasCurrentBudget,
  }) async {
    if (await hasSkippedBudgetSetup(userId)) return false;
    return !(await loadHasCurrentBudget());
  }

  Future<bool> shouldShowReminder({
    required int userId,
    required bool hasCurrentBudget,
  }) async {
    return !hasCurrentBudget && await hasSkippedBudgetSetup(userId);
  }

  String _keyFor(int userId) => '$_keyPrefix$userId';
}
