import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../utils/task_completion_handler.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';
import '../utils/ripple_background.dart';

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
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          // Ripple Animation
          RippleBackground(
            colors: [
              AppColors.accent,
              Colors.white.withOpacity(0.7),
              AppColors.primary.withOpacity(0.5),
            ],
          ),
          // Task List Content
          Column(
            children: [
              AppBar(
                title: const Text('My Tasks'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Show Completed Tasks',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AnimatedToggleButton(
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
                    ? const Center(
                  child: Text(
                    'No tasks available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
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
        ],
      ),
    );
  }
}

class AnimatedToggleButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedToggleButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AnimatedToggleButton> createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: widget.value
              ? AppColors.accentGradient
              : LinearGradient(
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade600,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.value
                  ? AppColors.accent.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: widget.value ? 30 : 4,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
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
}