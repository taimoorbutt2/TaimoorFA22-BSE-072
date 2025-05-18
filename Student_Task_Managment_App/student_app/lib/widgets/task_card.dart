import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;

  const TaskCard({super.key, required this.task, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              task.description ?? 'No description',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Due: ${task.dueDate != null ? Helpers.formatDate(task.dueDate!) : 'No due date'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${task.status}',
              style: TextStyle(
                color: task.status == 'completed' ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (task.status == 'pending' && onComplete != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: const Text('Mark Complete'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}