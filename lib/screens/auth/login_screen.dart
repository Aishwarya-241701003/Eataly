import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

export 'admin_login_screen.dart';
export 'role_selection_screen.dart';
export 'student_login_screen.dart';

/// Backward-compatible alias for existing imports
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleSelectionScreen();
  }
}
