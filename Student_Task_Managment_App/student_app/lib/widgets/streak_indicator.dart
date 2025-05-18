import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StreakIndicator extends StatelessWidget {
  final int streak;

  const StreakIndicator({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.local_fire_department, color: AppColors.accent, size: 40),
        const SizedBox(width: 8),
        Text(
          '$streak Day Streak',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}