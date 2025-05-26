import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import '../utils/constants.dart';
import '../utils/particle_animation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late GridFlow _gridFlow;

  @override
  void initState() {
    super.initState();
    // Initialize grid flow
    _gridFlow = GridFlow();
    // Animation controller for grid movement
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.adminUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Animated Grid Flow Background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Update grid flow
              _gridFlow.update(_animationController.value);
              return CustomPaint(
                painter: GridFlowPainter(_gridFlow),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              );
            },
          ),
          // Form Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Admin Login',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            blurRadius: 10,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          if (authProvider.error != null)
                            Text(
                              authProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 20),
                          _buildLoginButton(authProvider),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40), // Space to keep form at top
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return GestureDetector(
      onTapDown: (_) {
        // Scale animation on press
        setState(() {});
      },
      onTapUp: (_) {
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: authProvider.isLoading
              ? null
              : () async {
            if (_formKey.currentState!.validate()) {
              await authProvider.login(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
              if (authProvider.adminUser != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: authProvider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}