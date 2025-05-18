import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';

import '../models/user.dart' as local_user;
import '../models/task.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<local_user.User>> getStudents() async {
    try {
      final response = await _client.from('users').select().eq('role', 'student');
      debugPrint('Fetched students: ${response.length}');
      return response.map((data) => local_user.User.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<String> addStudent(String name) async {
    try {
      final response = await _client.from('users').insert({
        'name': name,
        'email': null,
        'role': 'student',
      }).select('id').single();
      final String id = response['id'];
      debugPrint('Student added: $name with ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error adding student: $e');
      throw Exception('Failed to add student: $e');
    }
  }

  Future<void> updateStudent(String id, String newName) async {
    try {
      await _client.from('users').update({
        'name': newName,
      }).eq('id', id);
      debugPrint('Student updated: $id with new name: $newName');
    } catch (e) {
      debugPrint('Error updating student: $e');
      throw Exception('Failed to update student: $e');
    }
  }

  Future<void> bulkAddStudents(PlatformFile file) async {
    try {
      final content = utf8.decode(file.bytes!);
      final csv = const CsvToListConverter().convert(content);
      final students = csv.skip(1).map((row) => {
        'name': row[0].toString(),
        'email': null,
        'role': 'student',
      }).toList();
      await _client.from('users').insert(students);
      debugPrint('Bulk added ${students.length} students');
    } catch (e) {
      debugPrint('Error bulk adding students: $e');
      throw Exception('Failed to bulk add students: $e');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _client.from('users').delete().eq('id', id);
      debugPrint('Student deleted: $id');
    } catch (e) {
      debugPrint('Error deleting student: $e');
      throw Exception('Failed to delete student: $e');
    }
  }

  Future<void> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime dueDate,
    required String createdBy,
  }) async {
    try {
      await _client.from('tasks').insert({
        'title': title,
        'description': description,
        'assigned_to': assignedTo,
        'due_date': dueDate.toIso8601String(),
        'created_by': createdBy,
        'status': 'pending',
      });
      debugPrint('Task assigned: $title to $assignedTo');
    } catch (e) {
      debugPrint('Error assigning task: $e');
      throw Exception('Failed to assign task: $e');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final response = await _client.from('tasks').select();
      debugPrint('Fetched tasks: ${response.length}');
      return response.map((data) => Task.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<List<Task>> getTasksForStudent(String studentId) async {
    try {
      final response = await _client.from('tasks').select().eq('assigned_to', studentId);
      debugPrint('Fetched tasks for student $studentId: ${response.length}');
      return response.map((data) => Task.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks for student: $e');
      throw Exception('Failed to fetch tasks for student: $e');
    }
  }

  void subscribeToTasks(Function(List<Task>) onUpdate) {
    try {
      final channel = _client.channel('public:tasks');

      channel
          .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tasks',
        callback: (PostgresChangePayload payload) {
          debugPrint('Received task update: ${payload.newRecord}');
          getTasks().then(onUpdate);
        },
      )
          .subscribe();
    } catch (e) {
      debugPrint('Error subscribing to tasks: $e');
      throw Exception('Failed to subscribe to tasks: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final students = await getStudents();
      final tasks = await getTasks();
      final today = DateTime.now();
      final tasksToday = tasks.where((task) =>
      task.createdAt.day == today.day &&
          task.createdAt.month == today.month &&
          task.createdAt.year == today.year).length;
      final pendingTasks = tasks.where((task) => task.status == 'pending').length;
      final completedTasks = tasks.where((task) => task.status == 'completed').length;

      final stats = {
        'total_students': students.length,
        'tasks_today': tasksToday,
        'pending_tasks': pendingTasks,
        'completed_tasks': completedTasks,
      };
      debugPrint('Dashboard stats: $stats');
      return stats;
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStudentPerformance() async {
    try {
      final students = await getStudents();
      final List<Map<String, dynamic>> performance = [];
      for (var student in students) {
        final tasks = await getTasksForStudent(student.id);
        final completed = tasks.where((task) => task.status == 'completed').length;
        final total = tasks.length;
        final score = total > 0 ? (completed / total) * 100 : 0;
        performance.add({
          'student_id': student.id,
          'name': student.name,
          'completed_tasks': completed,
          'total_tasks': total,
          'performance_score': score,
        });
      }
      final sorted = performance..sort((a, b) => b['performance_score'].compareTo(a['performance_score']));
      debugPrint('Student performance: $sorted');
      return sorted;
    } catch (e) {
      debugPrint('Error fetching student performance: $e');
      throw Exception('Failed to fetch student performance: $e');
    }
  }
}