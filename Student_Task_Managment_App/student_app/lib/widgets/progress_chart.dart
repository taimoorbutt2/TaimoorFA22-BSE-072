import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProgressChart extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressChart({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pending = total - completed;
    final sections = [
      PieChartSectionData(
        color: AppColors.accent, // Purple for completed
        value: completed.toDouble(),
        title: completed > 0 ? '$completed' : '',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        badgeWidget: completed > 0
            ? Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Text(
            'Done',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        )
            : null,
      ),
      PieChartSectionData(
        color: AppColors.primary.withOpacity(0.5), // Teal for pending
        value: pending.toDouble(),
        title: pending > 0 ? '$pending' : '',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        badgeWidget: pending > 0
            ? Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Text(
            'Pending',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        )
            : null,
      ),
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            touchCallback: (event, pieTouchResponse) {
              debugPrint('ProgressChart: Touched section ${pieTouchResponse?.touchedSection?.touchedSectionIndex}');
            },
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}