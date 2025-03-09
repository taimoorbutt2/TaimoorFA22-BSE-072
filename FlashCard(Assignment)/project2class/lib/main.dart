import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MaterialApp( debugShowCheckedModeBanner: false,
  home: FlashcardHomeScreen(),
));

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

class FlashcardHomeScreen extends StatelessWidget {
  const FlashcardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set background color to blue
      appBar: AppBar(
        title: const Text('Flashcard Decks', style: TextStyle(color: Colors.black)), // Black text
        backgroundColor: Colors.white, // Set app bar color to white
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardScreen(
                      deckTitle: 'General Knowledge',
                      flashcards: generalKnowledgeFlashcards,
                    ),
                  ),
                );
              },
              child: const Text('General Knowledge'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardScreen(
                      deckTitle: 'Flutter Basics',
                      flashcards: flutterFlashcards,
                    ),
                  ),
                );
              },
              child: const Text('Flutter Basics'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFlashcardScreen(),
                  ),
                );
              },
              child: const Text('Add New Flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  final String deckTitle;
  final List<Flashcard> flashcards;

  const FlashcardScreen({Key? key, required this.deckTitle, required this.flashcards}) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool showAnswer = false;
  int currentIndex = 0;
  int score = 0;
  Timer? _timer;
  final int _countdownDuration = 5; // Countdown duration in seconds

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick >= _countdownDuration) {
        _flipCard();
        timer.cancel();
      }
    });
  }

  void _flipCard() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _updateScore(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        score++;
      }
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
        showAnswer = false;
        _timer?.cancel();
        _startTimer(); // Restart the timer for the next card
      } else {
        // End of deck
        _timer?.cancel();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Deck Complete!'),
            content: Text('Your score: $score/${widget.flashcards.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to home screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set background color to blue
      appBar: AppBar(
        title: Text(widget.deckTitle, style: const TextStyle(color: Colors.black)), // Black text
        backgroundColor: Colors.white, // Set app bar color to white
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Score: $score/${widget.flashcards.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _timer?.cancel(); // Cancel the timer on manual flip
                  _flipCard();
                  _startTimer(); // Restart the timer
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: Card(
                    key: ValueKey(showAnswer),
                    elevation: 6,
                    color: showAnswer ? Colors.yellow : Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          showAnswer
                              ? widget.flashcards[currentIndex].answer
                              : widget.flashcards[currentIndex].question,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: showAnswer ? Colors.black : Colors.blue.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateScore(true),
                  child: const Text('Correct'),
                ),
                ElevatedButton(
                  onPressed: () => _updateScore(false),
                  child: const Text('Incorrect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddFlashcardScreen extends StatefulWidget {
  const AddFlashcardScreen({Key? key}) : super(key: key);

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set background color to blue
      appBar: AppBar(
        title: const Text('Add New Flashcard', style: TextStyle(color: Colors.black)), // Black text
        backgroundColor: Colors.white, // Set app bar color to white
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Add the new flashcard to the list
                    generalKnowledgeFlashcards.add(
                      Flashcard(
                        question: _questionController.text,
                        answer: _answerController.text,
                      ),
                    );
                    Navigator.pop(context); // Go back to home screen
                  }
                },
                child: const Text('Save Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sample flashcard decks
List<Flashcard> generalKnowledgeFlashcards = [
  const Flashcard(question: "What is the Name of the AppDevelopment teacher?", answer: "Sir Abdullah"),
  const Flashcard(question: "What is the celebration at the end of Ramadan called?", answer: "Eid al-Fitr"),
  const Flashcard(question: "What is the deepest part of the ocean ?", answer: "The Mariana Trench"),
  const Flashcard(question: "What percentage of Earth's surface is water?", answer: "Approximately 71%"),
];

List<Flashcard> flutterFlashcards = [
  const Flashcard(question: "What is Flutter?", answer: "A UI toolkit by Google"),
  const Flashcard(question: " What is the primary programming language used for iOS app development?", answer: "Swift"),
  const Flashcard(question: "What language does Flutter use?", answer: "Dart"),
  const Flashcard(question: "What is the popular cloud-based platform for building and deploying mobile apps?", answer: "Firebase"),
];