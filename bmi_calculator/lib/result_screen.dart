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
    Expanded