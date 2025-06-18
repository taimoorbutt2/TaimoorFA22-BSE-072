import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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

      setState(() {
        _timeline = timeline;
        _student = student;
        _advisor = advisor;
        _hod = hod;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
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
        const SnackBar(content: Text('No media URL available')),
      );
      return;
    }

    try {
      final uri = Uri.parse(widget.complaint.mediaUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open media URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid media URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getStatusColor(widget.complaint.status),
                                child: Text(
                                  widget.complaint.title[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.complaint.title,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(widget.complaint.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.complaint.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (widget.complaint.mediaUrl != null && widget.complaint.mediaUrl!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _openMediaUrl,
                              icon: const Icon(Icons.link),
                              label: const Text('View Media'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_student != null) ...[
                            Text('Student: ${_student!.name}'),
                            Text('Email: ${_student!.email}'),
                            if (_student!.phoneNo != null)
                              Text('Phone: ${_student!.phoneNo}'),
                            if (_student!.studentId != null)
                              Text('Student ID: ${_student!.studentId}'),
                          ],
                          if (_advisor != null) ...[
                            const SizedBox(height: 8),
                            Text('Batch Advisor: ${_advisor!.name}'),
                          ],
                          if (_hod != null) ...[
                            const SizedBox(height: 8),
                            Text('HOD: ${_hod!.name}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Timeline
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timeline',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          if (_timeline.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No timeline entries yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _timeline.length,
                              itemBuilder: (context, index) {
                                final entry = _timeline[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: _getStatusColor(entry.status ?? ''),
                                        child: Text(
                                          entry.status?[0].toUpperCase() ?? 'T',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (entry.status != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(entry.status!),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  entry.status!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            if (entry.comment != null) ...[
                                              const SizedBox(height: 4),
                                              Text(entry.comment!),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatDate(entry.createdAt),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 