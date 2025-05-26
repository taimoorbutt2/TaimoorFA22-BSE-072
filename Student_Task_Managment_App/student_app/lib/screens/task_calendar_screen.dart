import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_app/services/supabase_service.dart';
import '../utils/constants.dart';
import '../utils/gradient_text.dart';

class TaskCalendarScreen extends StatefulWidget {
  final String studentId;
  const TaskCalendarScreen({super.key, required this.studentId});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _tasks = [];
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTasks();
    debugPrint('TaskCalendarScreen: Initialized for student ${widget.studentId}');
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await _supabaseService.getTasksForStudent(widget.studentId);
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  List<dynamic> _getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = task.dueDate as DateTime;
      return taskDate.year == day.year &&
          taskDate.month == day.month &&
          taskDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rendering TaskCalendarScreen at ${DateTime.now()}');
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient, // Blue to Cyan
            ),
          ),
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Toggle Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GradientText(
                          text: 'Task Calendar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          gradient: AppColors.accentGradient, // Purple to Blue
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent, // Deep Purple
                                AppColors.primary, // Teal
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.3), // Purple shadow
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _showCompleted ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _showCompleted = !_showCompleted;
                                debugPrint('Toggle completed tasks: $_showCompleted');
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calendar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          debugPrint('Selected day: $selectedDay');
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        weekendTextStyle: const TextStyle(color: Colors.white70),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                      ),
                      eventLoader: _getTasksForDay,
                    ),
                  ),
                  // Selected Day Tasks
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: GradientText(
                      text: 'Tasks for ${_selectedDay?.toString().substring(0, 10) ?? 'Selected Date'}',
                      style: Theme.of(context).textTheme.titleMedium,
                      gradient: AppColors.accentGradient,
                    ),
                  ),
                  ..._getTasksForDay(_selectedDay ?? _focusedDay).map((task) {
                    return _TaskCard(
                      title: task.title,
                      status: task.status,
                      dueDate: task.dueDate,
                    );
                  }),
                  // Completed Tasks Section (shown when toggled)
                  if (_showCompleted)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: GradientText(
                        text: 'Completed Tasks',
                        style: Theme.of(context).textTheme.titleMedium,
                        gradient: AppColors.accentGradient,
                      ),
                    ),
                  if (_showCompleted)
                    ..._tasks.where((task) => task.status == 'completed').map((task) {
                      return _TaskCard(
                        title: task.title,
                        status: task.status,
                        dueDate: task.dueDate,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String status;
  final DateTime? dueDate;

  const _TaskCard({
    required this.title,
    required this.status,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.primary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: $status',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (dueDate != null)
            Text(
              'Due: ${dueDate!.toString().substring(0, 10)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }
}