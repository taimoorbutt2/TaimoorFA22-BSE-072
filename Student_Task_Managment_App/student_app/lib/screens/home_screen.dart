import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as local_user;
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../utils/gradient_text.dart';
import 'task_list_screen.dart';
import 'task_calendar_screen.dart';
import 'performance_screen.dart';

class HomeScreen extends StatefulWidget {
  final local_user.User student;
  const HomeScreen({super.key, required this.student});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int _pendingTasks = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPendingTasks();
    debugPrint('HomeScreen: Initialized for ${widget.student.name}');
  }

  Future<void> _fetchPendingTasks() async {
    try {
      final tasks = await _supabaseService.getTasksForStudent(widget.student.id);
      setState(() {
        _pendingTasks = tasks.where((task) => task.status == 'pending').length;
      });
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskListScreen(studentId: widget.student.id),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskCalendarScreen(studentId: widget.student.id),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerformanceScreen(studentId: widget.student.id),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rendering HomeScreen with gradient UI at ${DateTime.now()}');
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message with Fade Animation
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(seconds: 1),
                    child: GradientText(
                      text: 'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      gradient: AppColors.accentGradient, // Pink to Orange
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Greeting with Bounce Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.bounceOut,
                    transform: Matrix4.identity()..scale(1.0),
                    onEnd: () {
                      setState(() {
                        debugPrint('Greeting bounce animation completed');
                      });
                    },
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent, // Coral
                          AppColors.primary, // Teal
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.student.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientText(
                    text: 'Hello, ${widget.student.name}!',
                    style: Theme.of(context).textTheme.titleLarge,
                    gradient: AppColors.accentGradient, // Pink to Orange
                  ),
                  const SizedBox(height: 24),
                  // Task Container with Scale Animation
                  GestureDetector(
                    onTapDown: (_) => setState(() {
                      debugPrint('Task container tapped');
                    }),
                    onTapUp: (_) => setState(() {}),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(1.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.3), // Faded Coral
                            AppColors.primary.withOpacity(0.3), // Faded Teal
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pending Tasks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You have $_pendingTasks tasks to complete',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            selectedItemColor: AppColors.accent, // Coral
            unselectedItemColor: Colors.white70,
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
            ? AppColors.accentGradient // Pink to Orange
            : const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.accent : AppColors.accent.withOpacity(0.7), // Coral, faded coral
      ),
    );
  }
}