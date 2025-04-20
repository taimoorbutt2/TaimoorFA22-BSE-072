import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService() {
    tz.initializeTimeZones();
    debugPrint('NotificationService: Timezone initialized');
  }

  Future<void> scheduleNotification({
    required String categoryId,
    required int taskIndex,
    required String taskTitle,
    required DateTime dueDate,
    bool isRepeated = false,
    String? repeatType,
    List<String>? repeatDays,
    int? repeatDate,
  }) async {
    final notificationId = _generateNotificationId(categoryId, taskIndex);
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    debugPrint('NotificationService: Scheduling notification ID=$notificationId, '
        'title="$taskTitle", dueDate=$dueDate, isRepeated=$isRepeated, '
        'repeatType=$repeatType, repeatDays=$repeatDays, repeatDate=$repeatDate');

    try {
      if (isRepeated && repeatType != null) {
        await _scheduleRepeatedNotification(
          notificationId,
          taskTitle,
          dueDate,
          repeatType,
          repeatDays,
          repeatDate,
          notificationDetails,
        );
      } else {
        final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
        debugPrint('NotificationService: Non-repeated notification scheduled for $scheduledDate');
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          taskTitle,
          'This task is due now!',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: '$categoryId:$taskIndex',
        );
      }
      debugPrint('NotificationService: Notification ID=$notificationId scheduled successfully');
    } catch (e) {
      debugPrint('NotificationService: Error scheduling notification: $e');
    }
  }

  Future<void> _scheduleRepeatedNotification(
      int notificationId,
      String taskTitle,
      DateTime dueDate,
      String repeatType,
      List<String>? repeatDays,
      int? repeatDate,
      NotificationDetails notificationDetails,
      ) async {
    debugPrint('NotificationService: Scheduling repeated notification, '
        'type=$repeatType, dueDate=$dueDate');

    try {
      if (repeatType == 'daily') {
        final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);
        debugPrint('NotificationService: Daily notification scheduled for $scheduledDate');
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          taskTitle,
          'This task is due now!',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: notificationId.toString(),
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (repeatType == 'weekly' && repeatDays != null && repeatDays.isNotEmpty) {
        for (String day in repeatDays) {
          final dayIndex = _getDayIndex(day);
          final nextOccurrence = _getNextOccurrenceForDay(dueDate, dayIndex);
          final scheduledDate = tz.TZDateTime.from(nextOccurrence, tz.local);
          final weeklyNotificationId = _generateNotificationId(notificationId.toString(), dayIndex);
          debugPrint('NotificationService: Weekly notification ID=$weeklyNotificationId '
              'for $day scheduled for $scheduledDate');
          await flutterLocalNotificationsPlugin.zonedSchedule(
            weeklyNotificationId,
            taskTitle,
            'This task is due now!',
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            payload: notificationId.toString(),
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      } else if (repeatType == 'monthly' && repeatDate != null) {
        final nextOccurrence = _getNextMonthlyOccurrence(dueDate, repeatDate);
        final scheduledDate = tz.TZDateTime.from(nextOccurrence, tz.local);
        debugPrint('NotificationService: Monthly notification scheduled for $scheduledDate');
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          taskTitle,
          'This task is due now!',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: notificationId.toString(),
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
      }
    } catch (e) {
      debugPrint('NotificationService: Error scheduling repeated notification: $e');
    }
  }

  Future<void> cancelNotification(String categoryId, int taskIndex) async {
    final notificationId = _generateNotificationId(categoryId, taskIndex);
    debugPrint('NotificationService: Cancelling notification ID=$notificationId');
    try {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      // Cancel weekly notifications for all days
      for (int i = 1; i <= 7; i++) {
        final weeklyNotificationId = _generateNotificationId(notificationId.toString(), i);
        debugPrint('NotificationService: Cancelling weekly notification ID=$weeklyNotificationId');
        await flutterLocalNotificationsPlugin.cancel(weeklyNotificationId);
      }
      debugPrint('NotificationService: Notification ID=$notificationId cancelled successfully');
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notification: $e');
    }
  }

  int _generateNotificationId(String categoryId, dynamic index) {
    final id = (categoryId.hashCode + index.toString().hashCode).abs() % 1000000;
    debugPrint('NotificationService: Generated notification ID=$id for category=$categoryId, index=$index');
    return id;
  }

  int _getDayIndex(String day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final index = days.indexOf(day) + 1;
    debugPrint('NotificationService: Day $day mapped to index $index');
    return index;
  }

  DateTime _getNextOccurrenceForDay(DateTime dueDate, int dayIndex) {
    final now = DateTime.now();
    var next = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueDate.hour,
      dueDate.minute,
    );
    while (next.weekday != dayIndex || next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    debugPrint('NotificationService: Next occurrence for dayIndex=$dayIndex is $next');
    return next;
  }

  DateTime _getNextMonthlyOccurrence(DateTime dueDate, int repeatDate) {
    final now = DateTime.now();
    var next = DateTime(dueDate.year, dueDate.month, repeatDate, dueDate.hour, dueDate.minute);
    while (next.isBefore(now)) {
      next = DateTime(next.year, next.month + 1, repeatDate, next.hour, next.minute);
    }
    debugPrint('NotificationService: Next monthly occurrence for day=$repeatDate is $next');
    return next;
  }
}