import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as local_user;
import 'dashboard_screen.dart';
import '../utils/constants.dart';
import '../utils/wave_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final studentId = _idController.text.trim();
      debugPrint('Attempting login with student ID: $studentId');
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', studentId)
          .eq('role', 'student')
          .maybeSingle();

      if (response == null) {
        setState(() {
          _error = 'Invalid student ID or not a student';
          _isLoading = false;
        });
        debugPrint('No user found for ID: $studentId');
        return;
      }

      final user = local_user.User.fromJson(response);
      debugPrint('User logged in: ${user.name} (ID: ${user.id})');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(student: user),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Login failed: ${e.toString().split('message:').last}';
        _isLoading = false;
      });
      debugPrint('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          // Wave Animation
          WaveBackground(
            colors: [
              AppColors.accent,
              Colors.white.withOpacity(0.7),
              AppColors.primary.withOpacity(0.5),
            ],
          ),
          // Login Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Enter Your Student ID',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      hintText: 'Enter your UUID',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your student ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 20),
                  // Stylish Login Button
                  AnimatedLoginButton(
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _login,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const AnimatedLoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<AnimatedLoginButton> createState() => _AnimatedLoginButtonState();
}

class _AnimatedLoginButtonState extends State<AnimatedLoginButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) {
          setState(() {
            _isTapped = true;
          });
        }
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          setState(() {
            _isTapped = false;
          });
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (!widget.isLoading) {
          setState(() {
            _isTapped = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isTapped ? 0.95 : 1.0),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: widget.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}