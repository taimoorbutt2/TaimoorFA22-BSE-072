import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/database_service.dart';
import 'package:todo_app/services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  List<Task> _tasks = [];
  bool _isLoading = false; // Prevent multiple loadTasks calls

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    if (_isLoading) {
      debugPrint('TaskProvider: loadTasks already in progress, skipping');
      return;
    }
    _isLoading = true;
    try {
      debugPrint('TaskProvider: Starting loadTasks');
      _tasks = await _dbService.getTasks();
      debugPrint('TaskProvider: Loaded ${_tasks.length} categories: ${_tasks.map((t) => t.title).toList()}');
      notifyListeners();
    } catch (e) {
      debugPrint('TaskProvider: Error loading tasks: $e');
      _tasks = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      debugPrint('TaskProvider: loadTasks completed');
    }
  }

  Future<void> addCategory(Task newCategory) async {
    try {
      debugPrint('TaskProvider: Adding category: ${newCategory.title}');
      final updatedTasks = List<Task>.from(_tasks)..add(newCategory);
      _tasks = updatedTasks;
      await _dbService.updateTask(newCategory);
      debugPrint('TaskProvider: Added category: ${newCategory.title}, total categories: ${_tasks.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('TaskProvider: Error adding category: $e');
    }
  }

  Future<void> addTaskToCategory(String categoryId, Map<String, dynamic> taskDetail) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == categoryId);
      if (taskIndex != -1) {
        final updatedTaskDetail = {
          ...taskDetail,
          'isCompleted': false, // Initialize isCompleted
        };
        final updatedTasks = List<Task>.from(_tasks);
        final updatedTask = Task(
          id: _tasks[taskIndex].id,
          iconData: _tasks[taskIndex].iconData,
          title: _tasks[taskIndex].title,
          bgColor: _tasks[taskIndex].bgColor,
          iconColor: _tasks[taskIndex].iconColor,
          btnColor: _tasks[taskIndex].btnColor,
          dueDate: _tasks[taskIndex].dueDate, // Preserve category's dueDate
          desc: [..._tasks[taskIndex].desc, updatedTaskDetail],
        );
        updatedTasks[taskIndex] = updatedTask;
        _tasks = updatedTasks;
        await _dbService.updateTask(updatedTask);
        // Schedule notification
        if (updatedTaskDetail['dueDate'] != null) {
          try {
            final dueDate = DateTime.parse(updatedTaskDetail['dueDate']);
            debugPrint('TaskProvider: Scheduling notification for task "${updatedTaskDetail['title']}" '
                'with dueDate=$dueDate, categoryId=$categoryId, taskIndex=${updatedTask.desc.length - 1}');
            await _notificationService.scheduleNotification(
              categoryId: categoryId,
              taskIndex: updatedTask.desc.length - 1,
              taskTitle: updatedTaskDetail['title'],
              dueDate: dueDate,
              isRepeated: updatedTaskDetail['isRepeated'] ?? false,
              repeatType: updatedTaskDetail['repeatType'],
              repeatDays: updatedTaskDetail['repeatDays'] != null
                  ? List<String>.from(updatedTaskDetail['repeatDays'])
                  : null,
              repeatDate: updatedTaskDetail['repeatDate'],
            );
            debugPrint('TaskProvider: Notification scheduled successfully');
          } catch (e) {
            debugPrint('TaskProvider: Error scheduling notification: $e');
          }
        } else {
          debugPrint('TaskProvider: No dueDate provided for task "${updatedTaskDetail['title']}"');
        }
        debugPrint('TaskProvider: Added task to category $categoryId: ${updatedTaskDetail['title']}');
        notifyListeners();
      } else {
        debugPrint('TaskProvider: Category $categoryId not found');
      }
    } catch (e) {
      debugPrint('TaskProvider: Error adding task: $e');
    }
  }

  Future<void> deleteTask(String categoryId, int taskIndex) async {
    try {
      final categoryIndex = _tasks.indexWhere((task) => task.id == categoryId);
      if (categoryIndex != -1) {
        final updatedTasks = List<Task>.from(_tasks);
        final updatedDesc = List<Map<String, dynamic>>.from(_tasks[categoryIndex].desc);
        updatedDesc.removeAt(taskIndex);

        final updatedTask = Task(
          id: _tasks[categoryIndex].id,
          iconData: _tasks[categoryIndex].iconData,
          title: _tasks[categoryIndex].title,
          bgColor: _tasks[categoryIndex].bgColor,
          iconColor: _tasks[categoryIndex].iconColor,
          btnColor: _tasks[categoryIndex].btnColor,
          dueDate: _tasks[categoryIndex].dueDate,
          desc: updatedDesc,
        );

        updatedTasks[categoryIndex] = updatedTask;
        _tasks = updatedTasks;
        await _dbService.updateTask(updatedTask);
        // Cancel notification
        debugPrint('TaskProvider: Cancelling notification for categoryId=$categoryId, taskIndex=$taskIndex');
        await _notificationService.cancelNotification(categoryId, taskIndex);
        debugPrint('TaskProvider: Deleted task at index $taskIndex from category $categoryId');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TaskProvider: Error deleting task: $e');
    }
  }

  Future<void> completeTask(String categoryId, int taskIndex) async {
    try {
      final categoryIndex = _tasks.indexWhere((task) => task.id == categoryId);
      if (categoryIndex != -1) {
        final updatedTasks = List<Task>.from(_tasks);
        final updatedDesc = List<Map<String, dynamic>>.from(_tasks[categoryIndex].desc);
        updatedDesc[taskIndex] = {
          ...updatedDesc[taskIndex],
          'isCompleted': true,
        };

        final updatedTask = Task(
          id: _tasks[categoryIndex].id,
          iconData: _tasks[categoryIndex].iconData,
          title: _tasks[categoryIndex].title,
          bgColor: _tasks[categoryIndex].bgColor,
          iconColor: _tasks[categoryIndex].iconColor,
          btnColor: _tasks[categoryIndex].btnColor,
          dueDate: _tasks[categoryIndex].dueDate,
          desc: updatedDesc,
        );

        updatedTasks[categoryIndex] = updatedTask;
        _tasks = updatedTasks;
        await _dbService.updateTask(updatedTask);
        // Cancel notification for completed task
        debugPrint('TaskProvider: Cancelling notification for completed task, '
            'categoryId=$categoryId, taskIndex=$taskIndex');
        await _notificationService.cancelNotification(categoryId, taskIndex);
        debugPrint('TaskProvider: Completed task at index $taskIndex in category $categoryId');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TaskProvider: Error completing task: $e');
    }
  }

  Future<void> updateTask(String categoryId, int taskIndex, Map<String, dynamic> updatedTask) async {
    try {
      final categoryIndex = _tasks.indexWhere((task) => task.id == categoryId);
      if (categoryIndex != -1) {
        final updatedTasks = List<Task>.from(_tasks);
        final updatedDesc = List<Map<String, dynamic>>.from(_tasks[categoryIndex].desc);
        updatedDesc[taskIndex] = {
          ...updatedTask,
          'isCompleted': updatedDesc[taskIndex]['isCompleted'] ?? false, // Preserve isCompleted
        };

        final updatedCategory = Task(
          id: _tasks[categoryIndex].id,
          iconData: _tasks[categoryIndex].iconData,
          title: _tasks[categoryIndex].title,
          bgColor: _tasks[categoryIndex].bgColor,
          iconColor: _tasks[categoryIndex].iconColor,
          btnColor: _tasks[categoryIndex].btnColor,
          dueDate: _tasks[categoryIndex].dueDate,
          desc: updatedDesc,
        );

        updatedTasks[categoryIndex] = updatedCategory;
        _tasks = updatedTasks;
        await _dbService.updateTask(updatedCategory);
        // Cancel existing notification
        debugPrint('TaskProvider: Cancelling existing notification for categoryId=$categoryId, taskIndex=$taskIndex');
        await _notificationService.cancelNotification(categoryId, taskIndex);
        // Schedule new notification if dueDate exists
        if (updatedTask['dueDate'] != null) {
          try {
            final dueDate = DateTime.parse(updatedTask['dueDate']);
            debugPrint('TaskProvider: Scheduling updated notification for task "${updatedTask['title']}" '
                'with dueDate=$dueDate, categoryId=$categoryId, taskIndex=$taskIndex');
            await _notificationService.scheduleNotification(
              categoryId: categoryId,
              taskIndex: taskIndex,
              taskTitle: updatedTask['title'],
              dueDate: dueDate,
              isRepeated: updatedTask['isRepeated'] ?? false,
              repeatType: updatedTask['repeatType'],
              repeatDays: updatedTask['repeatDays'] != null
                  ? List<String>.from(updatedTask['repeatDays'])
                  : null,
              repeatDate: updatedTask['repeatDate'],
            );
            debugPrint('TaskProvider: Updated notification scheduled successfully');
          } catch (e) {
            debugPrint('TaskProvider: Error scheduling updated notification: $e');
          }
        } else {
          debugPrint('TaskProvider: No dueDate provided for updated task "${updatedTask['title']}"');
        }
        debugPrint('TaskProvider: Updated task at index $taskIndex in category $categoryId');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TaskProvider: Error updating task: $e');
    }
  }

  List<Map<String, dynamic>> getTasksForCategory(
      String categoryId, {
        bool showRepeated = false,
        bool showToday = false,
        bool showFuture = false,
        bool showCompleted = false,
      }) {
    try {
      final category = _tasks.firstWhere((task) => task.id == categoryId);
      final filteredTasks = category.desc.where((task) {
        bool isRepeatedMatch;
        if (showRepeated) {
          isRepeatedMatch = task['isRepeated'] == true; // Only repeated tasks
        } else {
          isRepeatedMatch = true; // Include both repeated and non-repeated
        }

        final isTodayMatch = showToday ? _isTaskDueToday(task) : true;
        final isFutureMatch = showFuture ? _isTaskDueFuture(task) : true;
        final isCompletedMatch = showCompleted ? (task['isCompleted'] == true) : (task['isCompleted'] != true);

        debugPrint('TaskProvider: Filtering task "${task['title']}", dueDate=${task['dueDate']}, '
            'isRepeated=${task['isRepeated']}, isRepeatedMatch=$isRepeatedMatch, '
            'isTodayMatch=$isTodayMatch, isFutureMatch=$isFutureMatch, '
            'isCompletedMatch=$isCompletedMatch');

        return isRepeatedMatch && isTodayMatch && isFutureMatch && isCompletedMatch;
      }).toList();
      debugPrint('TaskProvider: Filtered ${filteredTasks.length} tasks for category $categoryId');
      return filteredTasks;
    } catch (e) {
      debugPrint('TaskProvider: Error filtering tasks: $e');
      return [];
    }
  }

  bool _isTaskDueToday(Map<String, dynamic> task) {
    final dueDateString = task['dueDate'];
    if (dueDateString == null) {
      debugPrint('TaskProvider: Task "${task['title']}" has no dueDate');
      return false;
    }
    try {
      final dueDate = DateTime.parse(dueDateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
      bool isToday = taskDate == today;

      if (task['isRepeated'] == true) {
        if (task['repeatType'] == 'weekly') {
          final repeatDays = List<String>.from(task['repeatDays'] ?? []);
          final todayWeekday = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ][now.weekday - 1]; // Adjust for 1-based weekday
          isToday = repeatDays.contains(todayWeekday);
          debugPrint('TaskProvider: Weekly task "${task['title']}", todayWeekday=$todayWeekday, '
              'repeatDays=$repeatDays, isToday=$isToday');
        } else if (task['repeatType'] == 'monthly') {
          final repeatDate = task['repeatDate'] as int?;
          isToday = repeatDate != null && now.day == repeatDate;
          debugPrint('TaskProvider: Monthly task "${task['title']}", repeatDate=$repeatDate, '
              'today=${now.day}, isToday=$isToday');
        } else if (task['repeatType'] == 'daily') {
          isToday = true; // Daily tasks are always due today
          debugPrint('TaskProvider: Daily task "${task['title']}", isToday=$isToday');
        }
      } else {
        debugPrint('TaskProvider: Non-repeated task "${task['title']}", '
            'taskDate=$taskDate, today=$today, isToday=$isToday');
      }

      return isToday;
    } catch (e) {
      debugPrint('TaskProvider: Error parsing due date for task "${task['title']}": $e');
      return false;
    }
  }

  bool _isTaskDueFuture(Map<String, dynamic> task) {
    final dueDateString = task['dueDate'];
    if (dueDateString == null) {
      debugPrint('TaskProvider: Task "${task['title']}" has no dueDate for future check');
      return false;
    }
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (task['isRepeated'] == true) {
        if (task['repeatType'] == 'daily') {
          debugPrint('TaskProvider: Daily task "${task['title']}" always has future occurrences');
          return true;
        } else if (task['repeatType'] == 'weekly') {
          final repeatDays = List<String>.from(task['repeatDays'] ?? []);
          final hasFuture = repeatDays.isNotEmpty;
          debugPrint('TaskProvider: Weekly task "${task['title']}", '
              'repeatDays=$repeatDays, hasFuture=$hasFuture');
          return hasFuture;
        } else if (task['repeatType'] == 'monthly') {
          final repeatDate = task['repeatDate'] as int?;
          final hasFuture = repeatDate != null && repeatDate >= 1 && repeatDate <= 31;
          debugPrint('TaskProvider: Monthly task "${task['title']}", '
              'repeatDate=$repeatDate, hasFuture=$hasFuture');
          return hasFuture;
        }
        debugPrint('TaskProvider: Invalid repeat type for task "${task['title']}"');
        return false; // Invalid repeat type
      } else {
        final dueDate = DateTime.parse(dueDateString);
        final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final isFuture = taskDate.isAfter(today);
        debugPrint('TaskProvider: Non-repeated task "${task['title']}", '
            'taskDate=$taskDate, today=$today, isFuture=$isFuture');
        return isFuture;
      }
    } catch (e) {
      debugPrint('TaskProvider: Error parsing due date for future check of task "${task['title']}": $e');
      return false;
    }
  }
}