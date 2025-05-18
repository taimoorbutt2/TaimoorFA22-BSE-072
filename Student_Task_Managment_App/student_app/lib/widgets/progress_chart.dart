import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class ProgressChart extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressChart({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: AppColors.primary,
              value: completed.toDouble(),
              title: '$completed',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: AppColors.border,
              value: (total - completed).toDouble(),
              title: '${total - completed}',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}