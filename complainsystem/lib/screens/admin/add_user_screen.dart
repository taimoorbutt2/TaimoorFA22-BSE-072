import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/supabase_service.dart';
import '../../services/email_service.dart';
import '../../models/batch.dart';
import '../../utils/constants.dart';
import '../../services/complaint_timeline_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedRole = 'student';
  String? _selectedBatchId;
  List<Batch> _batches = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await SupabaseService.getAllBatches();
      setState(() {
        _batches = batches;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load batches: $e';
      });
    }
  }

  Future<String> _generateStudentId() async {
    final students = await SupabaseService.getAllProfiles(role: 'student');
    int studentCount = students.length + 1;
    String studentId;

    while (true) {
      studentId = '${AppConstants.studentIdPrefix}${studentCount.toString().padLeft(2, '0')}';
      final existingStudent = await SupabaseService.getProfileByStudentId(studentId);
      if (existingStudent == null) {
        return studentId;
      }
      studentCount++;
    }
  }

  void _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? studentId;
      String? batchId;

      if (_selectedRole == 'student') {
        studentId = await _generateStudentId();
        batchId = _selectedBatchId;
      } else if (_selectedRole == 'batch_advisor') {
        batchId = _selectedBatchId;
      }

      final response = await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
        batchId: batchId,
        phoneNo: _phoneController.text.trim(),
        studentId: studentId,
      );

      if (_selectedRole == 'batch_advisor' && batchId != null && response.user != null) {
        print('DEBUG: Assigning advisor ${response.user!.id} to batch $batchId');
        await SupabaseService.assignAdvisorToBatch(batchId, response.user!.id);
      }

      if (response.user != null) {
        // Send email based on role
        switch (_selectedRole) {
          case 'hod':
            await EmailService.sendHODCredentials(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
            break;
          case 'batch_advisor':
            final batch = _batches.firstWhere((b) => b.id == _selectedBatchId);
            await EmailService.sendBatchAdvisorCredentials(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              batch: batch.batchName,
            );
            break;
          case 'student':
            final batch = _batches.firstWhere((b) => b.id == _selectedBatchId);
            await EmailService.sendStudentCredentials(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              studentId: studentId!,
              batch: batch.batchName,
            );
            break;
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: Text('${_selectedRole.toUpperCase()} account created. Credentials sent via email.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error adding user: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New User',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter email'
                        : (!EmailValidator.validate(value) || !value.contains('@') || !value.endsWith('.com'))
                            ? 'Enter a valid email'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'hod', child: Text('HOD')),
                  DropdownMenuItem(value: 'batch_advisor', child: Text('Batch Advisor')),
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                    if (_selectedRole != 'student' && _selectedRole != 'batch_advisor') {
                      _selectedBatchId = null;
                    }
                  });
                },
              ),
              if (_selectedRole == 'student' || _selectedRole == 'batch_advisor') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBatchId,
                  decoration: const InputDecoration(
                    labelText: 'Batch',
                    border: OutlineInputBorder(),
                  ),
                  items: _batches.map((batch) {
                    return DropdownMenuItem(
                      value: batch.id,
                      child: Text(batch.batchName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBatchId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select a batch' : null,
                ),
              ],
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}