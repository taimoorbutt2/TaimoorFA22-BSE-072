import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../../models/batch.dart';
import '../../utils/constants.dart';
import '../../services/complaint_timeline_service.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mediaUrlController = TextEditingController();
  
  String _selectedTitle = '';
  bool _isCustomTitle = false;
  User? _currentUser;
  Batch? _userBatch;
  User? _batchAdvisor;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = SupabaseService.getCurrentUser();
      if (user != null) {
        final profile = await SupabaseService.getProfile(user.id);
        if (profile != null) {
          setState(() {
            _currentUser = profile;
          });
          if (profile.batchId != null) {
            await _loadBatchData(profile.batchId!);
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading user data: $e';
      });
    }
  }

  Future<void> _loadBatchData(String batchId) async {
    try {
      final batch = await SupabaseService.getBatch(batchId);
      if (batch != null) {
        setState(() {
          _userBatch = batch;
        });
        if (batch.advisorId != null) {
          final advisor = await SupabaseService.getProfile(batch.advisorId!);
          setState(() {
            _batchAdvisor = advisor;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading batch data: $e';
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null || _userBatch == null) {
      setState(() {
        _error = 'User or batch information not available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final title = _isCustomTitle ? _titleController.text.trim() : _selectedTitle;
      
      // Get the count of existing complaints with the same title
      final sameTitleCount = await SupabaseService.getSameTitleComplaintCount(title);

      final complaintData = {
        'student_id': _currentUser!.id,
        'batch_id': _userBatch!.id,
        'advisor_id': _batchAdvisor?.id,
        'title': title,
        'description': _descriptionController.text.trim(),
        'media_url': _mediaUrlController.text.trim().isEmpty ? null : _mediaUrlController.text.trim(),
        'status': 'Submitted',
        'same_title_count': sameTitleCount + 1,
      };

      // Create the complaint and get its ID
      final complaintId = await SupabaseService.createComplaint(complaintData);

      // Try to add timeline entry, but ignore any errors
      try {
        if (complaintId != null && complaintId.isNotEmpty) {
          await ComplaintTimelineService.addTimelineEntry(
            complaintId: complaintId,
            comment: 'Complaint submitted by student',
            status: 'Submitted',
            createdBy: _currentUser!.id,
          );
        }
      } catch (e) {
        // Do nothing: hide timeline errors from user
        print('Timeline entry error ignored: $e');
      }

      // Always show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your complaint has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Only show error if complaint creation itself fails
      setState(() {
        _error = 'Error submitting complaint: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testMediaUrl() async {
    final url = _mediaUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a media URL first')),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL format')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit New Complaint',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              
              // User Info Card
              if (_currentUser != null && _userBatch != null)
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
                        Text('Student: ${_currentUser!.name}'),
                        Text('Batch: ${_userBatch!.batchName}'),
                        if (_batchAdvisor != null)
                          Text('Batch Advisor: ${_batchAdvisor!.name}'),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Title Selection
              if (!_isCustomTitle) ...[
                DropdownButtonFormField<String>(
                  value: _selectedTitle.isEmpty ? null : _selectedTitle,
                  decoration: const InputDecoration(
                    labelText: 'Complaint Title',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    ...AppConstants.complaintTitles.map((title) {
                      return DropdownMenuItem(value: title, child: Text(title));
                    }),
                    const DropdownMenuItem(value: 'custom', child: Text('Custom Title')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 'custom') {
                        _isCustomTitle = true;
                        _selectedTitle = '';
                      } else {
                        _selectedTitle = value ?? '';
                      }
                    });
                  },
                  validator: (value) => value == null ? 'Select a title' : null,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isCustomTitle = false;
                          _titleController.clear();
                        });
                      },
                      child: const Text('Use Preset'),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Describe your complaint in detail...',
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Enter a description' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Media URL
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mediaUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Media URL (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Google Drive link to image/video',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _testMediaUrl,
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Test URL',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitComplaint,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 