import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../models/batch.dart';
import '../models/complaint.dart';
import '../models/complaint_timeline.dart';
import '../utils/constants.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Authentication Methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? batchId,
    String? phoneNo,
    String? studentId,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create profile
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'role': role,
          'name': name,
          'batch_id': batchId,
          'department_id': await _getDepartmentId(),
          'phone_no': phoneNo,
          'student_id': studentId,
        });
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Profile Methods
  static Future<app_user.User?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return app_user.User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<app_user.User?> getProfileByStudentId(String studentId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('student_id', studentId)
          .single();
      return app_user.User.fromJson(response);
    } catch (e) {
      // If single() throws, it means 0 or more than 1 rows were found. We can assume no user found.
      return null;
    }
  }

  static Future<List<app_user.User>> getAllProfiles({String? role}) async {
    try {
      var query = _supabase.from('profiles').select();
      if (role != null) {
        query = query.eq('role', role);
      }
      final response = await query.order('created_at', ascending: false);
      
      return (response as List).map((json) => app_user.User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch profiles: $e');
    }
  }

  static Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Batch Methods
  static Future<List<Batch>> getAllBatches() async {
    try {
      final response = await _supabase
          .from('batches')
          .select()
          .order('batch_name', ascending: true);
      
      return (response as List).map((json) => Batch.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch batches: $e');
    }
  }

  static Future<Batch?> getBatch(String batchId) async {
    try {
      final response = await _supabase
          .from('batches')
          .select()
          .eq('id', batchId)
          .single();
      
      return Batch.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> createBatch(String batchName) async {
    try {
      await _supabase.from('batches').insert({
        'batch_name': batchName,
        'department_id': await _getDepartmentId(),
      });
    } catch (e) {
      throw Exception('Failed to create batch: $e');
    }
  }

  static Future<String?> _getOrCreateDefaultBatch() async {
    try {
      // Try to get the first available batch
      final response = await _supabase
          .from('batches')
          .select('id')
          .limit(1)
          .single();
      
      return response['id'];
    } catch (e) {
      // If no batches exist, create a default one
      try {
        final response = await _supabase
            .from('batches')
            .insert({
              'batch_name': 'FA22',
              'department_id': await _getDepartmentId(),
            })
            .select('id')
            .single();
        
        return response['id'];
      } catch (e) {
        return null;
      }
    }
  }

  static Future<void> assignAdvisorToBatch(String batchId, String advisorId) async {
    try {
      await _supabase
          .from('batches')
          .update({'advisor_id': advisorId})
          .eq('id', batchId);
    } catch (e) {
      throw Exception('Failed to assign advisor: $e');
    }
  }

  // Complaint Methods
  static Future<List<Complaint>> getComplaints({
    String? studentId,
    String? advisorId,
    String? hodId,
    String? status,
  }) async {
    try {
      var query = _supabase.from('complaints').select();
      
      if (studentId != null) {
        query = query.eq('student_id', studentId);
      }
      if (advisorId != null) {
        query = query.eq('advisor_id', advisorId);
      }
      if (hodId != null) {
        query = query.eq('hod_id', hodId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }
      
      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => Complaint.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch complaints: $e');
    }
  }

  static Future<Complaint?> getComplaint(String complaintId) async {
    try {
      final response = await _supabase
          .from('complaints')
          .select()
          .eq('id', complaintId)
          .single();
      
      return Complaint.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> createComplaint(Map<String, dynamic> complaintData) async {
    try {
      final response = await _supabase
          .from('complaints')
          .insert(complaintData)
          .select('id')
          .single();
      return response['id'] as String?;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  static Future<void> updateComplaint(String complaintId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('complaints')
          .update(data)
          .eq('id', complaintId);
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  // Complaint Timeline Methods
  static Future<List<ComplaintTimeline>> getComplaintTimeline(String complaintId) async {
    try {
      final response = await _supabase
          .from('complaint_timeline')
          .select()
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);
      
      return (response as List).map((json) => ComplaintTimeline.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch timeline: $e');
    }
  }

  static Future<void> addTimelineEntry(Map<String, dynamic> timelineData) async {
    try {
      await _supabase.from('complaint_timeline').insert(timelineData);
    } catch (e) {
      throw Exception('Failed to add timeline entry: $e');
    }
  }

  // Helper Methods
  static Future<String> _getDepartmentId() async {
    try {
      final response = await _supabase
          .from('departments')
          .select('id')
          .eq('name', AppConstants.departmentName)
          .single();
      
      return response['id'];
    } catch (e) {
      // If department doesn't exist, create it
      return await _createDepartment();
    }
  }

  static Future<String> _createDepartment() async {
    try {
      final response = await _supabase
          .from('departments')
          .insert({
            'name': AppConstants.departmentName,
            'description': 'Computer Science Department',
          })
          .select('id')
          .single();
      
      return response['id'];
    } catch (e) {
      throw Exception('Failed to create department: $e');
    }
  }

  static Future<int> getSameTitleComplaintCount(String title) async {
    try {
      final response = await _supabase
          .from('complaints')
          .select('id')
          .eq('title', title)
          .not('status', 'in', '(Resolved,Rejected)');
      
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  static Future<app_user.User?> getHOD() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'hod')
          .single();
      
      return app_user.User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Real-time subscriptions (simplified for now)
  static RealtimeChannel subscribeToComplaints(String userId, Function(Map<String, dynamic>) onData) {
    return _supabase
        .channel('complaints')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'complaints',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'student_id',
            value: userId,
          ),
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToTimeline(String complaintId, Function(Map<String, dynamic>) onData) {
    return _supabase
        .channel('timeline')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'complaint_timeline',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'complaint_id',
            value: complaintId,
          ),
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }
} 