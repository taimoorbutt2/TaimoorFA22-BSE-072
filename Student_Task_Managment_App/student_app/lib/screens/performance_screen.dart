import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../widgets/progress_chart.dart';
import '../widgets/streak_indicator.dart';
import '../utils/constants.dart';
import '../utils/gradient_text.dart';

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
    debugPrint('PerformanceScreen: Current user: ${Supabase.instance.client.auth.currentUser?.id}');
    _supabaseService.subscribeToTasks(widget.studentId, (updatedTasks) {
      setState(() {
        _tasks = updatedTasks;
        debugPrint('PerformanceScreen: Updated tasks to ${updatedTasks.length}');
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
        debugPrint('PerformanceScreen: Fetched ${tasks.length} tasks');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
      setState(() {
        _isLoading = false;
      });
      debugPrint('PerformanceScreen: Error fetching tasks: $e');
    }
  }

  int _calculateStreak() {
    final completedTasks = _tasks
        .where((task) => task.status == 'completed' && (task.completed_at ?? task.dueDate) != null)
        .toList();
    if (completedTasks.isEmpty) return 0;

    // Sort by completion date (or due date if completed_at is null), descending
    completedTasks.sort((a, b) => (b.completed_at ?? b.dueDate)!.compareTo((a.completed_at ?? a.dueDate)!));

    int streak = 0;
    DateTime? lastDate;
    final today = DateTime.now();
    for (var task in completedTasks) {
      final completionDate = (task.completed_at ?? task.dueDate)!;
      final taskDay = DateTime(completionDate.year, completionDate.month, completionDate.day);
      if (lastDate == null) {
        // Start streak if task is today or yesterday
        if (taskDay.isAfter(today.subtract(const Duration(days: 2)))) {
          streak = 1;
          lastDate = taskDay;
        } else {
          break;
        }
      } else {
        final expected = lastDate.subtract(const Duration(days: 1));
        if (taskDay.isAtSameMomentAs(expected)) {
          streak++;
          lastDate = taskDay;
        } else {
          break;
        }
      }
    }
    debugPrint('PerformanceScreen: Calculated streak: $streak');
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.status == 'completed').length;
    final total = _tasks.length;
    final progress = total > 0 ? completed / total : 0.0;
    final streak = _calculateStreak();

    debugPrint('PerformanceScreen: Rendering with $completed/$total tasks, streak: $streak');
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient, // Blue to Cyan
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GradientText(
                        text: 'Performance',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        gradient: AppColors.accentGradient,
                      ),
                    ),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    else ...[
                      // Progress Overview
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientText(
                              text: 'Progress Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                              gradient: AppColors.accentGradient,
                            ),
                            const SizedBox(height: 16),
                            ProgressChart(completed: completed, total: total),
                            const SizedBox(height: 16),
                            Text(
                              'Completion: ${(progress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Task Streaks
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientText(
                              text: 'Task Streaks',
                              style: Theme.of(context).textTheme.titleLarge,
                              gradient: AppColors.accentGradient,
                            ),
                            const SizedBox(height: 16),
                            AnimatedStreakIndicator(streak: streak),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}