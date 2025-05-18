import 'package:flutter/material.dart';
import 'package:student_app/models/user.dart' as local_user;
import 'package:student_app/screens/task_list_screen.dart';
import 'package:student_app/screens/performance_screen.dart';
import 'package:student_app/screens/task_calendar_screen.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  final local_user.User student;
  const DashboardScreen({super.key, required this.student});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      TaskListScreen(studentId: widget.student.id),
      TaskCalendarScreen(studentId: widget.student.id),
      PerformanceScreen(studentId: widget.student.id),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.student.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Performance',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}