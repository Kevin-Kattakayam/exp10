import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/firestore_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Cloud Firestore
  await FirestoreAuthService.instance.initialize();

  runApp(const FirestoreAuthApp());
}

/// Root widget for the Manual User Login Authentication app.
class FirestoreAuthApp extends StatelessWidget {
  const FirestoreAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore User Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
