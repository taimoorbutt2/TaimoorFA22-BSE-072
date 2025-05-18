import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../widgets/progress_chart.dart';
import '../widgets/streak_indicator.dart';
import '../utils/constants.dart';

class PerformanceScreen extends StatefulWidget {
  final String studentId;
  const PerformanceScreen({super.key, required this.studentId});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
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

  int get _streak {
    int streak = 0;
    final sortedTasks = _tasks.where((task) => task.status == 'completed').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final today = DateTime.now();
    for (var task in sortedTasks) {
      if (task.createdAt.day == today.day &&
          task.createdAt.month == today.month &&
          task.createdAt.year == today.year) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.status == 'completed').length;
    final total = _tasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress Overview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ProgressChart(completed: completed, total: total),
                      const SizedBox(height: 16),
                      Text(
                        'Completion: ${(progress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Streaks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      StreakIndicator(streak: _streak),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}