import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: FlashcardScreen(),
));

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  static const List<Flashcard> flashcards = [
    Flashcard(question: "What is the capital of France?", answer: "Paris"),
    Flashcard(question: "What is 2 + 2?", answer: "4"),
    Flashcard(question: "What is the largest planet?", answer: "Jupiter"),
    Flashcard(question: "Who wrote 'Romeo and Juliet'?", answer: "Shakespeare"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Container(
        color: Colors.blue, // Change background color to blue
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            return FlashcardWidget(flashcard: flashcards[index]);
          },
        ),
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  const FlashcardWidget({Key? key, required this.flashcard}) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showAnswer = false;
  bool isTapped = false; // Track if the card is tapped

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showAnswer = !showAnswer;
          isTapped = !isTapped; // Toggle the tapped state
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Animation duration
        margin: const EdgeInsets.all(10),
        child: Transform.scale(
          scale: isTapped ? 1.05 : 1.0, // Scale up when tapped
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: isTapped ? Colors.yellow : Colors.white, // Change color to yellow when tapped
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Text(
                    showAnswer ? widget.flashcard.answer : widget.flashcard.question,
                    key: ValueKey(showAnswer),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isTapped ? Colors.black : Colors.blue.shade900, // Change text color when tapped
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}