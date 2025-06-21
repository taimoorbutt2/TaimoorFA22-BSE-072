import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_gradient/animate_gradient.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart' as app_user;
import '../../models/complaint.dart';
import '../../models/complaint_timeline.dart';
import '../../utils/constants.dart';
import 'submit_complaint_screen.dart';
import 'complaint_details_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  app_user.User? _currentUser;
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  RealtimeChannel? _complaintChannel;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _loadUserData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _complaintChannel?.unsubscribe();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    
    try {
      final user = SupabaseService.getCurrentUser();
      if (user != null) {
        final profile = await SupabaseService.getProfile(user.id);
        if (profile != null) {
          setState(() {
            _currentUser = profile;
          });
          await _loadComplaints();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComplaints() async {
    if (_currentUser == null) return;
    
    try {
      final complaints = await SupabaseService.getComplaints(
        studentId: _currentUser!.id,
      );
      setState(() {
        _complaints = complaints;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading complaints: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _setupRealtimeSubscription() {
    final user = SupabaseService.getCurrentUser();
    if (user != null) {
      _complaintChannel = SupabaseService.subscribeToComplaints(
        user.id,
        (payload) {
          // Refresh complaints when there's an update
          _loadComplaints();
        },
      );
    }
  }

  void _signOut(BuildContext context) async {
    // Add scale animation for button press
    _scaleController.reverse().then((_) {
      _scaleController.forward();
    });
    
    await SupabaseService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${_currentUser?.name ?? 'Student'}',
          style: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomRight,
        secondaryBegin: Alignment.bottomLeft,
        secondaryEnd: Alignment.topRight,
        primaryColors: const [
          Color(0xFFE3F2FD),
          Color(0xFFF3E5F5),
          Color(0xFFE8F5E8),
        ],
        secondaryColors: const [
          Color(0xFFF3E5F5),
          Color(0xFFE8F5E8),
          Color(0xFFE3F2FD),
        ],
        child: Stack(
          children: [
            // Decorative shapes with animation
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 100,
                        right: 50,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                          child: _buildShape(Colors.blue.withOpacity(0.1), 150),
                        ),
                      ),
                      Positioned(
                        top: 300,
                        left: 30,
                        child: Transform.translate(
                          offset: Offset(0, -20 * (1 - _fadeAnimation.value)),
                          child: _buildShape(Colors.purple.withOpacity(0.1), 100),
                        ),
                      ),
                      Positioned(
                        bottom: 200,
                        right: 100,
                        child: Transform.translate(
                          offset: Offset(20 * (1 - _fadeAnimation.value), 0),
                          child: _buildShape(Colors.green.withOpacity(0.1), 120),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Main content with slide animation
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isLoading
                    ? Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: GlassmorphicContainer(
                            width: 100,
                            height: 100,
                            borderRadius: 20,
                            blur: 15,
                            alignment: Alignment.center,
                            border: 2,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.white70],
                            ),
                            borderGradient: LinearGradient(
                              colors: [Colors.white, Colors.white70],
                            ),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      )
                    : SafeArea(
                        child: Column(
                          children: [
                            // Stats Section
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Complaints',
                                      _complaints.length.toString(),
                                      Icons.report,
                                      [Colors.blue.shade400, Colors.blue.shade600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Pending',
                                      _complaints.where((c) => c.status == 'Submitted').length.toString(),
                                      Icons.pending,
                                      [Colors.orange.shade400, Colors.orange.shade600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Resolved',
                                      _complaints.where((c) => c.status == 'Resolved').length.toString(),
                                      Icons.check_circle,
                                      [Colors.green.shade400, Colors.green.shade600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Complaints Section
                            Expanded(
                              child: _complaints.isEmpty
                                  ? Center(
                                      child: GlassmorphicContainer(
                                        width: 300,
                                        height: 200,
                                        borderRadius: 20,
                                        blur: 15,
                                        alignment: Alignment.center,
                                        border: 2,
                                        linearGradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.8),
                                            Colors.white.withOpacity(0.6),
                                          ],
                                        ),
                                        borderGradient: LinearGradient(
                                          colors: [
                                            Colors.deepPurple.withOpacity(0.3),
                                            Colors.deepPurple.withOpacity(0.3),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No complaints yet',
                                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Submit your first complaint to get started',
                                              style: TextStyle(color: Colors.grey.shade500),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GlassmorphicContainer(
                                      width: double.infinity,
                                      height: double.infinity,
                                      borderRadius: 20,
                                      blur: 15,
                                      alignment: Alignment.center,
                                      border: 2,
                                      linearGradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.8),
                                          Colors.white.withOpacity(0.6),
                                        ],
                                      ),
                                      borderGradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.withOpacity(0.3),
                                          Colors.deepPurple.withOpacity(0.3),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _complaints.length,
                                        itemBuilder: (context, index) {
                                          final complaint = _complaints[index];
                                          return AnimatedBuilder(
                                            animation: _fadeAnimation,
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                                                child: Opacity(
                                                  opacity: _fadeAnimation.value,
                                                  child: _buildComplaintTile(complaint),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubmitComplaintScreen()),
          ).then((_) => _loadComplaints()),
          icon: const Icon(Icons.add),
          label: const Text('Submit Complaint'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> gradient) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 16,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.6),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          gradient[0].withOpacity(0.5),
          gradient[1].withOpacity(0.5),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient[0].withOpacity(0.1),
              gradient[1].withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: gradient),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: gradient[1],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintTile(Complaint complaint) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.3),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(complaint.status).withOpacity(0.2),
          child: Text(
            complaint.title[0].toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(complaint.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          complaint.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.description,
              style: TextStyle(color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    complaint.status,
                    style: TextStyle(
                      color: _getStatusColor(complaint.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(complaint.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintDetailsScreen(complaint: complaint),
          ),
        ),
      ),
    );
  }

  Widget _buildShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Escalated':
        return Colors.red;
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 