import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';

class TaskListScreen extends StatefulWidget {
  final String studentId;
  const TaskListScreen({super.key, required this.studentId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  String _filter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _supabaseService.subscribeToTasks((updatedTasks) {
      setState(() {
        _tasks = updatedTasks.where((task) => task.assignedTo == widget.studentId).toList();
      });
    });
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tasks = await _supabaseService.getTasksForStudent(widget.studentId);
      setState(() {
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

  Future<void> _markTaskComplete(Task task) async {
    try {
      await Supabase.instance.client
          .from('tasks')
          .update({'status': 'completed'})
          .eq('id', task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task marked as completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<Task> get _filteredTasks {
    if (_filter == 'pending') {
      return _tasks.where((task) => task.status == 'pending').toList();
    } else if (_filter == 'completed') {
      return _tasks.where((task) => task.status == 'completed').toList();
    }
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _filter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Tasks')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                ? const Center(child: Text('No tasks available'))
                : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return TaskCard(
                  task: task,
                  onComplete: task.status == 'pending'
                      ? () => _markTaskComplete(task)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}