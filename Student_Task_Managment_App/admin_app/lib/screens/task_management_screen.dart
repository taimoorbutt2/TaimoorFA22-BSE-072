
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/task_card.dart';

class TaskManagementScreen extends StatefulWidget {
const TaskManagementScreen({super.key});

@override
State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
final SupabaseService _supabaseService = SupabaseService();
final _titleController = TextEditingController();
final _descriptionController = TextEditingController();
final _dueDateController = TextEditingController();
final _formKey = GlobalKey<FormState>();
List<User> _students = [];
List<Task> _tasks = [];
List<String> _selectedStudentIds = [];
bool _isLoading = true;
DateTime? _selectedDate;

@override
void initState() {
super.initState();
_fetchData();
_supabaseService.subscribeToTasks((updatedTasks) {
setState(() {
_tasks = updatedTasks;
});
});
}

Future<void> _fetchData() async {
setState(() {
_isLoading = true;
});
try {
final students = await _supabaseService.getStudents();
final tasks = await _supabaseService.getTasks();
setState(() {
_students = students;
_tasks = tasks;
_isLoading = false;
});
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
setState(() {
_isLoading = false;
});
}
}

Future<void> _assignTask() async {
if (!_formKey.currentState!.validate() || _selectedStudentIds.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Please complete all fields and select at least one student')),
);
return;
}

try {
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await _supabaseService.assignTask(
title: _titleController.text.trim(),
description: _descriptionController.text.trim(),
assignedTo: _selectedStudentIds,
dueDate: _selectedDate!,
createdBy: authProvider.adminUser!.uid,
);
_titleController.clear();
_descriptionController.clear();
_dueDateController.clear();
_selectedStudentIds = [];
_selectedDate = null;
_fetchData();
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Task assigned successfully to selected students')),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
}
}

Future<void> _selectDate(BuildContext context) async {
final picked = await showDatePicker(
context: context,
initialDate: DateTime.now(),
firstDate: DateTime.now(),
lastDate: DateTime(2030),
);
if (picked != null) {
setState(() {
_selectedDate = picked;
_dueDateController.text = Helpers.formatDate(picked);
});
}
}

Future<void> _selectStudents() async {
final selected = await showDialog<List<String>>(
context: context,
builder: (context) => MultiSelectDialog(
students: _students,
selectedIds: _selectedStudentIds,
),
);
if (selected != null) {
setState(() {
_selectedStudentIds = selected;
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Manage Tasks')),
body: _isLoading
? const Center(child: CircularProgressIndicator(color: Color(0xFF3B00FF)))
    : SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Assign New Task',
style: Theme.of(context).textTheme.headlineSmall,
),
const SizedBox(height: 16),
Form(
key: _formKey,
child: Column(
children: [
TextFormField(
controller: _titleController,
decoration: const InputDecoration(
labelText: 'Task Title',
hintText: 'Enter task title',
),
style: const TextStyle(color: Colors.white),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter a title';
}
return null;
},
),
const SizedBox(height: 16),
TextFormField(
controller: _descriptionController,
decoration: const InputDecoration(
labelText: 'Description',
hintText: 'Enter task description',
),
style: const TextStyle(color: Colors.white),
maxLines: 3,
),
const SizedBox(height: 16),
TextFormField(
readOnly: true,
decoration: InputDecoration(
labelText: 'Select Students',
hintText: _selectedStudentIds.isEmpty
? 'Select students'
    : _selectedStudentIds
    .map((id) => _students.firstWhere((s) => s.id == id).name)
    .join(', '),
),
style: const TextStyle(color: Colors.white),
onTap: _selectStudents,
validator: (value) {
if (_selectedStudentIds.isEmpty) {
return 'Please select at least one student';
}
return null;
},
),
const SizedBox(height: 16),
TextFormField(
controller: _dueDateController,
decoration: const InputDecoration(
labelText: 'Due Date',
hintText: 'Select due date',
),
style: const TextStyle(color: Colors.white),
readOnly: true,
onTap: () => _selectDate(context),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please select a due date';
}
return null;
},
),
const SizedBox(height: 16),
ElevatedButton(
onPressed: _assignTask,
child: const Text('Assign Task'),
),
],
),
),
const SizedBox(height: 20),
Text(
'All Tasks',
style: Theme.of(context).textTheme.headlineSmall,
),
const SizedBox(height: 16),
_tasks.isEmpty
? const Center(child: Text('No tasks available'))
    : ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: _tasks.length,
itemBuilder: (context, index) {
final task = _tasks[index];
final student = _students.firstWhere(
(s) => s.id == task.assignedTo,
orElse: () => User(
id: '',
name: 'Unknown',
role: 'student',
createdAt: DateTime.now(),
),
);
return TaskCard(task: task, studentName: student.name);
},
),
],
),
),
),
);
}
}

class MultiSelectDialog extends StatefulWidget {
final List<User> students;
final List<String> selectedIds;

const MultiSelectDialog({
super.key,
required this.students,
required this.selectedIds,
});

@override
State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
late List<String> _tempSelectedIds;

@override
void initState() {
super.initState();
_tempSelectedIds = List.from(widget.selectedIds);
}

@override
Widget build(BuildContext context) {
return AlertDialog(
backgroundColor: AppColors.background,
title: const Text(
'Select Students',
style: TextStyle(color: Colors.white),
),
content: Container(
width: double.maxFinite,
child: ListView.builder(
shrinkWrap: true,
itemCount: widget.students.length,
itemBuilder: (context, index) {
final student = widget.students[index];
return Card(
color: AppColors.background,
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8),
side: const BorderSide(color: AppColors.border),
),
margin: const EdgeInsets.symmetric(vertical: 4),
child: CheckboxListTile(
title: Text(
student.name,
style: const TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
subtitle: Text(
'ID: ${student.id}',
style: const TextStyle(
color: Colors.white70,
fontSize: 12,
),
),
value: _tempSelectedIds.contains(student.id),
onChanged: (value) {
setState(() {
if (value == true) {
_tempSelectedIds.add(student.id);
} else {
_tempSelectedIds.remove(student.id);
}
});
},
checkColor: Colors.white,
activeColor: AppColors.primary,
),
);
},
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text(
'Cancel',
style: TextStyle(color: Colors.white70),
),
),
TextButton(
onPressed: () => Navigator.pop(context, _tempSelectedIds),
child: const Text(
'Confirm',
style: TextStyle(color: Colors.white),
),
),
],
);
}
}
