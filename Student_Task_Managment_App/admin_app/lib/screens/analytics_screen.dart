import 'package:flutter/material.dart';
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
      setState(() {
        _performance = performance;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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