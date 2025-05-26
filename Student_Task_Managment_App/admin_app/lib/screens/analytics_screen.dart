import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/supabase_service.dart';
import '../widgets/performance_chart.dart';
import '../widgets/leaderboard_tile.dart';
import '../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _performance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPerformance();
  }

  Future<void> _fetchPerformance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final performance = await _supabaseService.getStudentPerformance();
      // Convert and validate data
      final convertedPerformance = performance.map((data) {
        // Handle numeric fields with null checks and type conversion
        final score = data['performance_score'];
        final completed = data['completed_tasks'];
        final total = data['total_tasks'];
        final name = data['name'];

        // Convert score to double, default to 0.0 if null or invalid
        final double performanceScore = (score is num
            ? score.toDouble()
            : score is String
            ? double.tryParse(score) ?? 0.0
            : 0.0);
        // Convert completed_tasks and total_tasks to int, default to 0 if null or invalid
        final int completedTasks = (completed is num
            ? completed.toInt()
            : completed is String
            ? int.tryParse(completed) ?? 0
            : 0);
        final int totalTasks = (total is num
            ? total.toInt()
            : total is String
            ? int.tryParse(total) ?? 0
            : 0);
        // Ensure name is String, default to "Unknown"
        final String studentName = (name is String && name.isNotEmpty) ? name : 'Unknown';

        return {
          'name': studentName,
          'performance_score': performanceScore,
          'completed_tasks': completedTasks,
          'total_tasks': totalTasks,
        };
      }).toList();

      setState(() {
        _performance = convertedPerformance;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching performance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _performance = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B00FF))) // Neon Indigo
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PerformanceChart(performance: _performance),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Leaderboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _performance.isEmpty
                  ? const Center(child: Text('No performance data available'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _performance.length,
                itemBuilder: (context, index) {
                  final data = _performance[index];
                  // Defensive check for required fields
                  if (data['name'] == null ||
                      data['performance_score'] == null ||
                      data['completed_tasks'] == null ||
                      data['total_tasks'] == null) {
                    debugPrint('Invalid data at index $index: $data');
                    return const SizedBox.shrink();
                  }
                  return LeaderboardTile(
                    rank: index + 1,
                    name: data['name'],
                    score: data['performance_score'],
                    completedTasks: data['completed_tasks'],
                    totalTasks: data['total_tasks'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}