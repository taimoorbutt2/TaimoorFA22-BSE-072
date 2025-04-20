import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _titleController = TextEditingController();
  Color _bgColor = Colors.blue;
  Color _iconColor = Colors.white;
  Color _btnColor = Colors.blueAccent;
  IconData _iconData = Icons.category;

  Future<void> _saveCategory() async {
    if (_titleController.text.isNotEmpty) {
      final newCategory = Task(
        id: const Uuid().v4(),
        iconData: _iconData,
        title: _titleController.text,
        bgColor: _bgColor,
        iconColor: _iconColor,
        btnColor: _btnColor,
        dueDate: null,
        desc: [],
      );

      await Provider.of<TaskProvider>(context, listen: false).addCategory(newCategory);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "${_titleController.text}" added')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category title')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Category Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveCategory,
              child: const Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}