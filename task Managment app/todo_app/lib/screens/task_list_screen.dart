import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/screens/edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  final Task category;
  final bool showRepeated;
  final bool showFuture;
  final bool showCompleted;

  const TaskListScreen({
    super.key,
    required this.category,
    required this.showRepeated,
    this.showFuture = false,
    this.showCompleted = false,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  LinearGradient _getCategoryGradient(Color btnColor) {
    final hsl = HSLColor.fromColor(btnColor);
    final darkerColor = hsl.withLightness((hsl.lightness - 0.3).clamp(0.2, 0.7)).toColor();
    return LinearGradient(
      colors: [
        Color.lerp(btnColor, Colors.white, 0.4) ?? btnColor.withOpacity(0.6),
        darkerColor,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryGradient = _getCategoryGradient(widget.category.btnColor);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: categoryGradient,
          ),
        ),
        title: Text(widget.showCompleted
            ? 'Completed Tasks'
            : widget.showFuture
            ? 'Future Tasks'
            : widget.showRepeated
            ? 'Repeated Tasks'
            : 'Today\'s Tasks'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: categoryGradient,
        ),
        child: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            final tasks = provider.getTasksForCategory(
              widget.category.id,
              showRepeated: widget.showRepeated,
              showToday: !widget.showRepeated && !widget.showFuture && !widget.showCompleted,
              showFuture: widget.showFuture,
              showCompleted: widget.showCompleted,
            );
            debugPrint('Displaying ${tasks.length} tasks for ${widget.category.title}');

            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  widget.showCompleted
                      ? 'No completed tasks in ${widget.category.title}'
                      : widget.showFuture
                      ? 'No future tasks in ${widget.category.title}'
                      : widget.showRepeated
                      ? 'No repeated tasks in ${widget.category.title}'
                      : 'No tasks for today in ${widget.category.title}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            }

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key('${widget.category.id}-${task['createdAt']}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: widget.showFuture || widget.showCompleted
                      ? null
                      : Container(
                    color: Colors.green,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await provider.deleteTask(widget.category.id, index);
                      return true;
                    } else if (!widget.showFuture && !widget.showCompleted) {
                      await provider.completeTask(widget.category.id, index);
                      return true;
                    }
                    return false;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: categoryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: ListTile(
                        title: Text(
                          task['title'] ?? 'Untitled Task',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task['description']?.isNotEmpty == true)
                              Text(
                                task['description'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (task['dueDate'] != null)
                              Text(
                                'Due: ${_formatTime(task['dueDate'])}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (task['isRepeated'] == true && task['repeatType'] == 'weekly' && task['repeatDays'] != null)
                              Text(
                                'Repeat: ${(task['repeatDays'] as List).join(', ')}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (task['isRepeated'] == true && task['repeatType'] == 'monthly' && task['repeatDate'] != null)
                              Text(
                                'Repeat: Day ${task['repeatDate']} of each month',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            Text(
                              task['isCompleted'] == true ? 'Completed' : 'Incomplete',
                              style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.showFuture || widget.showCompleted
                              ? [
                            IconButton(
                              icon: const Icon(Icons.description, color: Colors.white),
                              onPressed: () => _showTaskDescription(context, task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => provider.deleteTask(widget.category.id, index),
                            ),
                          ]
                              : [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _navigateToEditScreen(context, provider, widget.category.id, index, task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => provider.deleteTask(widget.category.id, index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showTaskDescription(BuildContext context, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text(task['title'] ?? 'Untitled Task', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(task['description']?.isNotEmpty == true
            ? task['description']
            : 'No description available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, TaskProvider provider,
      String categoryId, int taskIndex, Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(
          categoryId: categoryId,
          taskIndex: taskIndex,
          initialTask: task,
        ),
      ),
    );
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}