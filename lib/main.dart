import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(const EatalyApp());
}

class EatalyApp extends StatelessWidget {
  const EatalyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eataly',
      theme: ThemeData(
        fontFamily: 'sans-serif',
        fontFamilyFallback: const ['Arial', 'Helvetica', 'sans-serif'],
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}