import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

class PasswordResetResult {
  final bool isLiveEmailSent;
  final bool isPrototypeMode;
  final String email;
  final String message;

  const PasswordResetResult({
    required this.isLiveEmailSent,
    required this.isPrototypeMode,
    required this.email,
    required this.message,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // In-memory credential store for simulated / prototype testing
  static final Map<String, String> _prototypePasswords = {};

  static void setPrototypePassword(String email, String password) {
    _prototypePasswords[email.trim().toLowerCase()] = password;
  }

  static String? getPrototypePassword(String email) {
    return _prototypePasswords[email.trim().toLowerCase()];
  }

  static bool get isPlaceholderConfig {
    try {
      final key = DefaultFirebaseOptions.currentPlatform.apiKey;
      return key.contains('placeholder') || key.length < 20;
    } catch (_) {
      return true;
    }
  }

  AuthService._internal() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  String get userId => _auth.currentUser?.uid ?? 'guest_student';

  String get userEmail => _auth.currentUser?.email ?? 'student@rec.edu';

  String get displayName => _auth.currentUser?.displayName ?? 'Student User';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();

    if (isPlaceholderConfig) {
      debugPrint('AuthService: Placeholder API key detected. Simulating signIn for $trimmed.');
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
      return null;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmed,
        password: password,
      );
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code == 'api-key-not-valid' || msg.contains('api key not valid')) {
        debugPrint('AuthService: Invalid API key returned by Firebase. Falling back to prototype simulation mode.');
        notifyListeners();
        return null;
      }
      debugPrint('AuthService signIn error: $e');
      rethrow;
    } catch (e) {
      debugPrint('AuthService signIn error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    final trimmed = email.trim();

    if (isPlaceholderConfig) {
      debugPrint('AuthService: Placeholder API key detected. Simulating signUp for $trimmed.');
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
      return null;
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmed,
        password: password,
      );
      if (name != null && credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code == 'api-key-not-valid' || msg.contains('api key not valid')) {
        debugPrint('AuthService: Invalid API key returned by Firebase. Falling back to prototype simulation mode.');
        notifyListeners();
        return null;
      }
      debugPrint('AuthService signUp error: $e');
      rethrow;
    } catch (e) {
      debugPrint('AuthService signUp error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      notifyListeners();
      return credential;
    } catch (e) {
      debugPrint('AuthService anonymous sign-in error: $e');
      rethrow;
    }
  }

  Future<PasswordResetResult> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();

    if (isPlaceholderConfig) {
      debugPrint('AuthService: Placeholder API key detected. Using Prototype Reset for $trimmed');
      await Future.delayed(const Duration(milliseconds: 650));
      return PasswordResetResult(
        isLiveEmailSent: false,
        isPrototypeMode: true,
        email: trimmed,
        message: 'Prototype mode active (placeholder API key in firebase_options.dart).',
      );
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
      debugPrint('AuthService: Password reset email successfully dispatched to $trimmed');
      return PasswordResetResult(
        isLiveEmailSent: true,
        isPrototypeMode: false,
        email: trimmed,
        message: 'A real password reset link has been dispatched to $trimmed',
      );
    } on FirebaseAuthException catch (e) {
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();

      // If configuration mismatch, invalid API key, disabled provider, or project not found
      if (code == 'api-key-not-valid' ||
          code == 'invalid-api-key' ||
          code == 'configuration-not-found' ||
          code == 'operation-not-allowed' ||
          code == 'internal-error' ||
          code.contains('config') ||
          msg.contains('configuration') ||
          msg.contains('internal error') ||
          msg.contains('api key not valid') ||
          msg.contains('api_key_invalid') ||
          msg.contains('unregistered')) {
        debugPrint('AuthService: Firebase configuration / key issue [$code: $msg]. Falling back to Prototype Mode.');
        return PasswordResetResult(
          isLiveEmailSent: false,
          isPrototypeMode: true,
          email: trimmed,
          message: 'Firebase configuration issue ($code). Switched to Prototype Reset.',
        );
      }

      debugPrint('AuthService sendPasswordResetEmail FirebaseAuthException [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('config') ||
          str.contains('internal error') ||
          str.contains('api key not valid') ||
          str.contains('api_key_invalid')) {
        return PasswordResetResult(
          isLiveEmailSent: false,
          isPrototypeMode: true,
          email: trimmed,
          message: 'Firebase configuration issue. Switched to Prototype Reset.',
        );
      }
      debugPrint('AuthService sendPasswordResetEmail generic error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService signOut error: $e');
      rethrow;
    }
  }
}

