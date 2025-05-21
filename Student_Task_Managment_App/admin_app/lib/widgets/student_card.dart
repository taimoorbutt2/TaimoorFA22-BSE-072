import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StudentCard extends StatelessWidget {
  final User student;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const StudentCard({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController(text: student.name);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${student.id}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3B00FF)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Edit Student'),
                        content: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              onEdit(_nameController.text.trim());
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF2E63)),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Color(0xFF3B00FF)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: student.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student ID copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}