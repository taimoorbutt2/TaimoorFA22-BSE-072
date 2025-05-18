import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student_management_screen.dart';
import 'task_management_screen.dart';
import 'analytics_screen.dart';
import 'login_screen.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stats = await _supabaseService.getDashboardStats();
      setState(() {
        _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/admin_dashboard.png', height: 150),
              const SizedBox(height: 20),
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Students',
                    value: _stats['total_students'].toString(),
                    icon: Icons.people,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Tasks Today',
                    value: _stats['tasks_today'].toString(),
                    icon: Icons.task,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Pending Tasks',
                    color: Colors.red,
                    value: _stats['pending_tasks'].toString(),
                    icon: Icons.pending,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Completed Tasks',
                    color: Colors.green,
                    value: _stats['completed_tasks'].toString(),
                    icon: Icons.check_circle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    label: 'Manage Students',
                    icon: Icons.people,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentManagementScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    label: 'Manage Tasks',
                    icon: Icons.task,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskManagementScreen(),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    label: 'Analytics',
                    icon: Icons.bar_chart,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title, required String value, required IconData icon, Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color ?? AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}