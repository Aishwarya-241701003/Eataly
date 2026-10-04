import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  WebViewController? _webController;
  bool _hasNavigated = false;
  Timer? _animationTimer;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // Enable immersive full-screen mode on mobile devices
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _startTimers();
    _initSplashView();
  }

  void _startTimers() {
    // Primary timer matching the ~3.5s duration of the HTML intro animation
    _animationTimer = Timer(const Duration(milliseconds: 3600), () {
      _navigateToLogin();
    });

    // Safety fallback timer if loading stalls
    _fallbackTimer = Timer(const Duration(seconds: 6), () {
      debugPrint('Splash fallback timer reached. Navigating to login.');
      _navigateToLogin();
    });
  }

  Future<void> _initSplashView() async {
    try {
      final htmlContent = await rootBundle.loadString('assets/html/splash.html');

      final controller = WebViewController();

      // Features only available/supported on mobile platforms (Android/iOS)
      if (!kIsWeb) {
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFF1D0045))
          ..addJavaScriptChannel(
            'SplashChannel',
            onMessageReceived: (JavaScriptMessage message) {
              _navigateToLogin();
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (error) {
                debugPrint('Splash WebView error: ${error.description}');
              },
            ),
          );
      }

      await controller.loadHtmlString(htmlContent);

      if (mounted) {
        setState(() {
          _webController = controller;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize HTML splash: $e');
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _animationTimer?.cancel();
    _fallbackTimer?.cancel();

    // Restore standard system UI bars on mobile
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    // Replace the splash screen route so user cannot navigate back
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _fallbackTimer?.cancel();
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D0045),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _navigateToLogin,
        child: SizedBox.expand(
          child: _webController != null
              ? WebViewWidget(controller: _webController!)
              : const SizedBox.expand(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF7A05C9),
                          Color(0xFF4A0A8C),
                          Color(0xFF26005A),
                          Color(0xFF1D0045),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
