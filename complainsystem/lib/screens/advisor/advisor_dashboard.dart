import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart' as app_user;
import '../../models/complaint.dart';
import '../../models/complaint_timeline.dart';
import '../../utils/constants.dart';
import 'complaint_action_screen.dart';

class AdvisorDashboard extends StatefulWidget {
  const AdvisorDashboard({super.key});

  @override
  State<AdvisorDashboard> createState() => _AdvisorDashboardState();
}

class _AdvisorDashboardState extends State<AdvisorDashboard>
    with TickerProviderStateMixin {
  app_user.User? _currentUser;
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  String _selectedStatus = 'All';
  RealtimeChannel? _complaintChannel;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupRealtimeSubscription();
    
    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  @override
  void dispose() {
    _complaintChannel?.unsubscribe();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
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
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComplaints() async {
    if (_currentUser == null) return;
    
    try {
      final complaints = await SupabaseService.getComplaints(
        advisorId: _currentUser!.id,
      );
      setState(() {
        _complaints = complaints;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading complaints: $e')),
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
    await SupabaseService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  List<Complaint> get _filteredComplaints {
    if (_selectedStatus == 'All') {
      return _complaints;
    }
    return _complaints.where((c) => c.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFFE3F2FD),
              Color(0xFFF3E5F5),
              Color(0xFFE8F5E8),
              Color(0xFFF3E5F5),
              Color(0xFFE8F5E8),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
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
                            // Header with actions
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Welcome, ${_currentUser?.name ?? 'Advisor'}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple.shade800,
                                      ),
                                    ),
                                  ),
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.8),
                                            Colors.white.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: _loadUserData,
                                        icon: Icon(Icons.refresh, color: Colors.deepPurple.shade600),
                                        tooltip: 'Refresh',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.8),
                                            Colors.white.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: () => _signOut(context),
                                        icon: Icon(Icons.logout, color: Colors.deepPurple.shade600),
                                        tooltip: 'Sign Out',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Statistics Cards
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total',
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
                                      'In Progress',
                                      _complaints.where((c) => c.status == 'In Progress').length.toString(),
                                      Icons.trending_up,
                                      [Colors.purple.shade400, Colors.purple.shade600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Filter Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    Colors.indigo.shade400.withOpacity(0.5),
                                    Colors.indigo.shade600.withOpacity(0.5),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.indigo.shade50.withOpacity(0.3),
                                        Colors.blue.shade50.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.indigo.shade400,
                                                Colors.indigo.shade600,
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.filter_list,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Filter by status:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: DropdownButton<String>(
                                            value: _selectedStatus,
                                            isExpanded: true,
                                            underline: Container(),
                                            items: [
                                              'All',
                                              ...AppConstants.complaintStatuses,
                                            ].map((status) {
                                              return DropdownMenuItem(value: status, child: Text(status));
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedStatus = value!;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Complaints List
                            Expanded(
                              child: _filteredComplaints.isEmpty
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
                                            'No complaints found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Complaints will appear here when assigned',
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
                                      physics: const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: _filteredComplaints.length,
                                      itemBuilder: (context, index) {
                                        final complaint = _filteredComplaints[index];
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

  Widget _buildShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
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
      height: 125,
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComplaintActionScreen(complaint: complaint),
              ),
            ).then((_) => _loadComplaints()),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.8),
                          statusColor,
                        ],
                      ),
                    ),
                    child: Icon(statusIcon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: statusColor.withOpacity(0.1),
                              ),
                              child: Text(
                                complaint.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(complaint.createdAt),
                              style: TextStyle(
                                fontSize: 12,
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
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 