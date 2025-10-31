// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:task_connect_app/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // --- 1. PROVIDE THE REQUIRED PARAMETERS ---
    // We test the logged-out state.
    await tester.pumpWidget(const MyApp(
      isLoggedIn: false,
      userId: 0,
    ));

    // --- 2. UPDATE THE TEST LOGIC ---
    // Verify that our WelcomeScreen shows its text.
    // (This assumes your WelcomeScreen has the text 'Sign In' on a button)
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Verify that the counter text is not present
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
  });
}