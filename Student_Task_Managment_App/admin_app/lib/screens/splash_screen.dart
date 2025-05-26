
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
late AnimationController _fadeController;
late AnimationController _scaleController;
late AnimationController _rotateController;
late Animation<double> _fadeAnimation;
late Animation<double> _scaleAnimation;
late Animation<double> _rotateAnimation;

@override
void initState() {
super.initState();
// Fade animation for logo
_fadeController = AnimationController(
duration: const Duration(seconds: 2),
vsync: this,
);
_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
);

// Scale animation for logo
_scaleController = AnimationController(
duration: const Duration(seconds: 2),
vsync: this,
);
_scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
);

// Rotate animation for loader
_rotateController = AnimationController(
duration: const Duration(seconds: 3),
vsync: this,
)..repeat();
_rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
CurvedAnimation(parent: _rotateController, curve: Curves.linear),
);

// Start animations
_fadeController.forward();
_scaleController.forward();

// Navigate after 8 seconds
Future.delayed(const Duration(seconds: 8), () {
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
_fadeController.dispose();
_scaleController.dispose();
_rotateController.dispose();
super.dispose();
}

Widget _buildCustomLogo() {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient: AppColors.primaryGradient,
boxShadow: [
BoxShadow(
color: AppColors.primary.withOpacity(0.5),
blurRadius: 20,
spreadRadius: 5,
),
],
),
child: const Icon(
Icons.admin_panel_settings,
size: 80,
color: Colors.white,
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
decoration: const BoxDecoration(
gradient: AppColors.primaryGradient,
),
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
ScaleTransition(
scale: _scaleAnimation,
child: FadeTransition(
opacity: _fadeAnimation,
child: _buildCustomLogo(),
),
),
const SizedBox(height: 20),
Text(
AppStrings.appName,
style: const TextStyle(
color: Colors.white,
fontSize: 28,
fontWeight: FontWeight.bold,
letterSpacing: 1.5,
shadows: [
Shadow(
blurRadius: 15.0,
color: Colors.black45,
offset: Offset(3.0, 3.0),
),
],
),
),
const SizedBox(height: 20),
RotationTransition(
turns: _rotateAnimation,
child: Container(
width: 50,
height: 50,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient: AppColors.accentGradient,
boxShadow: [
BoxShadow(
color: AppColors.accent.withOpacity(0.4),
blurRadius: 10,
spreadRadius: 2,
),
],
),
),
),
],
),
),
),
);
}
}
