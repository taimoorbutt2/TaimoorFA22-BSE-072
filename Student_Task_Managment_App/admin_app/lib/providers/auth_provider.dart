import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_user.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  AdminUser? _adminUser;
  bool _isLoading = false;
  String? _error;

  AdminUser? get adminUser => _adminUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      await _fetchAdminUser(session.user.id);
    }
  }

  Future<void> login(String email, String password) async {
    setState(true);
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await _fetchAdminUser(user.id);
      } else {
        _error = 'Login failed: No user found';
      }
    } catch (e) {
      _error = 'Login failed: $e';
    } finally {
      setState(false);
    }
  }

  Future<void> _fetchAdminUser(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .eq('role', 'admin')
          .maybeSingle();
      if (response != null) {
        _adminUser = AdminUser.fromJson(response, uid);
        _error = null;
      } else {
        _error = 'User is not an admin';
        await _client.auth.signOut();
      }
    } catch (e) {
      _error = 'Error fetching user: $e';
      debugPrint('Fetch admin user error: $e');
      await _client.auth.signOut();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _adminUser = null;
    _error = null;
    notifyListeners();
  }

  void setState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}