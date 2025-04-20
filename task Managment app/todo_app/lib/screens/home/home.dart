import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_category_screen.dart';
import 'package:todo_app/widgets/go_premium.dart';
import 'package:todo_app/widgets/tasks.dart';
import 'package:todo_app/screens/task_list_screen.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String? initialNotificationPayload;

  const HomePage({super.key, this.initialNotificationPayload});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialNotificationPayload != null) {
      // Handle notification payload: format "categoryId:taskIndex"
      final parts = widget.initialNotificationPayload!.split(':');
      if (parts.length == 2) {
        final categoryId = parts[0];
        final taskIndex = int.tryParse(parts[1]);
        if (taskIndex != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider = Provider.of<TaskProvider>(context, listen: false);
            final category = provider.tasks.firstWhere(
                  (task) => task.id == categoryId,
              orElse: () => provider.tasks.first,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskListScreen(
                  category: category,
                  showRepeated: false,
                  showFuture: false,
                  showCompleted: false,
                ),
              ),
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          GoPremium(),
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Tasks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Tasks()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
          );
        },
        child: const Icon(Icons.add, size: 35),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/avatar.jpg'),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Hi, User!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: const [
        Icon(Icons.more_vert, color: Colors.black, size: 40),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey.withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(Icons.home_rounded, size: 30),
        ),
        BottomNavigationBarItem(
          label: 'Person',
          icon: Icon(Icons.person_rounded, size: 30),
        ),
      ],
    );
  }
}