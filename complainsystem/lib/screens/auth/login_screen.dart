import 'package:flutter/material.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String _selectedRole = 'student'; // Default role

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await SupabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response.user != null) {
        final userProfile = await SupabaseService.getProfile(response.user!.id);
        if (mounted) {
          if (userProfile == null) {
            setState(() {
              _error = 'User profile not found.';
              _isLoading = false;
            });
            return;
          }
          if (userProfile.role != _selectedRole) {
            setState(() {
              _error = 'Invalid role for this user.';
              _isLoading = false;
            });
            return;
          }
          switch (userProfile.role) {
            case 'admin':
              Navigator.pushReplacementNamed(context, '/admin');
              break;
            case 'student':
              Navigator.pushReplacementNamed(context, '/student');
              break;
            case 'batch_advisor':
              Navigator.pushReplacementNamed(context, '/advisor');
              break;
            case 'hod':
              Navigator.pushReplacementNamed(context, '/hod');
              break;
            default:
              setState(() {
                _error = 'Unknown user role.';
                _isLoading = false;
              });
          }
        }
      } else {
        setState(() {
          _error = 'Login failed. Please check your credentials.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomLeft,
        secondaryBegin: Alignment.bottomLeft,
        secondaryEnd: Alignment.topRight,
        primaryColors: const [
          Color(0xff1f202c),
          Color(0xff3b2b4f),
          Color(0xff1f202c),
        ],
        secondaryColors: const [
          Color(0xff3b2b4f),
          Color(0xff1f202c),
          Color(0xff3b2b4f),
        ],
        child: Stack(
          children: [
            // Floating Shapes (simplified example)
            Positioned(top: 100, left: 20, child: _buildShape(Colors.deepPurple.withOpacity(0.1), 120)),
            Positioned(top: 400, right: -50, child: _buildShape(Colors.blue.withOpacity(0.1), 200)),
            Positioned(bottom: 50, left: -30, child: _buildShape(Colors.pink.withOpacity(0.1), 150)),

            // Login Form
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: GlassmorphicContainer(
                  width: 350,
                  height: 520,
                  borderRadius: 20,
                  blur: 15,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: const [0.1, 1],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.5),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Log in to your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 40),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: const [
                              DropdownMenuItem(value: 'student', child: Text('Student')),
                              DropdownMenuItem(value: 'batch_advisor', child: Text('Batch Advisor')),
                              DropdownMenuItem(value: 'hod', child: Text('HOD')),
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                            decoration: _buildInputDecoration('Role'),
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: const Color(0xff3b2b4f),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: _buildInputDecoration('Email'),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: _buildInputDecoration('Password'),
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                          ),
                          const SizedBox(height: 24),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                            child: const Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
    );
  }
} 