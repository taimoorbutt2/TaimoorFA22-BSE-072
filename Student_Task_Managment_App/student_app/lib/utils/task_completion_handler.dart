import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskCompletionHandler {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> markTaskComplete({
    required Task task,
    required String studentId,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      debugPrint('TaskCompletionHandler: Marking task ${task.id} as completed');
      debugPrint('TaskCompletionHandler: Student ID: $studentId, assigned_to: ${task.assignedTo}');

      // Verify task exists and is assigned to the student
      final verification = await _client
          .from('tasks')
          .select('id, assigned_to')
          .eq('id', task.id)
          .maybeSingle();
      debugPrint('TaskCompletionHandler: Verification response: $verification');

      if (verification == null) {
        throw Exception('Task not found');
      }
      if (verification['assigned_to'] != studentId) {
        throw Exception('Task is not assigned to the provided student ID');
      }

      // Perform the update
      final response = await _client.from('tasks').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', task.id).select().single();
      debugPrint('TaskCompletionHandler: Update response: $response');

      // Only call onSuccess if update returns data
      if (response['status'] == 'completed') {
        onSuccess();
        debugPrint('TaskCompletionHandler: Task ${task.id} marked as completed successfully');
        return true;
      } else {
        throw Exception('Update failed: Response did not confirm completion');
      }
    } catch (e) {
      debugPrint('TaskCompletionHandler: Error marking task ${task.id}: $e');
      onError(e.toString());
      return false;
    }
  }
}