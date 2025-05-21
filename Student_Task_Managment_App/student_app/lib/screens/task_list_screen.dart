import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../utils/task_completion_handler.dart';
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
  final TaskCompletionHandler _completionHandler = TaskCompletionHandler();
  List<Task> _tasks = [];
  bool _showCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    debugPrint('TaskListScreen: Student ID: ${widget.studentId}');
    _supabaseService.subscribeToTasks(widget.studentId, (updatedTasks) {
      setState(() {
        _tasks = updatedTasks;
        debugPrint('TaskListScreen: Updated tasks to ${updatedTasks.length}');
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
        debugPrint('TaskListScreen: Fetched ${tasks.length} tasks');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
      setState(() {
        _isLoading = false;
      });
      debugPrint('TaskListScreen: Error fetching tasks: $e');
    }
  }

  Future<void> _markTaskComplete(Task task) async {
    await _completionHandler.markTaskComplete(
      task: task,
      studentId: widget.studentId,
      onSuccess: () async {
        await _fetchTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as completed')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark task: $error')),
        );
      },
    );
  }

  List<Task> get _filteredTasks {
    return _tasks.where((task) => _showCompleted || task.status == 'pending').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show Completed Tasks', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _showCompleted,
                  onChanged: (value) {
                    setState(() {
                      _showCompleted = value;
                    });
                  },
                ),
              ],
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