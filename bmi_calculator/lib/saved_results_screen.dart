import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedResultsScreen extends StatefulWidget {
  const SavedResultsScreen({super.key});

  @override
  _SavedResultsScreenState createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  List<Map<String, dynamic>> _savedResults = [];

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedResults = prefs.getStringList('bmi_results') ?? [];
      setState(() {
        _savedResults = savedResults
            .map((result) => jsonDecode(result) as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading results: $e')),
      );
    }
  }

  Future<void> _clearResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('bmi_results');
      setState(() {
        _savedResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All saved results cleared!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing results: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved BMI Results',
            style: TextStyle(color: Colors.cyanAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_savedResults.isEmpty)
                const SizedBox(
                  height: 400,
                  child: Center(
                    child: Text(
                      'No saved results yet!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _savedResults.length,
                  itemBuilder: (context, index) {
                    final result = _savedResults[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.cyanAccent, width: 2),
                      ),
                      child: ListTile(
                        title: Text(
                          'BMI: ${result['bmi'].toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Weight: ${result['weight']} kg, Age: ${result['age']}, Gender: ${result['gender']}\n'
                              'Saved on: ${DateTime.parse(result['timestamp']).toLocal()}',
                          style: const TextStyle(color: Colors.pinkAccent),
                        ),
                      ),
                    );
                  },
                ),
              if (_savedResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: _clearResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Clear All Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}