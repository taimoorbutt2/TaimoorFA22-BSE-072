import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintTimelineService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> addTimelineEntry({
    required String complaintId,
    required String comment,
    required String status,
    required String createdBy,
  }) async {
    if (complaintId.isEmpty) {
      print('Error: complaintId is empty! Timeline entry not created.');
      return;
    }
    try {
      await _supabase.from('complaint_timeline').insert({
        'complaint_id': complaintId,
        'comment': comment,
        'status': status,
        'created_by': createdBy,
      });
    } catch (e) {
      print('Failed to add timeline entry: $e');
      throw Exception('Failed to add timeline entry: $e');
    }
  }
} 