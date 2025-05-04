import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'input_page.dart';
import 'result_screen.dart';
import 'saved_results_screen.dart';

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      home: const BMICalculatorHomeScreen(),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final double bmi;
  final int weight;
  final int age;
  final String gender;

  const ResultScreen({
    super.key,
    required this.bmi,
    required this.weight,
    required this.age,
    required this.gender,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showResetDialog = false;

  void _showResetDialogBox() {
    setState(() {
      _showResetDialog = true;
    });
  }

  void _resetData() {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    setState(() {
      _showResetDialog = false;
    });
  }

  Future<void> _saveResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedResults = prefs.getStringList('bmi_results') ?? [];
      final result = {
        'bmi': widget.bmi,
        'weight': widget.weight,
        'age': widget.age,
        'gender': widget.gender,
        'timestamp': DateTime.now().toIso8601String(),
      };
      savedResults.add(jsonEncode(result));
      await prefs.setStringList('bmi_results', savedResults);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving result: $e')),
      );
    }
  }

  void _viewSavedResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedResultsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    String bmiCategory = widget.bmi < 18.5
        ? 'Underweight'
        : widget.bmi < 25
        ? 'Normal'
        : widget.bmi < 30
        ? 'Overweight'
        : 'Obese';
    String advice = widget.bmi < 18.5
        ? 'The best way to gain weight is through a balanced diet with more calories.'
        : widget.bmi < 25
        ? 'You are at a healthy weight! Keep maintaining a balanced diet and exercise.'
        : 'The best way to lose weight if you are overweight is through a combination of diet and exercise.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Your Result',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bmiCategory.toUpperCase(),
                        style: const TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      Text(
                        widget.bmi.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'kg/m²',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 10,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (widget.bmi.clamp(0, 18.5) / 40 * 100).toInt(),
                              child: Container(color: Colors.blue),
                            ),
                            Expanded(
                              flex: ((widget.bmi.clamp(18.5, 25) - 18.5) / 40 * 100).toInt(),
                              child: Container(color: Colors.green),
                            ),
                            Expanded(
                              flex: ((widget.bmi.clamp(25, 30) - 25) / 40 * 100).toInt(),
                              child: Container(color: Colors.orange),
                            ),
                            Expanded(
                              flex: ((widget.bmi.clamp(30, 40) - 30) / 40 * 100).toInt(),
                              child: Container(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveResult,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Save Result'),
                          ),
                          ElevatedButton(
                            onPressed: _viewSavedResults,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('View Saved Results'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Advice: $advice',
                        style: const TextStyle(fontSize: 16, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {},
                        child: const Text('More', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _showResetDialogBox,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('RE-CALCULATE YOUR BMI',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ],
            ),
          ),
          if (_showResetDialog)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Would you reset your BMI data?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _resetData,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Yes'),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => _showResetDialog = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('No'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'For tips on maintaining a healthy weight check out the food and diet fitness',
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
        title: const Text('Saved BMI Results', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_savedResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No saved results yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _savedResults.length,
                  itemBuilder: (context, index) {
                    final result = _savedResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('BMI: ${result['bmi'].toStringAsFixed(1)}'),
                        subtitle: Text(
                          'Weight: ${result['weight']} kg, Age: ${result['age']}, Gender: ${result['gender']}\n'
                              'Saved on: ${DateTime.parse(result['timestamp']).toLocal()}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_savedResults.isNotEmpty)
              ElevatedButton(
                onPressed: _clearResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Clear All Results',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}