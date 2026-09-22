import 'package:flutter/material.dart';
import 'screens/student/student_home.dart';

void main() {
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
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const StudentHome(),
    );
  }
}