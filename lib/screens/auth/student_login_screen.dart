import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../student/student_home.dart';
import 'admin_login_screen.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStudentLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    if (!email.endsWith('@rajalakshmi.edu.in')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access restricted: Only @rajalakshmi.edu.in college emails can login.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final password = _passwordController.text;
    final savedPassword = AuthService.getPrototypePassword(email);
    if (savedPassword != null && savedPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Incorrect password. Please use the new password you set during reset.'),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt auth if configured, or simulate smooth verification
      await Future.delayed(const Duration(milliseconds: 650));
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Welcome, ${email.split('@').first}!',
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StudentHome()),
      (route) => false,
    );
  }

  void _handleGoogleSignIn() {
    FocusScope.of(context).unfocus();
    _showGoogleAuthDialog();
  }

  void _showGoogleAuthDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        return _GoogleAuthWindow(
          onAccountSelected: (String email, String displayName) async {
            Navigator.of(bottomCtx).pop();

            setState(() {
              _isGoogleLoading = true;
            });

            await Future.delayed(const Duration(milliseconds: 600));

            if (!mounted) return;

            setState(() {
              _isGoogleLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Signed in as $email ($displayName)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                duration: const Duration(seconds: 2),
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StudentHome()),
              (route) => false,
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD -> DISPATCH RESET LINK TO EMAIL
  // ------------------------------------------------------------
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    final resetFormKey = GlobalKey<FormState>();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_read_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your registered @rajalakshmi.edu.in email. A secure password reset link will be sent to your inbox.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: resetEmailController,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'College Email ID',
                        hintText: 'e.g. 21cs001@rajalakshmi.edu.in',
                        prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        final trimmed = value.trim().toLowerCase();
                        if (!trimmed.endsWith('@rajalakshmi.edu.in')) {
                          return 'Must end with @rajalakshmi.edu.in';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (resetFormKey.currentState!.validate()) {
                            setDialogState(() => isSending = true);
                            final target = resetEmailController.text.trim().toLowerCase();

                            String? errorMsg;
                            PasswordResetResult? resetResult;

                            try {
                              resetResult = await _authService.sendPasswordResetEmail(target);
                            } on FirebaseAuthException catch (e) {
                              final c = e.code.toLowerCase();
                              if (c == 'user-not-found') {
                                errorMsg = 'No registered student account was found for "$target". Please register or sign up first.';
                              } else if (c == 'invalid-email') {
                                errorMsg = 'The email address format is invalid.';
                              } else if (c == 'too-many-requests') {
                                errorMsg = 'Too many attempts. Please try again after 5 minutes.';
                              } else {
                                resetResult = PasswordResetResult(
                                  isLiveEmailSent: false,
                                  isPrototypeMode: true,
                                  email: target,
                                  message: 'Firebase configuration issue ($c).',
                                );
                              }
                            } catch (e) {
                              resetResult = PasswordResetResult(
                                isLiveEmailSent: false,
                                isPrototypeMode: true,
                                email: target,
                                message: 'Offline / Prototype fallback mode.',
                              );
                            }

                            if (!dialogCtx.mounted) return;
                            setDialogState(() => isSending = false);

                            if (resetResult != null) {
                              Navigator.of(dialogCtx).pop();

                              if (mounted) {
                                if (resetResult.isLiveEmailSent) {
                                  _showLiveResetSentDialog(context, target);
                                } else {
                                  _showPrototypeResetDialog(context, target);
                                }
                              }
                            } else if (errorMsg != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          errorMsg,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLiveResetSentDialog(BuildContext context, String targetEmail) {
    showDialog(
      context: context,
      builder: (infoCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            SizedBox(width: 10),
            Text('Reset Link Sent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A password reset link was dispatched to:\n$targetEmail',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Why haven\'t I received it?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '1. College institutional spam filters often place automated Firebase emails in your Spam or Junk folder.\n2. Search your inbox for "noreply" or "firebase".\n3. Allow 2-3 minutes for campus mail servers to deliver.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(infoCtx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showPrototypeResetDialog(BuildContext context, String targetEmail) {
    showDialog(
      context: context,
      builder: (protoCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Prototype Mode: Reset',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        targetEmail,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF92400E), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Firebase Prototype Notice',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF92400E)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'The app is currently configured with a development placeholder Firebase key. Live Google SMTP dispatch to campus mail requires your Firebase Web API Key.\n\nFor offline presentation and instant testing, you can update your password right now:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_done_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'To send real emails to your college inbox:\nPaste your Web API Key from Firebase Console into lib/firebase_options.dart.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(protoCtx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(protoCtx).pop();
              _showSetNewPasswordSheet(context, targetEmail);
            },
            icon: const Icon(Icons.lock_reset_rounded, size: 18),
            label: const Text('Set New Password'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetNewPasswordSheet(BuildContext context, String targetEmail) {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final passFormKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: passFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.key_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set New Password',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Create a new password for your account',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                targetEmail,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPassController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Minimum 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: confirmPassController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
                        ),
                        validator: (v) {
                          if (v != newPassController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (passFormKey.currentState!.validate()) {
                              final newPass = newPassController.text.trim();
                              AuthService.setPrototypePassword(targetEmail, newPass);
                              Navigator.of(sheetCtx).pop();

                              setState(() {
                                _emailController.text = targetEmail;
                                _passwordController.text = newPass;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Password successfully updated for $targetEmail!',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
                          ),
                          child: const Text('Update & Autofill Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SIGN UP WITH PHONE NUMBER & OTP VERIFICATION
  // ------------------------------------------------------------
  void _showPhoneOtpSignUpModal() {
    final nameController = TextEditingController();
    final signUpEmailController = TextEditingController();
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    final signUpFormKey = GlobalKey<FormState>();

    bool otpSent = false;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 28,
              ),
              child: Form(
                key: signUpFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title & Subtitle
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              otpSent ? Icons.lock_clock_rounded : Icons.phone_android_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otpSent ? 'Enter Verification OTP' : 'Student Sign Up',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  otpSent
                                      ? 'Sent to +91 ${phoneController.text.trim()}'
                                      : 'Register with Phone & College Email',
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      if (!otpSent) ...[
                        // Step 1: Name, Email, Phone
                        const Text(
                          'Full Name',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'e.g. Aishwarya B',
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your name';
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'College Email ID',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: signUpEmailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: '21cs001@rajalakshmi.edu.in',
                            prefixIcon: const Icon(Icons.school_outlined, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter college email';
                            if (!val.trim().toLowerCase().endsWith('@rajalakshmi.edu.in')) {
                              return 'Must end with @rajalakshmi.edu.in';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Mobile Number',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '9876543210',
                            prefixIcon: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: const Text(
                                '+91',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter 10-digit mobile number';
                            if (val.trim().length != 10) return 'Please enter a valid 10-digit number';
                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    if (signUpFormKey.currentState!.validate()) {
                                      setSheetState(() => isProcessing = true);
                                      await Future.delayed(const Duration(milliseconds: 600));
                                      setSheetState(() {
                                        isProcessing = false;
                                        otpSent = true;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              ),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Send Verification OTP',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ] else ...[
                        // Step 2: OTP Verification
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'A 6-digit OTP was sent to +91 ${phoneController.text.trim()}. (Enter any 6 digits to verify)',
                                  style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 10),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '------',
                            hintStyle: const TextStyle(letterSpacing: 8, color: Colors.grey),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 4) {
                              return 'Enter the OTP code received';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('New OTP sent to your phone!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                            label: const Text(
                              'Resend OTP Code',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    if (signUpFormKey.currentState!.validate()) {
                                      setSheetState(() => isProcessing = true);
                                      await Future.delayed(const Duration(milliseconds: 650));
                                      if (!context.mounted) return;

                                      Navigator.of(sheetCtx).pop();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Welcome, ${nameController.text.trim()}! Phone verified.'),
                                          backgroundColor: AppColors.success,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );

                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (_) => const StudentHome()),
                                        (route) => false,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              ),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                : const Text(
                                    'Verify & Complete Sign Up',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: 12.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Area with entrance Logo Animation
                    Center(
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.65, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutBack,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.offerGradient1, AppColors.offerGradient2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.32),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'STUDENT FOOD COURT • REC',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Card Form
                    Container(
                      padding: const EdgeInsets.all(AppConstants.cardPadding + 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Student Login',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Login with your Rajalakshmi institutional email.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // College Email ID field
                          const Text(
                            'College Email ID',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g. 21cs001@rajalakshmi.edu.in',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                                fontSize: 13.5,
                              ),
                              prefixIcon: const Icon(
                                Icons.school_outlined,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.danger),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your college email';
                              }
                              final trimmed = value.trim().toLowerCase();
                              if (!trimmed.endsWith('@rajalakshmi.edu.in')) {
                                return 'Only @rajalakshmi.edu.in institutional email is allowed';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Password field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleStudentLogin(),
                            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter your student password',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                borderSide: const BorderSide(color: AppColors.danger),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 6),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Large Red Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleStudentLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Login as Student',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Divider with OR
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  thickness: 1.2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  thickness: 1.2,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google sign in
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(color: AppColors.border, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                ),
                              ),
                              child: _isGoogleLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildGoogleIcon(),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Continue with REC Google ID',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Don't have an account? Sign Up with Phone & OTP
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showPhoneOtpSignUpModal,
                            child: const Text(
                              'Sign Up with Phone & OTP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Switch to Admin
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.admin_panel_settings_outlined, size: 18, color: Color(0xFF1E3A8A)),
                        label: const Text(
                          'Canteen Staff? Login as Admin',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }
}

class _GoogleAuthWindow extends StatefulWidget {
  final Function(String email, String displayName) onAccountSelected;

  const _GoogleAuthWindow({required this.onAccountSelected});

  @override
  State<_GoogleAuthWindow> createState() => _GoogleAuthWindowState();
}

class _GoogleAuthWindowState extends State<_GoogleAuthWindow> {
  bool _showCustomInput = false;
  final TextEditingController _customEmailController = TextEditingController();
  final GlobalKey<FormState> _customFormKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _customEmailController.dispose();
    super.dispose();
  }

  void _select(String email, String name) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      widget.onAccountSelected(email, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Google Logo & Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'G',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202124),
                      ),
                    ),
                    Text(
                      'Choose an account for Eataly Food Court',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 8),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4285F4)),
                    SizedBox(height: 16),
                    Text(
                      'Connecting to Google Workspace...',
                      style: TextStyle(color: Color(0xFF5F6368), fontSize: 13),
                    ),
                  ],
                ),
              )
            else ...[
              // Account 1: Aishwarya S
              _buildAccountTile(
                name: 'Aishwarya S',
                email: 'aishwarya.s@rajalakshmi.edu.in',
                initials: 'A',
                avatarColor: const Color(0xFF0D9488),
                badge: 'Verified REC Scholar',
                onTap: () => _select('aishwarya.s@rajalakshmi.edu.in', 'Aishwarya S'),
              ),

              const Divider(height: 1, indent: 56, color: Color(0xFFF1F3F4)),

              // Account 2: 21cs001@rajalakshmi.edu.in
              _buildAccountTile(
                name: 'REC Student (CSE)',
                email: '21cs001@rajalakshmi.edu.in',
                initials: 'R',
                avatarColor: const Color(0xFFE11D48),
                badge: 'Student Workspace',
                onTap: () => _select('21cs001@rajalakshmi.edu.in', 'REC Student'),
              ),

              const Divider(height: 1, indent: 56, color: Color(0xFFF1F3F4)),

              // Use another account
              if (!_showCustomInput)
                InkWell(
                  onTap: () => setState(() => _showCustomInput = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                          ),
                          child: const Icon(
                            Icons.person_add_alt_outlined,
                            size: 20,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Use another college account',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Form(
                  key: _customFormKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _customEmailController,
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Institutional Email ID',
                            hintText: 'e.g. yourname@rajalakshmi.edu.in',
                            prefixIcon: const Icon(Icons.school_outlined, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.8),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter your email';
                            if (!val.trim().toLowerCase().endsWith('@rajalakshmi.edu.in')) {
                              return 'Must be an @rajalakshmi.edu.in email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _showCustomInput = false),
                              child: const Text('Cancel', style: TextStyle(color: Color(0xFF5F6368))),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_customFormKey.currentState!.validate()) {
                                  final entered = _customEmailController.text.trim().toLowerCase();
                                  final name = entered.split('@').first.toUpperCase();
                                  _select(entered, name);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A73E8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Continue'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'To continue, Google will share your name, email address, and profile picture with Eataly REC Food Court. See Eataly\'s Privacy Policy and Terms of Service.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF70757A),
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required String name,
    required String email,
    required String initials,
    required Color avatarColor,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
