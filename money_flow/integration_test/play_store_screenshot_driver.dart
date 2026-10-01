import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

const _expectedScreenshotNames = <String>[
  '01-welcome',
  '02-onboarding',
  '03-budget-setup-choice',
];

Future<void> main() async {
  final outputPath = Platform.environment['PLAY_STORE_SCREENSHOT_OUTPUT'];
  if (outputPath == null || outputPath.isEmpty) {
    throw StateError(
      'PLAY_STORE_SCREENSHOT_OUTPUT must name an existing screenshot directory.',
    );
  }

  final outputDirectory = Directory(outputPath);
  if (!await outputDirectory.exists()) {
    throw StateError(
      'Screenshot output directory does not exist: ${outputDirectory.path}',
    );
  }

  var nextScreenshotIndex = 0;
  await integrationDriver(
    onScreenshot: (screenshotName, screenshotBytes, [args]) async {
      if (nextScreenshotIndex >= _expectedScreenshotNames.length) {
        throw StateError('Received unexpected screenshot: $screenshotName');
      }

      final expectedName = _expectedScreenshotNames[nextScreenshotIndex];
      if (screenshotName != expectedName) {
        throw StateError(
          'Expected screenshot $expectedName, received $screenshotName.',
        );
      }
      if (screenshotBytes.isEmpty) {
        throw StateError('Screenshot data is empty: $screenshotName');
      }

      final screenshotFile = File(
        '${outputDirectory.path}${Platform.pathSeparator}$expectedName.png',
      );
      await screenshotFile.writeAsBytes(screenshotBytes, flush: true);
      nextScreenshotIndex += 1;
      return true;
    },
  );

  if (nextScreenshotIndex != _expectedScreenshotNames.length) {
    final missingScreenshots = _expectedScreenshotNames
        .skip(nextScreenshotIndex)
        .join(', ');
    throw StateError('Missing expected screenshots: $missingScreenshots');
  }
}
