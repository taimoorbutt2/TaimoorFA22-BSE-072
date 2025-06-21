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
                            // Stats Section with more height
                            Container(
                              height: 140, // Increased from 120 to 140 (+20px to eliminate overflow)
                              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      ' Complaints',
                                      _complaints.length.toString(),
                                      Icons.report,
                                      [Colors.blue.shade400, Colors.blue.shade600],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Pending',
                                      _complaints.where((c) => c.status == 'Submitted').length.toString(),
                                      Icons.pending,
                                      [Colors.orange.shade400, Colors.orange.shade600],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                            // Submit Button in Middle
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: GlassmorphicContainer(
                                width: double.infinity,
                                height: 60,
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
                                    Colors.deepPurple.withOpacity(0.5),
                                    Colors.deepPurple.withOpacity(0.5),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SubmitComplaintScreen()),
                                    ).then((_) => _loadComplaints()),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.deepPurple.withOpacity(0.1),
                                            Colors.deepPurple.withOpacity(0.05),
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.deepPurple.shade400,
                                                  Colors.deepPurple.shade600,
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Submit New Complaint',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Complaints Section at Bottom with Scroll
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: GlassmorphicContainer(
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
                                      Colors.purple.shade400.withOpacity(0.5),
                                      Colors.purple.shade600.withOpacity(0.5),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.purple.shade50.withOpacity(0.3),
                                          Colors.blue.shade50.withOpacity(0.2),
                                          Colors.indigo.shade50.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.purple.shade400,
                                                      Colors.purple.shade600,
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.assignment,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Recent Complaints',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.purple.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: _complaints.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(16),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.grey.shade300,
                                                              Colors.grey.shade400,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.inbox_outlined,
                                                          size: 48,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Text(
                                                        'No complaints yet',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey.shade600,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Submit your first complaint to get started',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey.shade500,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : ListView.builder(
                                                  physics: const BouncingScrollPhysics(),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  itemCount: _complaints.length,
                                                  itemBuilder: (context, index) {
                                                    final complaint = _complaints[index];
                                                    return AnimatedContainer(
                                                      duration: Duration(milliseconds: 300 + (index * 100)),
                                                      margin: const EdgeInsets.only(bottom: 12),
                                                      child: _buildComplaintCard(complaint),
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
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
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: gradient),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: gradient[1],
                ),
              ),
              const SizedBox(height: 2),
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

  Widget _buildComplaintCard(Complaint complaint) {
    Color statusColor;
    IconData statusIcon;
    
    switch (complaint.status) {
      case 'Submitted':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'Under Review':
        statusColor = Colors.blue;
        statusIcon = Icons.visibility;
        break;
      case 'In Progress':
        statusColor = Colors.purple;
        statusIcon = Icons.engineering;
        break;
      case 'Resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return GlassmorphicContainer(
      width: double.infinity,
      height: 110,
      borderRadius: 16,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.7),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          statusColor.withOpacity(0.3),
          statusColor.withOpacity(0.3),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.05),
              statusColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ComplaintDetailsScreen(complaint: complaint),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.8),
                          statusColor,
                        ],
                      ),
                    ),
                    child: Icon(statusIcon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          complaint.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: statusColor.withOpacity(0.1),
                              ),
                              child: Text(
                                complaint.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(complaint.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 14,
                  ),
                ],
              ),
            ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 