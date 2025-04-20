import 'package:flutter/material.dart';

class Task {
  final String id;
  final IconData iconData;
  final String title;
  final Color bgColor;
  final Color iconColor;
  final Color btnColor;
  final DateTime? dueDate;
  final List<Map<String, dynamic>> desc;

  Task({
    required this.id,
    required this.iconData,
    required this.title,
    required this.bgColor,
    required this.iconColor,
    required this.btnColor,
    this.dueDate,
    required this.desc,
  });
}