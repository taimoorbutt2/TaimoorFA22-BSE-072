import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../widgets/student_card.dart';
import '../utils/constants.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<User> _students = [];
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final students = await _supabaseService.getStudents();
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _supabaseService.addStudent(_nameController.text.trim());
      _nameController.clear();
      _fetchStudents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _bulkUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && result.files.single.bytes != null) {
        await _supabaseService.bulkAddStudents(result.files.single);
        _fetchStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Students uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        hintText: 'Enter student name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addStudent,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _bulkUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Upload CSV'),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                ? const Center(child: Text('No students available'))
                : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return StudentCard(
                  student: student,
                  onEdit: (newName) async {
                    try {
                      await _supabaseService.updateStudent(student.id, newName);
                      _fetchStudents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student updated')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  onDelete: () async {
                    try {
                      await _supabaseService.deleteStudent(student.id);
                      _fetchStudents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student deleted')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}