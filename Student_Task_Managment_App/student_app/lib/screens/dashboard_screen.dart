import 'package:flutter/material.dart';
import 'package:student_app/models/user.dart' as local_user;
import 'package:student_app/screens/task_list_screen.dart';
import 'package:student_app/screens/performance_screen.dart';
import 'package:student_app/screens/task_calendar_screen.dart';
import '../utils/constants.dart';
import '../utils/gradient_text.dart';

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
      debugPrint('DashboardScreen: Navigated to index $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rendering DashboardScreen for ${widget.student.name} at ${DateTime.now()}');
    final List<Widget> screens = [
      TaskListScreen(studentId: widget.student.id),
      TaskCalendarScreen(studentId: widget.student.id),
      PerformanceScreen(studentId: widget.student.id),
    ];

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
          Column(
            children: [
              // Custom Header with Gradient Welcome
              Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(seconds: 1),
                      child: GradientText(
                        text: 'Welcome, ${widget.student.name}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        gradient: AppColors.accentGradient, // Purple to Blue
                      ),
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
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          debugPrint('DashboardScreen: Logout tapped');
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Screen Content
              Expanded(
                child: screens[_selectedIndex],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.accent, // Deep Purple
            unselectedItemColor: AppColors.accent.withOpacity(0.7), // Faded Purple
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.task_alt,
                  isSelected: _selectedIndex == 0,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.calendar_today,
                  isSelected: _selectedIndex == 1,
                ),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.bar_chart,
                  isSelected: _selectedIndex == 2,
                ),
                label: 'Performance',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    debugPrint('Rendering NavIcon: ${isSelected ? 'selected' : 'unselected'}');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? AppColors.accentGradient // Purple to Blue
            : const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.accent : AppColors.accent.withOpacity(0.7), // Purple, Faded Purple
      ),
    );
  }
}