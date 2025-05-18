import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<User> _students = [];
  List<Task> _tasks = [];
  String? _selectedStudentId;
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _supabaseService.subscribeToTasks((updatedTasks) {
      setState(() {
        _tasks = updatedTasks;
      });
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final students = await _supabaseService.getStudents();
      final tasks = await _supabaseService.getTasks();
      setState(() {
        _students = students;
        _tasks = tasks;
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

  Future<void> _assignTask() async {
    if (!_formKey.currentState!.validate() || _selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _supabaseService.assignTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _selectedStudentId!,
        dueDate: _selectedDate!,
        createdBy: authProvider.adminUser!.uid,
      );
      _titleController.clear();
      _descriptionController.clear();
      _dueDateController.clear();
      _selectedStudentId = null;
      _selectedDate = null;
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task assigned successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = Helpers.formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tasks')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign New Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStudentId,
                      hint: const Text('Select Student'),
                      items: _students
                          .map((student) => DropdownMenuItem(
                        value: student.id,
                        child: Text(student.name),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a student';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        hintText: 'Select due date',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a due date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _assignTask,
                      child: const Text('Assign Task'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'All Tasks',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _tasks.isEmpty
                  ? const Center(child: Text('No tasks available'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final student = _students.firstWhere(
                        (s) => s.id == task.assignedTo,
                    orElse: () => User(
                      id: '',
                      name: 'Unknown',
                      role: 'student',
                      createdAt: DateTime.now(),
                    ),
                  );
                  return TaskCard(task: task, studentName: student.name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}