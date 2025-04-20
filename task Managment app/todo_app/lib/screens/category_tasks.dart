import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/task_list_screen.dart';

class CategoryTasksScreen extends StatelessWidget {
  final Task category;
  const CategoryTasksScreen({super.key, required this.category});

  LinearGradient _getCategoryGradient(Color btnColor) {
    final hsl = HSLColor.fromColor(btnColor);
    final darkerColor = hsl.withLightness((hsl.lightness - 0.3).clamp(0.2, 0.7)).toColor();
    return LinearGradient(
      colors: [
        Color.lerp(btnColor, Colors.white, 0.4) ?? btnColor.withOpacity(0.6),
        darkerColor,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryGradient = _getCategoryGradient(category.btnColor);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: categoryGradient,
          ),
        ),
        title: Text(category.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: categoryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradientButton(
                context,
                text: "Today's Tasks",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskListScreen(
                        category: category,
                        showRepeated: false,
                      ),
                    ),
                  );
                },
                gradient: categoryGradient,
              ),
              const SizedBox(height: 20),
              _buildGradientButton(
                context,
                text: "Completed Tasks",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskListScreen(
                        category: category,
                        showRepeated: false,
                        showCompleted: true,
                      ),
                    ),
                  );
                },
                gradient: categoryGradient,
              ),
              const SizedBox(height: 20),
              _buildGradientButton(
                context,
                text: "Repeated Tasks",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskListScreen(
                        category: category,
                        showRepeated: true,
                      ),
                    ),
                  );
                },
                gradient: categoryGradient,
              ),
              const SizedBox(height: 20),
              _buildGradientButton(
                context,
                text: "Future Tasks",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskListScreen(
                        category: category,
                        showRepeated: false,
                        showFuture: true,
                      ),
                    ),
                  );
                },
                gradient: categoryGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(BuildContext context,
      {required String text, required VoidCallback onPressed, required LinearGradient gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}