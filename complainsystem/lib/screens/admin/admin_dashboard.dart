import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_gradient/animate_gradient.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart' as app_user;
import '../../models/batch.dart';
import '../../models/complaint.dart';
import '../../utils/constants.dart';
import 'add_user_screen.dart';
import 'csv_import_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<app_user.User> _users = [];
  List<Batch> _batches = [];
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  final List<String> _menuTitles = [
    'Overview',
    'Users',
    'Batches',
    'Complaints',
  ];
  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.people,
    Icons.school,
    Icons.report,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await SupabaseService.getAllProfiles();
      final batches = await SupabaseService.getAllBatches();
      final complaints = await SupabaseService.getComplaints();
      setState(() {
        _users = users;
        _batches = batches;
        _complaints = complaints;
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

  void _signOut(BuildContext context) async {
    await SupabaseService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      drawer: _buildDrawer(),
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
            // Decorative shapes
            Positioned(top: 100, right: 50, child: _buildShape(Colors.blue.withOpacity(0.1), 150)),
            Positioned(top: 300, left: 30, child: _buildShape(Colors.purple.withOpacity(0.1), 100)),
            Positioned(bottom: 200, right: 100, child: _buildShape(Colors.green.withOpacity(0.1), 120)),
            // Main content
            _isLoading
                ? Center(
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
                      ),
                    ),
                  )
                : _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            if (constraints.maxWidth >= 900) _buildNavigationRail(),
            if (constraints.maxWidth >= 900)
              Container(
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
            Expanded(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(constraints.maxWidth),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationRail() {
    return GlassmorphicContainer(
      width: 250,
      height: double.infinity,
      borderRadius: 0,
      blur: 15,
      alignment: Alignment.center,
      border: 0,
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
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.5),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          GlassmorphicContainer(
            width: 200,
            height: 80,
            borderRadius: 20,
            blur: 15,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.withOpacity(0.2),
                Colors.deepPurple.withOpacity(0.1),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.5),
                Colors.deepPurple.withOpacity(0.5),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 32, color: Colors.deepPurple),
                SizedBox(height: 4),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ...List.generate(_menuTitles.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 60,
                borderRadius: 15,
                blur: 15,
                alignment: Alignment.center,
                border: _selectedIndex == index ? 2 : 0,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _selectedIndex == index
                      ? [
                          Colors.deepPurple.withOpacity(0.2),
                          Colors.deepPurple.withOpacity(0.1),
                        ]
                      : [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.5),
                    Colors.deepPurple.withOpacity(0.5),
                  ],
                ),
                child: ListTile(
                  leading: Icon(
                    _menuIcons[index],
                    color: _selectedIndex == index ? Colors.deepPurple : Colors.grey.shade700,
                  ),
                  title: Text(
                    _menuTitles[index],
                    style: TextStyle(
                      fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      color: _selectedIndex == index ? Colors.deepPurple : Colors.grey.shade700,
                    ),
                  ),
                  onTap: () => _onMenuTap(index),
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 50,
              borderRadius: 15,
              blur: 15,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.withOpacity(0.1),
                  Colors.red.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.3),
                  Colors.red.withOpacity(0.3),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () => _signOut(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContent(double maxWidth) {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview(maxWidth);
      case 1:
        return _buildUsers();
      case 2:
        return _buildBatches();
      case 3:
        return _buildComplaints();
      default:
        return const Center(child: Text('Select a section'));
    }
  }

  Widget _buildOverview(double maxWidth) {
    final adminCount = _users.where((u) => u.role == 'admin').length;
    final hodCount = _users.where((u) => u.role == 'hod').length;
    final advisorCount = _users.where((u) => u.role == 'batch_advisor').length;
    final studentCount = _users.where((u) => u.role == 'student').length;
    final pendingComplaints = _complaints.where((c) => c.status == 'Submitted').length;
    final inProgressComplaints = _complaints.where((c) => c.status == 'In Progress').length;
    final resolvedComplaints = _complaints.where((c) => c.status == 'Resolved').length;

    // Fixed 2-column layout with shorter cards
    const int crossAxisCount = 2;
    const double childAspectRatio = 1.2; // Shorter, wider cards

    final stats = [
      {'title': 'Total Users', 'value': _users.length.toString(), 'icon': Icons.people, 'color': Colors.blue, 'gradient': [Colors.blue.shade400, Colors.blue.shade600]},
      {'title': 'Total Batches', 'value': _batches.length.toString(), 'icon': Icons.school, 'color': Colors.purple, 'gradient': [Colors.purple.shade400, Colors.purple.shade600]},
      {'title': 'Total Complaints', 'value': _complaints.length.toString(), 'icon': Icons.report, 'color': Colors.red, 'gradient': [Colors.red.shade400, Colors.red.shade600]},
      {'title': 'Admins', 'value': adminCount.toString(), 'icon': Icons.admin_panel_settings, 'color': Colors.teal, 'gradient': [Colors.teal.shade400, Colors.teal.shade600]},
      {'title': 'HODs', 'value': hodCount.toString(), 'icon': Icons.person, 'color': Colors.indigo, 'gradient': [Colors.indigo.shade400, Colors.indigo.shade600]},
      {'title': 'Advisors', 'value': advisorCount.toString(), 'icon': Icons.school, 'color': Colors.orange, 'gradient': [Colors.orange.shade400, Colors.orange.shade600]},
      {'title': 'Students', 'value': studentCount.toString(), 'icon': Icons.person_outline, 'color': Colors.green, 'gradient': [Colors.green.shade400, Colors.green.shade600]},
      {'title': 'Pending', 'value': pendingComplaints.toString(), 'icon': Icons.pending, 'color': Colors.orange, 'gradient': [Colors.orange.shade400, Colors.orange.shade600]},
      {'title': 'In Progress', 'value': inProgressComplaints.toString(), 'icon': Icons.trending_up, 'color': Colors.blue, 'gradient': [Colors.blue.shade400, Colors.blue.shade600]},
      {'title': 'Resolved', 'value': resolvedComplaints.toString(), 'icon': Icons.check_circle, 'color': Colors.green, 'gradient': [Colors.green.shade400, Colors.green.shade600]},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassmorphicContainer(
          width: double.infinity,
          height: 70, // Reduced height
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Reduced padding
            child: Row(
              children: [
                const Icon(Icons.dashboard, size: 28, color: Colors.deepPurple), // Smaller icon
                const SizedBox(width: 12), // Reduced spacing
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 20, // Smaller font
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, color: Colors.deepPurple, size: 20), // Smaller icon
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero, // Remove padding
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32), // Smaller constraints
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12), // Reduced spacing
        Expanded(
          child: GridView.count(
            physics: const AlwaysScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8, // Reduced spacing
            crossAxisSpacing: 8, // Reduced spacing
            childAspectRatio: childAspectRatio,
            padding: const EdgeInsets.only(bottom: 8), // Reduced padding
            children: stats.map((stat) => _buildStatCard(
              stat['title'] as String,
              stat['value'] as String,
              stat['icon'] as IconData,
              gradient: stat['gradient'] as List<Color>,
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {required List<Color> gradient}) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
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
                  gradient: LinearGradient(
                    colors: gradient,
                  ),
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

  Widget _buildUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Use Column layout for smaller screens, Row for larger screens
            if (constraints.maxWidth < 600) {
              return GlassmorphicContainer(
                width: double.infinity,
                height: 100, // Increased height for mobile layout
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
                child: Padding(
                  padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20, color: Colors.deepPurple), // Smaller icon
                          const SizedBox(width: 8), // Reduced spacing
                          const Expanded(
                            child: Text(
                              'User Management',
                              style: TextStyle(
                                fontSize: 16, // Smaller font
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // Reduced from 6 to 4
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddUserScreen()),
                              ).then((_) => _loadData()),
                              icon: const Icon(Icons.add, size: 14), // Smaller icon
                              label: const Text('Add User', style: TextStyle(fontSize: 11)), // Smaller text
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Smaller radius
                                padding: const EdgeInsets.symmetric(vertical: 4), // Reduced from 6 to 4
                              ),
                            ),
                          ),
                          const SizedBox(width: 6), // Reduced spacing
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CsvImportScreen()),
                              ).then((_) => _loadData()),
                              icon: const Icon(Icons.upload_file, size: 14), // Smaller icon
                              label: const Text('Import CSV', style: TextStyle(fontSize: 11)), // Smaller text
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Smaller radius
                                padding: const EdgeInsets.symmetric(vertical: 4), // Reduced from 6 to 4
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return GlassmorphicContainer(
                width: double.infinity,
                height: 80, // Original height for desktop
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.people, size: 32, color: Colors.deepPurple),
                      const SizedBox(width: 16),
                      const Text(
                        'User Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddUserScreen()),
                        ).then((_) => _loadData()),
                        icon: const Icon(Icons.add),
                        label: const Text('Add User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CsvImportScreen()),
                        ).then((_) => _loadData()),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Import CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 24),
        Expanded(
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
                Colors.deepPurple.withOpacity(0.3),
                Colors.deepPurple.withOpacity(0.3),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                final user = _users[index];
                return _buildUserTile(user);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(app_user.User user) {
    Color roleColor;
    IconData roleIcon;
    
    switch (user.role) {
      case 'admin':
        roleColor = Colors.red;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'hod':
        roleColor = Colors.blue;
        roleIcon = Icons.person;
        break;
      case 'batch_advisor':
        roleColor = Colors.orange;
        roleIcon = Icons.school;
        break;
      case 'student':
        roleColor = Colors.green;
        roleIcon = Icons.person_outline;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.3),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(roleIcon, color: roleColor, size: 20),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          '${user.role.replaceAll('_', ' ').toUpperCase()} • ${user.email}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: user.studentId != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.studentId!,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBatches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Use Column layout for smaller screens, Row for larger screens
            if (constraints.maxWidth < 500) {
              return GlassmorphicContainer(
                width: double.infinity,
                height: 90, // Increased height for mobile layout
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
                child: Padding(
                  padding: const EdgeInsets.all(12), // Reduced padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, size: 20, color: Colors.deepPurple), // Smaller icon
                          const SizedBox(width: 8), // Reduced spacing
                          const Expanded(
                            child: Text(
                              'Batch Management',
                              style: TextStyle(
                                fontSize: 16, // Smaller font
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6), // Reduced spacing
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createBatches,
                          icon: const Icon(Icons.add, size: 14), // Smaller icon
                          label: const Text('Create Batches', style: TextStyle(fontSize: 11)), // Smaller text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // Smaller radius
                            padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return GlassmorphicContainer(
                width: double.infinity,
                height: 80, // Original height for desktop
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.school, size: 32, color: Colors.deepPurple),
                      const SizedBox(width: 16),
                      const Text(
                        'Batch Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _createBatches,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Batches'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 24),
        Expanded(
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
                Colors.deepPurple.withOpacity(0.3),
                Colors.deepPurple.withOpacity(0.3),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _batches.length,
              itemBuilder: (context, index) {
                final batch = _batches[index];
                final advisor = _users.firstWhere(
                  (u) => u.id == batch.advisorId,
                  orElse: () => app_user.User(
                    id: '',
                    email: '',
                    role: '',
                    name: 'No Advisor Assigned',
                    createdAt: DateTime.now(),
                  ),
                );
                return _buildBatchTile(batch, advisor);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchTile(Batch batch, app_user.User advisor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.3),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.2),
          child: Text(
            batch.batchName,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          batch.batchName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          'Advisor: ${advisor.name}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: batch.advisorId != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Assigned',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Unassigned',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildComplaints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassmorphicContainer(
          width: double.infinity,
          height: 80,
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.report, size: 32, color: Colors.deepPurple),
                const SizedBox(width: 16),
                const Text(
                  'All Complaints',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
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
                Colors.deepPurple.withOpacity(0.3),
                Colors.deepPurple.withOpacity(0.3),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                final student = _users.firstWhere(
                  (u) => u.id == complaint.studentId,
                  orElse: () => app_user.User(
                    id: '',
                    email: '',
                    role: '',
                    name: 'Unknown Student',
                    createdAt: DateTime.now(),
                  ),
                );
                return _buildComplaintTile(complaint, student);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintTile(Complaint complaint, app_user.User student) {
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
        subtitle: Text(
          '${student.name} • ${complaint.status}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(complaint.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatDate(complaint.createdAt),
            style: TextStyle(
              color: _getStatusColor(complaint.status),
              fontWeight: FontWeight.w500,
              fontSize: 12,
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

  Future<void> _createBatches() async {
    try {
      for (final batchName in AppConstants.batchNames) {
        final exists = _batches.any((b) => b.batchName.toLowerCase() == batchName.toLowerCase());
        if (!exists) {
          await SupabaseService.createBatch(batchName);
        }
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Batches created successfully'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating batches: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.2),
                          Colors.deepPurple.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.admin_panel_settings, size: 48, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin Menu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            ...List.generate(_menuTitles.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedIndex == index 
                      ? Colors.deepPurple.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: ListTile(
                  leading: Icon(
                    _menuIcons[index],
                    color: _selectedIndex == index ? Colors.deepPurple : Colors.grey.shade700,
                  ),
                  title: Text(
                    _menuTitles[index],
                    style: TextStyle(
                      fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      color: _selectedIndex == index ? Colors.deepPurple : Colors.grey.shade700,
                    ),
                  ),
                  selected: _selectedIndex == index,
                  onTap: () => _onMenuTap(index),
                ),
              );
            }),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.withOpacity(0.1),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () => _signOut(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Smart Complaint System',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}