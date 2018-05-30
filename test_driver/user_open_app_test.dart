import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('open app test group', () {
    FlutterDriver driver;

    setUpAll(() async {
      // Connects to the app
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        // Closes the connection
        driver.close();
      }
    });

    test('open app', () async {
      // Check the title is there
      SerializableFinder title = find.text('Heist');
      await driver.waitFor(title);

      // Find the enter room form
      SerializableFinder enterRoomForm = find.byValueKey('_enterRoomFormKey');
      expect(enterRoomForm, isNotNull);
    });

    test('create room', () async {
      // Find the create room button
      SerializableFinder createRoomButton = find.text('CREATE ROOM');
      expect(createRoomButton, isNotNull);

      // Tap the button and wait until it disappears
      await driver.tap(createRoomButton);
      await driver.waitForAbsent(createRoomButton);

      // Check that the new screen appears
      expect(find.text('CHANGE ROOM'), isNotNull);

      // TODO get room code when it is displayed on screen,
      // check that the room exists in the db and delete it
    });
  });
}
