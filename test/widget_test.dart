import 'package:flutter_test/flutter_test.dart';
import 'package:firestore_auth_app/main.dart';
import 'package:firestore_auth_app/services/firestore_auth_service.dart';

void main() {
  setUp(() async {
    await FirestoreAuthService.instance.initialize();
  });

  testWidgets('Renders LoginScreen, fills demo credentials, and authenticates to Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FirestoreAuthApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Login Screen Header
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to access your Firestore User Portal'), findsOneWidget);

    // Verify Sign in button exists
    expect(find.text('Sign In with Firestore'), findsOneWidget);

    // Verify Create Account link exists
    expect(find.text('Create Account'), findsOneWidget);

    // Tap quick-fill demo Admin button
    await tester.tap(find.text('Admin User'));
    await tester.pump();

    // Verify fields populated
    expect(find.text('admin@cloudcorp.io'), findsOneWidget);

    // Tap Sign In with Firestore
    await tester.tap(find.text('Sign In with Firestore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify navigated to Dashboard Screen
    expect(find.text('User Portal Dashboard'), findsOneWidget);
    expect(find.text('Cloud Administrator'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
  });
}
