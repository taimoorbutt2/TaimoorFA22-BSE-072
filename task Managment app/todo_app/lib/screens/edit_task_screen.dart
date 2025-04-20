import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final String categoryId;
  final int taskIndex;
  final Map<String, dynamic> initialTask;

  const EditTaskScreen({
    super.key,
    required this.categoryId,
    required this.taskIndex,
    required this.initialTask,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _isRepeated;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask['title']);
    _descriptionController = TextEditingController(text: widget.initialTask['description']);
    _isRepeated = widget.initialTask['isRepeated'] ?? false;
    _dueDate = DateTime.parse(widget.initialTask['dueDate']);
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isNotEmpty) {
      final updatedTask = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isRepeated': _isRepeated,
        'dueDate': _dueDate.toIso8601String(),
        'createdAt': widget.initialTask['createdAt'],
        'repeatType': widget.initialTask['repeatType'],
        if (widget.initialTask['repeatDays'] != null) 'repeatDays': widget.initialTask['repeatDays'],
        if (widget.initialTask['repeatDate'] != null) 'repeatDate': widget.initialTask['repeatDate'],
      };

      await Provider.of<TaskProvider>(context, listen: false)
          .updateTask(widget.categoryId, widget.taskIndex, updatedTask);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "${_titleController.text}" updated')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(_dueDate.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),
            SwitchListTile(
              title: const Text('Repeat Task'),
              value: _isRepeated,
              onChanged: (value) => setState(() => _isRepeated = value),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}