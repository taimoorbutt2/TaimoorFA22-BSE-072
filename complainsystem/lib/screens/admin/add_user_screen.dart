import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_gradient/animate_gradient.dart';
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Text('Success', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                '${_selectedRole.toUpperCase()} account created. Credentials sent via email.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('OK', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomLeft,
        secondaryEnd: Alignment.topRight,
        primaryColors: const [
          Color(0xFFE3F2FD),
          Color(0xFFF3E5F5),
          Color(0xFFE8F5E8),
        ],
        secondaryColors: const [
          Color(0xFFF3E5F5),
          Color(0xFFE8F5E8),
          Color(0xFFE3F2FD),
        ],
        child: Stack(
          children: [
            // Decorative shapes
            Positioned(top: 100, right: 50, child: _buildShape(Colors.blue.withOpacity(0.1), 150)),
            Positioned(top: 300, left: 30, child: _buildShape(Colors.purple.withOpacity(0.1), 100)),
            Positioned(bottom: 200, right: 100, child: _buildShape(Colors.green.withOpacity(0.1), 120)),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 80,
                      borderRadius: 20,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.6),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.3),
                          Colors.deepPurple.withOpacity(0.3),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.person_add, size: 32, color: Colors.deepPurple),
                            const SizedBox(width: 16),
                            const Text(
                              'Add New User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Form Container
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 600,
                      borderRadius: 20,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.6),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.3),
                          Colors.deepPurple.withOpacity(0.3),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: _buildInputDecoration('Full Name', Icons.person),
                                style: const TextStyle(color: Colors.black87),
                                validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: _buildInputDecoration('Email', Icons.email),
                                style: const TextStyle(color: Colors.black87),
                                validator: (value) =>
                                    value == null || !EmailValidator.validate(value) ? 'Enter a valid email' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: _buildInputDecoration('Password', Icons.lock),
                                style: const TextStyle(color: Colors.black87),
                                obscureText: true,
                                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                decoration: _buildInputDecoration('Phone Number', Icons.phone),
                                style: const TextStyle(color: Colors.black87),
                                validator: (value) => value == null || value.isEmpty ? 'Enter phone number' : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: _buildInputDecoration('Role', Icons.work),
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Colors.black87),
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
                                  decoration: _buildInputDecoration('Batch', Icons.school),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Colors.black87),
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
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: TextStyle(color: Colors.red.shade700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_error != null) const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _addUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
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
                                          'Add User',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
    );
  }
}