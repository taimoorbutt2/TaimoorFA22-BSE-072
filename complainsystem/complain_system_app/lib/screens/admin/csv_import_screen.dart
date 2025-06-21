import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../../services/supabase_service.dart';
import '../../services/email_service.dart';
import '../../models/batch.dart';
import '../../utils/constants.dart';

class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  List<Map<String, dynamic>> _csvData = [];
  List<Batch> _batches = [];
  bool _isLoading = false;
  String? _error;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await SupabaseService.getAllBatches();
      setState(() {
        _batches = batches;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load batches: $e';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final bytes = result.files.first.bytes!;
        final csvString = String.fromCharCodes(bytes);
        final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

        if (csvTable.isEmpty || csvTable.length < 2) {
          setState(() {
            _error = 'CSV file is empty or invalid';
          });
          return;
        }

        // Validate headers
        final headers = csvTable[0].map((e) => e.toString().toLowerCase()).toList();
        final requiredHeaders = ['student_name', 'department', 'phone_no', 'batch_no', 'student_email'];
        
        for (final header in requiredHeaders) {
          if (!headers.contains(header)) {
            setState(() {
              _error = 'Missing required header: $header';
            });
            return;
          }
        }

        // Convert to list of maps
        final data = <Map<String, dynamic>>[];
        for (int i = 1; i < csvTable.length; i++) {
          final row = csvTable[i];
          if (row.length >= headers.length) {
            final map = <String, dynamic>{};
            for (int j = 0; j < headers.length; j++) {
              map[headers[j]] = row[j].toString();
            }
            data.add(map);
          }
        }

        setState(() {
          _csvData = data;
          _error = null;
          _isPreviewMode = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error reading CSV file: $e';
      });
    }
  }

  String _generateStudentId(int index) {
    return '${AppConstants.studentIdPrefix}${(index + 1).toString().padLeft(2, '0')}';
  }

  Future<void> _importStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      int successCount = 0;
      int errorCount = 0;

      for (int i = 0; i < _csvData.length; i++) {
        final row = _csvData[i];
        
        try {
          // Find batch by batch number
          final batch = _batches.firstWhere(
            (b) => b.batchName == row['batch_no'],
            orElse: () => throw Exception('Batch ${row['batch_no']} not found'),
          );

          // Generate student ID
          final studentId = _generateStudentId(i);

          // Create user
          final response = await SupabaseService.signUp(
            email: row['student_email'],
            password: row['student_email'], // Use email as password for students
            name: row['student_name'],
            role: 'student',
            batchId: batch.id,
            phoneNo: row['phone_no'],
            studentId: studentId,
          );

          if (response.user != null) {
            // Send email
            await EmailService.sendStudentCredentials(
              name: row['student_name'],
              email: row['student_email'],
              studentId: studentId,
              batch: batch.batchName,
            );
            successCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          errorCount++;
          print('Error importing student ${row['student_name']}: $e');
        }
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Complete'),
            content: Text('Successfully imported $successCount students.\nFailed to import $errorCount students.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error importing students: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Students from CSV',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'CSV Format: student_name, department, phone_no, batch_no, student_email',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (!_isPreviewMode) ...[
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select CSV File'),
              ),
            ] else ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Change File'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _importStudents,
                    icon: const Icon(Icons.upload),
                    label: const Text('Import Students'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_isPreviewMode && !_isLoading) ...[
              Text(
                'Preview (${_csvData.length} students)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _csvData.length,
                  itemBuilder: (context, index) {
                    final row = _csvData[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(row['student_name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${row['student_email'] ?? ''}'),
                            Text('Batch: ${row['batch_no'] ?? ''}'),
                            Text('Phone: ${row['phone_no'] ?? ''}'),
                          ],
                        ),
                        trailing: Text(
                          _generateStudentId(index),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 