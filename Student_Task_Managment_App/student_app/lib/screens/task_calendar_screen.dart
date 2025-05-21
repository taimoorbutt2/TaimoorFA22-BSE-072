import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../utils/task_completion_handler.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';

class TaskCalendarScreen extends StatefulWidget {
  final String studentId;
  const TaskCalendarScreen({super.key, required this.studentId});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final TaskCompletionHandler _completionHandler = TaskCompletionHandler();
  List<Task> _tasks = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTasks();
    debugPrint('TaskCalendarScreen: Student ID: ${widget.studentId}');
    _supabaseService.subscribeToTasks(widget.studentId, (updatedTasks) {
      setState(() {
        _tasks = updatedTasks;
        debugPrint('TaskCalendarScreen: Updated tasks to ${updatedTasks.length}');
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
        debugPrint('TaskCalendarScreen: Fetched ${tasks.length} tasks');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
      setState(() {
        _isLoading = false;
      });
      debugPrint('TaskCalendarScreen: Error fetching tasks: $e');
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      final dueDate = task.dueDate;
      return dueDate != null &&
          dueDate.year == day.year &&
          dueDate.month == day.month &&
          dueDate.day == day.day &&
          (_showCompleted || task.status == 'pending');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Calendar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getTasksForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
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
            child: _getTasksForDay(_selectedDay!).isEmpty
                ? const Center(child: Text('No tasks for this day'))
                : ListView.builder(
              itemCount: _getTasksForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                final task = _getTasksForDay(_selectedDay!)[index];
                return TaskCard(
                  task: task,
                  onComplete: task.status == 'pending'
                      ? () async {
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