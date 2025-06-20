import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../models/complaint_timeline.dart';
import '../../models/user.dart' as app_user;
import '../../services/supabase_service.dart';
import '../../services/email_service.dart';
import '../../utils/constants.dart';

class HodComplaintActionScreen extends StatefulWidget {
  final Complaint complaint;

  const HodComplaintActionScreen({super.key, required this.complaint});

  @override
  State<HodComplaintActionScreen> createState() => _HodComplaintActionScreenState();
}

class _HodComplaintActionScreenState extends State<HodComplaintActionScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<ComplaintTimeline> _timeline = [];
  app_user.User? _student;
  app_user.User? _advisor;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final timeline = await SupabaseService.getComplaintTimeline(widget.complaint.id);
      final student = await SupabaseService.getProfile(widget.complaint.studentId);
      
      app_user.User? advisor;
      if (widget.complaint.advisorId != null) {
        advisor = await SupabaseService.getProfile(widget.complaint.advisorId!);
      }

      setState(() {
        _timeline = timeline;
        _student = student;
        _advisor = advisor;
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

  Future<void> _updateStatus(String status) async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Update complaint status
      await SupabaseService.updateComplaint(widget.complaint.id, {
        'status': status,
        'hod_id': SupabaseService.getCurrentUser()?.id,
      });

      // Add timeline entry
      await SupabaseService.addTimelineEntry({
        'complaint_id': widget.complaint.id,
        'status': status,
        'comment': _commentController.text.trim(),
        'created_by': SupabaseService.getCurrentUser()?.id,
      });

      // Send email notification
      if (_student != null) {
        await EmailService.sendComplaintStatusUpdate(
          name: _student!.name,
          email: _student!.email,
          complaintTitle: widget.complaint.title,
          status: status,
          comment: _commentController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint $status successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating complaint: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOD Action'),
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
                          if (widget.complaint.sameTitleCount > 1 &&
                              widget.complaint.status != 'Resolved' &&
                              widget.complaint.status != 'Rejected') ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This complaint has ${widget.complaint.sameTitleCount - 1} other similar titles. Please review carefully.',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                            'Complaint Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_student != null) ...[
                            Text('Student: ${_student!.name}'),
                            Text('Email: ${_student!.email}'),
                            if (_student!.studentId != null)
                              Text('Student ID: ${_student!.studentId}'),
                          ],
                          if (_advisor != null) ...[
                            const SizedBox(height: 8),
                            Text('Batch Advisor: ${_advisor!.name}'),
                          ],
                          const SizedBox(height: 8),
                          Text('Submitted: ${_formatDate(widget.complaint.createdAt)}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOD Action',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _commentController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Comment (Required)',
                              hintText: 'Provide detailed feedback or resolution...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : () => _updateStatus('Resolved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Text('Resolve'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : () => _updateStatus('Rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
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