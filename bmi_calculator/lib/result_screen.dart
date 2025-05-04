import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'saved_results_screen.dart';

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
          title: const Text('BMI Calculator',
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
                const Text(
                'Your Result',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      bmiCategory.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.bmi.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'kg/m²',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.cyanAccent,
                      ),
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
                            flex:
                            ((widget.bmi.clamp(18.5, 25) - 18.5) / 40 * 100)
                                .toInt(),
                            child: Container(color: Colors.green),
                          ),
                          Expanded(
                            flex: ((widget.bmi.clamp(25, 30) - 25) / 40 * 100)
                                .toInt(),
                            child: Container(color: Colors.orange),
                          ),
                          Expanded(
                            flex: ((widget.bmi.clamp(30, 40) - 30) / 40 * 100)
                                .toInt(),
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
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Save Result'),
                        ),
                        ElevatedButton(
                          onPressed: _viewSavedResults,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('View Saved Results'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Advice: $advice',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'More',
                        style: TextStyle(color: Colors.cyanAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showResetDialogBox,
                style: ElevatedButton.styleFrom(
                    minimum -----: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'RE-CALCULATE YOUR BMI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_showResetDialog)
        Center(
    child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: Colors.grey[900],
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.cyanAccent, width: 2),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    const Text(
    'Would you reset your BMI data?',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.cyanAccent,
    ),
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
    backgroundColor: Colors.cyanAccent,
    foregroundColor: Colors.black,
    ),
    child: const Text('Yes'),
    ),
    ElevatedButton(
    onPressed: () =>
    setState(() => _showResetDialog = false),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[800],
    foregroundColor: Colors.cyanAccent,
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
    style: TextStyle(
    color: Colors.cyanAccent,
    fontWeight: FontWeight.bold,
    ),
    textAlign: TextAlign.center,
    ),
    ),
    ],
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