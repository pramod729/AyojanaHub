import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ayojana_hub/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // pump in 1s slices so async Firebase/network work can settle
  Future<void> settle(WidgetTester t, [int seconds = 8]) async {
    for (var i = 0; i < seconds; i++) {
      await t.pump(const Duration(seconds: 1));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await t.pump();
    await binding.takeScreenshot(name);
  }

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text).first;
    await t.ensureVisible(f);
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(f);
    await settle(t, 2);
  }

  testWidgets('customer journey: login, create event, browse, bookings', (t) async {
    try { await FirebaseAuth.instance.signOut(); } catch (_) {}
    app.main();
    await settle(t, 12); // splash + firebase init -> login screen

    // ---- LOGIN ----
    expect(find.text('Sign In'), findsWidgets);
    await shot(t, 'c01_login');
    await t.enterText(find.byType(TextField).at(0), 'customer@ayojanahub.test');
    await t.pump(const Duration(milliseconds: 300));
    await t.enterText(find.byType(TextField).at(1), 'Test@1234');
    await t.pump(const Duration(milliseconds: 300));
    await shot(t, 'c02_login_filled');
    await t.tap(find.text('Sign In'));
    await settle(t, 10); // firebase auth + route to home
    await shot(t, 'c03_home');

    // ---- CREATE EVENT ----
    await tapText(t, 'Create Event');
    await settle(t, 3);
    await shot(t, 'c04_create_form');
    await t.tap(find.text('Wedding').first); // event type chip
    await t.pump(const Duration(milliseconds: 400));
    final fields = find.byType(TextField);
    await t.enterText(fields.at(0), 'Grand Wedding 2026'); // event name
    await t.enterText(fields.at(1), 'Kathmandu');          // location
    await t.enterText(fields.at(2), '250');                // guests
    await t.enterText(fields.at(3), '700000');             // budget
    await t.enterText(fields.at(4), 'Catering, photography and decoration for 250 guests.');
    await t.pump(const Duration(milliseconds: 400));
    await shot(t, 'c05_form_filled');
    await tapText(t, 'Create Event & Get Proposals');
    await settle(t, 6);
    await shot(t, 'c06_event_created');

    // ---- MY EVENTS ----
    await tapText(t, 'Events'); // bottom nav
    await settle(t, 4);
    await shot(t, 'c07_my_events');

    // ---- MY BOOKINGS ----
    await tapText(t, 'Bookings'); // bottom nav
    await settle(t, 4);
    await shot(t, 'c08_bookings');

    // ---- PROFILE ----
    await tapText(t, 'Profile');
    await settle(t, 3);
    await shot(t, 'c09_profile');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
