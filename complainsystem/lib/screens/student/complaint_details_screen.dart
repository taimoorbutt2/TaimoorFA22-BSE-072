import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_gradient/animate_gradient.dart';
import '../../models/complaint.dart';
import '../../models/complaint_timeline.dart';
import '../../models/user.dart' as app_user;
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  List<ComplaintTimeline> _timeline = [];
  Map<String, String> _userNames = {}; // Map to store user ID to name mapping
  app_user.User? _student;
  app_user.User? _advisor;
  app_user.User? _hod;
  bool _isLoading = true;
  RealtimeChannel? _timelineChannel;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _timelineChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final timeline = await SupabaseService.getComplaintTimeline(widget.complaint.id);
      final student = await SupabaseService.getProfile(widget.complaint.studentId);
      
      app_user.User? advisor;
      app_user.User? hod;
      
      if (widget.complaint.advisorId != null) {
        advisor = await SupabaseService.getProfile(widget.complaint.advisorId!);
      }
      if (widget.complaint.hodId != null) {
        hod = await SupabaseService.getProfile(widget.complaint.hodId!);
      }

      // Load user names for timeline entries
      Map<String, String> userNames = {};
      for (var entry in timeline) {
        if (!userNames.containsKey(entry.createdBy)) {
          try {
            final user = await SupabaseService.getProfile(entry.createdBy);
            if (user != null) {
              userNames[entry.createdBy] = user.name;
            } else {
              userNames[entry.createdBy] = 'Unknown User';
            }
          } catch (e) {
            userNames[entry.createdBy] = 'Unknown User';
          }
        }
      }

      setState(() {
        _timeline = timeline;
        _userNames = userNames;
        _student = student;
        _advisor = advisor;
        _hod = hod;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _setupRealtimeSubscription() {
    _timelineChannel = SupabaseService.subscribeToTimeline(
      widget.complaint.id,
      (payload) {
        // Refresh timeline when there's an update
        _loadData();
      },
    );
  }

  Future<void> _openMediaUrl() async {
    if (widget.complaint.mediaUrl == null || widget.complaint.mediaUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No media URL available'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(widget.complaint.mediaUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open media URL'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid media URL'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaint Details',
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
            onPressed: _loadData,
            tooltip: 'Refresh',
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  strokeWidth: 3,
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Complaint Header Card
                      GlassmorphicContainer(
                        width: double.infinity,
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
                            Colors.deepPurple.withOpacity(0.5),
                            Colors.deepPurple.withOpacity(0.5),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getStatusColor(widget.complaint.status),
                                          _getStatusColor(widget.complaint.status).withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.complaint.title[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.complaint.title,
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(widget.complaint.status).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _getStatusColor(widget.complaint.status).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            widget.complaint.status,
                                            style: TextStyle(
                                              color: _getStatusColor(widget.complaint.status),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.complaint.description,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              if (widget.complaint.mediaUrl != null && widget.complaint.mediaUrl!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.withOpacity(0.1),
                                        Colors.deepPurple.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _openMediaUrl,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.link,
                                              color: Colors.deepPurple,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'View Media',
                                              style: TextStyle(
                                                color: Colors.deepPurple,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // User Information Card
                      GlassmorphicContainer(
                        width: double.infinity,
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
                            Colors.deepPurple.withOpacity(0.5),
                            Colors.deepPurple.withOpacity(0.5),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.people,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'User Information',
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_student != null) ...[
                                        _buildInfoRow('Student', _student!.name, Icons.person),
                                        _buildInfoRow('Email', _student!.email, Icons.email),
                                        if (_student!.phoneNo != null)
                                          _buildInfoRow('Phone', _student!.phoneNo!, Icons.phone),
                                        if (_student!.studentId != null)
                                          _buildInfoRow('Student ID', _student!.studentId!, Icons.badge),
                                      ],
                                      if (_advisor != null) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow('Batch Advisor', _advisor!.name, Icons.school),
                                      ],
                                      if (_hod != null) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow('HOD', _hod!.name, Icons.admin_panel_settings),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Timeline Card
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: 350,
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
                            Colors.deepPurple.withOpacity(0.5),
                            Colors.deepPurple.withOpacity(0.5),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.timeline,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Timeline',
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_timeline.length} entries',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _timeline.isEmpty
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              color: Colors.grey,
                                              size: 48,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'No timeline entries yet',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: _timeline.length,
                                        itemBuilder: (context, index) {
                                          final entry = _timeline[index];
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.deepPurple.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(entry.status ?? ''),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      entry.status?[0].toUpperCase() ?? 'T',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (entry.status != null) ...[
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: _getStatusColor(entry.status!).withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(
                                                              color: _getStatusColor(entry.status!).withOpacity(0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            entry.status!,
                                                            style: TextStyle(
                                                              color: _getStatusColor(entry.status!),
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 6),
                                                      ],
                                                      if (entry.comment != null && entry.comment!.isNotEmpty) ...[
                                                        Text(
                                                          entry.comment!,
                                                          style: const TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 12,
                                                            height: 1.3,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 6),
                                                      ],
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.person,
                                                            size: 10,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'By: ${_getUserDisplayName(entry.createdBy)}',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.grey.shade600,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                            _formatDate(entry.createdAt),
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.grey.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getUserDisplayName(String userId) {
    final userName = _userNames[userId] ?? 'Unknown User';
    
    // Check if it's the current student
    if (_student != null && userId == _student!.id) {
      return 'Student';
    }
    
    // Check if it's the advisor
    if (_advisor != null && userId == _advisor!.id) {
      return 'Batch Advisor';
    }
    
    // Check if it's the HOD
    if (_hod != null && userId == _hod!.id) {
      return 'HOD';
    }
    
    // If we have the user name but can't determine role, show the name
    if (userName != 'Unknown User') {
      return userName;
    }
    
    return 'Unknown User';
  }
} 