import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task category;
  const AddTaskScreen({super.key, required this.category});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isRepeated = false;
  DateTime _dueDate = DateTime.now();
  String? _repeatType;
  List<String> _repeatDays = [];
  int? _repeatDate;
  bool _showRepeatOptions = false;

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
          debugPrint('AddTaskScreen: Selected due date: $_dueDate');
        });
      }
    }
  }

  Future<void> _selectRepeatDays() async {
    final selectedDays = List<String>.from(_repeatDays);
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _RepeatDaysDialog(initialDays: selectedDays),
    );
    if (result != null) {
      setState(() {
        _repeatDays = result;
        debugPrint('AddTaskScreen: Selected repeat days: $_repeatDays');
      });
    }
  }

  Future<void> _selectRepeatDate() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _RepeatDateDialog(initialDate: _repeatDate),
    );
    if (result != null) {
      setState(() {
        _repeatDate = result;
        debugPrint('AddTaskScreen: Selected repeat date: $_repeatDate');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryGradient = _getCategoryGradient(widget.category.btnColor);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: categoryGradient,
          ),
        ),
        title: Text('Add Task to ${widget.category.title}'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: categoryGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: categoryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: const Text('Due Date', style: TextStyle(color: Colors.white)),
                    subtitle: Text(_dueDate.toString(), style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.calendar_today, color: Colors.white),
                    onTap: _selectDueDate,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: categoryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    title: const Text('Repeat Task', style: TextStyle(color: Colors.white)),
                    value: _isRepeated,
                    onChanged: (value) {
                      setState(() {
                        _isRepeated = value;
                        _showRepeatOptions = value;
                        if (!value) {
                          _repeatType = null;
                          _repeatDays = [];
                          _repeatDate = null;
                        }
                        debugPrint('AddTaskScreen: Repeat task set to: $_isRepeated');
                      });
                    },
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.grey,
                  ),
                ),
                if (_showRepeatOptions) ...[
                  const SizedBox(height: 8),
                  const Text('Repeat Frequency:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildRepeatOption('Daily', 'daily'),
                        _buildRepeatOption('Weekly', 'weekly'),
                        _buildRepeatOption('Monthly', 'monthly'),
                      ],
                    ),
                  ),
                  if (_repeatType == 'weekly')
                    Container(
                      decoration: BoxDecoration(
                        gradient: categoryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: const Text('Repeat Days', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _repeatDays.isEmpty ? 'Select days' : _repeatDays.join(', '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        onTap: _selectRepeatDays,
                      ),
                    ),
                  if (_repeatType == 'monthly')
                    Container(
                      decoration: BoxDecoration(
                        gradient: categoryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: const Text('Repeat Date', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _repeatDate == null ? 'Select date' : 'Day $_repeatDate',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        onTap: _selectRepeatDate,
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: categoryGradient,
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
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Task'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatOption(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: _repeatType == value ? Colors.white : Colors.black)),
        selected: _repeatType == value,
        selectedColor: widget.category.btnColor,
        backgroundColor: Colors.grey.shade200,
        onSelected: (selected) {
          setState(() {
            _repeatType = selected ? value : null;
            _repeatDays = [];
            _repeatDate = null;
            debugPrint('AddTaskScreen: Selected repeat type: $_repeatType');
          });
        },
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isNotEmpty) {
      final taskDetail = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isRepeated': _isRepeated,
        'dueDate': _dueDate.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'repeatType': _repeatType,
        if (_repeatType == 'weekly' && _repeatDays.isNotEmpty) 'repeatDays': _repeatDays,
        if (_repeatType == 'monthly' && _repeatDate != null) 'repeatDate': _repeatDate,
      };

      debugPrint('AddTaskScreen: Saving task with details: $taskDetail');

      await Provider.of<TaskProvider>(context, listen: false)
          .addTaskToCategory(widget.category.id, taskDetail);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "${_titleController.text}" added')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _RepeatDaysDialog extends StatefulWidget {
  final List<String> initialDays;

  const _RepeatDaysDialog({required this.initialDays});

  @override
  _RepeatDaysDialogState createState() => _RepeatDaysDialogState();
}

class _RepeatDaysDialogState extends State<_RepeatDaysDialog> {
  late List<String> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List.from(widget.initialDays);
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      title: const Text('Select Repeat Days', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: days.map((day) {
            return CheckboxListTile(
              title: Text(day),
              value: selectedDays.contains(day),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedDays),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _RepeatDateDialog extends StatefulWidget {
  final int? initialDate;

  const _RepeatDateDialog({this.initialDate});

  @override
  _RepeatDateDialogState createState() => _RepeatDateDialogState();
}

class _RepeatDateDialogState extends State<_RepeatDateDialog> {
  late int selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      title: const Text('Select Repeat Date', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        height: 150,
        child: NumberPicker(
          minValue: 1,
          maxValue: 31,
          value: selectedDate,
          onChanged: (value) => setState(() => selectedDate = value),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedDate),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class NumberPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;

  const NumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: value < maxValue
              ? () => onChanged(value + 1)
              : null,
        ),
        Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: value > minValue
              ? () => onChanged(value - 1)
              : null,
        ),
      ],
    );
  }
}