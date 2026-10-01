import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

import '../integration_test/play_store_screenshots/scenarios.dart';

void main() {
  configurePlayStoreScreenshotHarness();

  test('uses the required ordered scenario names', () {
    expect(
      playStoreScreenshotScenarios.map((scenario) => scenario.name),
      [
        '01-welcome',
        '02-onboarding',
        '03-budget-setup-choice',
      ],
    );
    expect(
      playStoreScreenshotLocale,
      const Locale.fromSubtags(
        languageCode: 'es',
        countryCode: '419',
      ),
    );
  });

  for (final scenario in playStoreScreenshotScenarios) {
    testWidgets('mounts ${scenario.name} without interaction', (tester) async {
      await tester.pumpWidget(
        buildPlayStoreScreenshotShell(scenario.factory()),
      );
      await tester.pump(screenshotReadinessDelay);

      expect(find.text(scenario.visibleMarker), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
