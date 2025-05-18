import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as local_user;
import 'dashboard_screen.dart';
import '../utils/constants.dart';

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
      appBar: AppBar(title: const Text('Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Enter Your Student ID',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  hintText: 'Enter your UUID',
                ),
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
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}