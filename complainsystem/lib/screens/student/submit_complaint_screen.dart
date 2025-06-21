import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism/glassmorphism.dart';
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

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen>
    with TickerProviderStateMixin {
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
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
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
      
      final complaintData = {
        'student_id': _currentUser!.id,
        'batch_id': _userBatch!.id,
        'advisor_id': _batchAdvisor?.id,
        'title': title,
        'description': _descriptionController.text.trim(),
        'media_url': _mediaUrlController.text.trim().isEmpty ? null : _mediaUrlController.text.trim(),
        'status': 'Submitted',
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Success!'),
              ],
            ),
            content: const Text('Your complaint has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold),
                ),
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
        SnackBar(
          content: const Text('Please enter a media URL first'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid URL'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid URL format'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
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
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with back button
                          Row(
                            children: [
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
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.arrow_back, color: Colors.deepPurple.shade600),
                                    tooltip: 'Back',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Submit Complaint',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // User Info Card
                          if (_currentUser != null && _userBatch != null)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 20),
                              child: GlassmorphicContainer(
                                width: double.infinity,
                                height: 150,
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
                                    Colors.blue.shade400.withOpacity(0.5),
                                    Colors.blue.shade600.withOpacity(0.5),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade50.withOpacity(0.3),
                                        Colors.indigo.shade50.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade400,
                                                    Colors.blue.shade600,
                                                  ],
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Complaint Details',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Student: ${_currentUser!.name}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Batch: ${_userBatch!.batchName}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (_batchAdvisor != null)
                                          Text(
                                            'Advisor: ${_batchAdvisor!.name}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Title Selection
                          if (!_isCustomTitle) ...[
                            _buildFormField(
                              'Complaint Title',
                              Icons.title,
                              Colors.orange,
                              child: DropdownButtonFormField<String>(
                                value: _selectedTitle.isEmpty ? null : _selectedTitle,
                                decoration: InputDecoration(
                                  labelText: 'Select Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
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
                            ),
                          ] else ...[
                            _buildFormField(
                              'Custom Title',
                              Icons.edit,
                              Colors.purple,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        labelText: 'Enter Custom Title',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.8),
                                      ),
                                      validator: (value) => value == null || value.isEmpty ? 'Enter a title' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.shade400,
                                          Colors.purple.shade600,
                                        ],
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isCustomTitle = false;
                                          _titleController.clear();
                                        });
                                      },
                                      child: const Text(
                                        'Use Preset',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 20),
                          
                          // Description
                          _buildFormField(
                            'Description',
                            Icons.description,
                            Colors.green,
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Describe your complaint',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                hintText: 'Describe your complaint in detail...',
                              ),
                              maxLines: 4,
                              validator: (value) => value == null || value.isEmpty ? 'Enter a description' : null,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Media URL
                          _buildFormField(
                            'Media URL (Optional)',
                            Icons.link,
                            Colors.blue,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _mediaUrlController,
                                    decoration: InputDecoration(
                                      labelText: 'Google Drive link to image/video',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: _testMediaUrl,
                                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                                    tooltip: 'Test URL',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          if (_error != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade50,
                                    Colors.red.shade100,
                                  ],
                                ),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Submit Button
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade400,
                                    Colors.deepPurple.shade600,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _isLoading ? null : _submitComplaint,
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.send, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Submit Complaint',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, IconData icon, Color color, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
} 