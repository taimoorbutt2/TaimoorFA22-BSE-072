import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../models/complaint_timeline.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';

class ComplaintActionScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintActionScreen({super.key, required this.complaint});

  @override
  State<ComplaintActionScreen> createState() => _ComplaintActionScreenState();
}

class _ComplaintActionScreenState extends State<ComplaintActionScreen> {
  List<ComplaintTimeline> _timeline = [];
  User? _student;
  User? _hod;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

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
      
      User? hod;
      if (widget.complaint.hodId != null) {
        hod = await SupabaseService.getProfile(widget.complaint.hodId!);
      }

      setState(() {
        _timeline = timeline;
        _student = student;
        _hod = hod;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _updateStatus(String newStatus, String comment) async {
    if (widget.complaint.status == 'Escalated' || 
        widget.complaint.status == 'Resolved' || 
        widget.complaint.status == 'Rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update resolved/escalated complaints')),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
      _error = null;
    });

    try {
      if (newStatus == 'Escalated') {
        // Directly assign the provided HOD ID
        await SupabaseService.updateComplaint(widget.complaint.id, {
          'status': 'Escalated',
          'hod_id': '497267c2-eae7-4097-9e91-39d09f6013ea',
          'last_action_at': DateTime.now().toIso8601String(),
        });
        await SupabaseService.addTimelineEntry({
          'complaint_id': widget.complaint.id,
          'comment': comment,
          'status': 'Escalated',
          'created_by': SupabaseService.getCurrentUser()!.id,
        });
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to Escalated')),
        );
        setState(() => _isUpdating = false);
        return;
      } else {
        // Normal status update
        await SupabaseService.updateComplaint(widget.complaint.id, {
          'status': newStatus,
          'last_action_at': DateTime.now().toIso8601String(),
        });
        await SupabaseService.addTimelineEntry({
          'complaint_id': widget.complaint.id,
          'comment': comment,
          'status': newStatus,
          'created_by': SupabaseService.getCurrentUser()!.id,
        });
      }

      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      setState(() {
        _error = 'Error updating status: $e';
      });
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showActionDialog(String action, String title) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(action, commentController.text.trim());
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Actions'),
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
                  // Complaint Details
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
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Student Information
                  if (_student != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Name: ${_student!.name}'),
                            Text('Email: ${_student!.email}'),
                            if (_student!.phoneNo != null)
                              Text('Phone: ${_student!.phoneNo}'),
                            if (_student!.studentId != null)
                              Text('Student ID: ${_student!.studentId}'),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  if (widget.complaint.status != 'Escalated' && 
                      widget.complaint.status != 'Resolved' && 
                      widget.complaint.status != 'Rejected')
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : () => _showActionDialog('In Progress', 'Mark In Progress'),
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('In Progress'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : () => _showActionDialog('Escalated', 'Escalate to HOD'),
                                    icon: const Icon(Icons.escalator_warning),
                                    label: const Text('Escalate'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : () => _showActionDialog('Resolved', 'Mark Resolved'),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('Resolve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : () => _showActionDialog('Rejected', 'Reject Complaint'),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                    ),
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