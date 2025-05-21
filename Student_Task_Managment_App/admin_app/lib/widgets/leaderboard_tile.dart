import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final double score;
  final int completedTasks;
  final int totalTasks;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent, // Neon Coral
          child: Text(
            '$rank',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          'Score: ${score.toStringAsFixed(1)}% | $completedTasks/$totalTasks tasks',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}