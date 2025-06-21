import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_gradient/animate_gradient.dart';
import '../../services/supabase_service.dart';
import '../../services/email_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _adminExists = false;
  bool _checkingAdmin = true;

  @override
  void initState() {
    super.initState();
    _checkAdminExists();
  }

  Future<void> _checkAdminExists() async {
    try {
      final admins = await SupabaseService.getAllProfiles(role: 'admin');
      if (mounted) {
        setState(() {
          _adminExists = admins.isNotEmpty;
          _checkingAdmin = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Could not verify admin status.";
          _checkingAdmin = false;
        });
      }
    }
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: 'admin',
      );
      if (response.user != null) {
        await EmailService.sendAdminCredentials(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Admin account created. Credentials sent via email.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Signup failed.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
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
            Positioned(top: 100, right: 20, child: _buildShape(Colors.pink.withOpacity(0.1), 120)),
            Positioned(top: 500, left: -50, child: _buildShape(Colors.blue.withOpacity(0.1), 200)),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _checkingAdmin
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : _adminExists
                        ? _buildAdminExistsCard()
                        : _buildSignupForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminExistsCard() {
    return GlassmorphicContainer(
      width: 350,
      height: 300,
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
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gpp_maybe, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Admin Account Exists',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Only one admin account can be created for the system.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Back to Login', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return GlassmorphicContainer(
      width: 350,
      height: 600,
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
      ),
      borderGradient: LinearGradient(
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
                'Create Admin Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Name'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email'),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value == null || !EmailValidator.validate(value) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: _buildInputDecoration('Password'),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: _buildInputDecoration('Confirm Password'),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.withOpacity(0.7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Back to Login', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
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