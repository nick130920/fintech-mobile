import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'play_store_screenshots/scenarios.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  configurePlayStoreScreenshotHarness();

  setUpAll(() async {
    await binding.convertFlutterSurfaceToImage();
  });

  for (final scenario in playStoreScreenshotScenarios) {
    testWidgets('captures ${scenario.name}', (tester) async {
      await tester.pumpWidget(
        buildPlayStoreScreenshotShell(scenario.factory()),
      );
      await tester.pump(screenshotReadinessDelay);

      expect(find.text(scenario.visibleMarker), findsOneWidget);
      await binding.takeScreenshot(scenario.name);
    });
  }
}
