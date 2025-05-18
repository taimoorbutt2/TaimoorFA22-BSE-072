import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/constants.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<dynamic> Function(DateTime) eventLoader;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      eventLoader: eventLoader,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}