import 'package:flutter/material.dart';
import 'result_screen.dart';

class BMICalculatorHomeScreen extends StatefulWidget {
  const BMICalculatorHomeScreen({super.key});

  @override
  _BMICalculatorHomeScreenState createState() => _BMICalculatorHomeScreenState();
}

class _BMICalculatorHomeScreenState extends State<BMICalculatorHomeScreen> {
  String selectedGender = 'Male';
  double heightCm = 180.0;
  int weight = 74;
  int age = 19;

  void _calculateBMI() {
    if (weight <= 20 || heightCm <= 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and height')),
      );
      return;
    }
    double heightM = heightCm / 100;
    double bmi = weight / (heightM * heightM);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          bmi: bmi,
          weight: weight,
          age: age,
          gender: selectedGender,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
          style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => selectedGender = 'Male'),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: selectedGender == 'Male'
                            ? Colors.cyanAccent.withOpacity(0.3)
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent, width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.male, size: 50, color: Colors.cyanAccent),
                          Text(
                            'Male',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => selectedGender = 'Female'),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: selectedGender == 'Female'
                            ? Colors.pinkAccent.withOpacity(0.3)
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.pinkAccent, width: 2),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.female, size: 50, color: Colors.pinkAccent),
                          Text(
                            'Female',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    const Text(
                      'HEIGHT',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${heightCm.toStringAsFixed(0)} cm',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: heightCm,
                      min: 60.0,
                      max: 220.0,
                      activeColor: Colors.cyanAccent,
                      inactiveColor: Colors.grey[600],
                      onChanged: (value) => setState(() => heightCm = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 150,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'AGE',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$age',
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: age.toDouble(),
                          min: 1,
                          max: 100,
                          activeColor: Colors.cyanAccent,
                          inactiveColor: Colors.grey[600],
                          onChanged: (value) =>
                              setState(() => age = value.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.cyanAccent),
                              onPressed: () =>
                                  setState(() => age > 1 ? age-- : null),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.cyanAccent),
                              onPressed: () => setState(() => age++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 150,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'WEIGHT',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$weight',
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: weight.toDouble(),
                          min: 20,
                          max: 200,
                          activeColor: Colors.cyanAccent,
                          inactiveColor: Colors.grey[600],
                          onChanged: (value) =>
                              setState(() => weight = value.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.cyanAccent),
                              onPressed: () =>
                                  setState(() => weight > 20 ? weight-- : null),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.cyanAccent),
                              onPressed: () => setState(() => weight++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'CALCULATE YOUR BMI',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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