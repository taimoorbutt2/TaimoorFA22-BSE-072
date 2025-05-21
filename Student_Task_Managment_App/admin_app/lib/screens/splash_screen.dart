import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds:8 ), () {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => authProvider.adminUser != null
                ? const DashboardScreen()
                : const LoginScreen(),
          ),
        );
      } catch (e) {
        debugPrint('Error navigating from splash screen: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1C2526), // Neon Black (AppColors.background)
              Color(0xFF3B00FF), // Neon Indigo (AppColors.primary)
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/welcome.jpeg', height: 100),
                const SizedBox(height: 20),
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SpinKitCircle(
                  color: Colors.white,
                  size: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}