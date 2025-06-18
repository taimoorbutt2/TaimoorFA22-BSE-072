import 'package:flutter/material.dart';
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
          SnackBar(content: Text('Error loading data: $e')),
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
    Navigator.pop(context); // Close drawer if open
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 8),
                  const Text('Admin Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ...List.generate(_menuTitles.length, (index) {
              return ListTile(
                leading: Icon(_menuIcons[index], color: _selectedIndex == index ? Theme.of(context).primaryColor : null),
                title: Text(_menuTitles[index], style: TextStyle(fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
                selected: _selectedIndex == index,
                onTap: () => _onMenuTap(index),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Smart Complaint System', style: TextStyle(color: Colors.grey.shade600)),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (constraints.maxWidth >= 900)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(_menuTitles.length, (index) =>
                      NavigationRailDestination(
                        icon: Icon(_menuIcons[index]),
                        label: Text(_menuTitles[index]),
                      ),
                  ),
                ),
              if (constraints.maxWidth >= 900)
                const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildContent(constraints.maxWidth),
                ),
              ),
            ],
          );
        },
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

    const int crossAxisCount = 2; // Fixed to two containers per row
    // Adjusted childAspectRatio to make cards taller, especially on smaller screens
    double childAspectRatio = maxWidth > 800 ? 0.8 : 0.6;

    final stats = [
      {'title': 'Total Users', 'value': _users.length.toString(), 'icon': Icons.people, 'color': Colors.blue},
      {'title': 'Total Batches', 'value': _batches.length.toString(), 'icon': Icons.school, 'color': Colors.purple},
      {'title': 'Total Complaints', 'value': _complaints.length.toString(), 'icon': Icons.report, 'color': Colors.red},
      {'title': 'Admins', 'value': adminCount.toString(), 'icon': Icons.admin_panel_settings, 'color': Colors.teal},
      {'title': 'HODs', 'value': hodCount.toString(), 'icon': Icons.person, 'color': Colors.indigo},
      {'title': 'Advisors', 'value': advisorCount.toString(), 'icon': Icons.school, 'color': Colors.orange},
      {'title': 'Students', 'value': studentCount.toString(), 'icon': Icons.person_outline, 'color': Colors.green},
      {'title': 'Pending', 'value': pendingComplaints.toString(), 'icon': Icons.pending, 'color': Colors.orange},
      {'title': 'In Progress', 'value': inProgressComplaints.toString(), 'icon': Icons.trending_up, 'color': Colors.blue},
      {'title': 'Resolved', 'value': resolvedComplaints.toString(), 'icon': Icons.check_circle, 'color': Colors.green},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                children: stats.map((stat) => _buildStatCard(
                  stat['title'] as String,
                  stat['value'] as String,
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRect( // Clip content to prevent overflow
        child: Container(
          padding: const EdgeInsets.all(16), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color ?? Theme.of(context).primaryColor), // Reduced icon size
              const SizedBox(height: 8),
              FittedBox( // Scale text to fit available space
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith( // Smaller text style
                    color: color ?? Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox( // Scale text to fit available space
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium, // Smaller text style
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsers() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddUserScreen()),
                        ).then((_) => _loadData()),
                        icon: const Icon(Icons.add),
                        label: const Text('Add User'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CsvImportScreen()),
                        ).then((_) => _loadData()),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Import CSV'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                itemCount: _users.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text('${user.role} • ${user.email}'),
                    trailing: Text(user.studentId ?? ''),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatches() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Batch Management',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _createBatches,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Batches'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.builder(
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
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(batch.batchName),
                    ),
                    title: Text(batch.batchName),
                    subtitle: Text('Advisor: ${advisor.name}'),
                    trailing: batch.advisorId != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.warning, color: Colors.orange),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaints() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'All Complaints',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(complaint.status),
                  child: Text(complaint.title[0].toUpperCase()),
                ),
                title: Text(complaint.title),
                subtitle: Text('${student.name} • ${complaint.status}'),
                trailing: Text(
                  _formatDate(complaint.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
      ],
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
        // Check if batch already exists (case-insensitive)
        final exists = _batches.any((b) => b.batchName.toLowerCase() == batchName.toLowerCase());
        if (!exists) {
          await SupabaseService.createBatch(batchName);
        }
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batches created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating batches: $e')),
        );
      }
    }
  }
}