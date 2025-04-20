import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/task_list_screen.dart';

class CategoryTasksScreen extends StatelessWidget {
  final Task category;
  const CategoryTasksScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskListScreen(
                      category: category,
                      showRepeated: false,
                      showFuture: false, // Added this line
                    ),
                  ),
                );
              },
              child: const Text("Today's Tasks"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskListScreen(
                      category: category,
                      showRepeated: true,
                      showFuture: false, // Added this line
                    ),
                  ),
                );
              },
              child: const Text('Repeated Tasks'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskListScreen(
                      category: category,
                      showRepeated: false,
                      showFuture: true, // Added this line for Future Tasks
                    ),
                  ),
                );
              },
              child: const Text('Future Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}