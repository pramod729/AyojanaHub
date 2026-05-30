import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

// Driver for `flutter drive` web e2e. Saves screenshots requested by the test
// (binding.takeScreenshot) into e2e/shots so they can be stitched into a video.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory('e2e/shots');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      await File('e2e/shots/$name.png').writeAsBytes(bytes);
      return true;
    },
  );
}
