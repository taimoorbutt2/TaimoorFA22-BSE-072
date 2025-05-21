import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;

  const TaskCard({super.key, required this.task, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (task.description != null) ...[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Due: ${task.dueDate?.toString().substring(0, 10) ?? 'No due date'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${task.status.capitalize()}',
              style: TextStyle(
                color: task.status == 'completed' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onComplete != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onComplete,
                child: const Text('Mark as Complete'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}