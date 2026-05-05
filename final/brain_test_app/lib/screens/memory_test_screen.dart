import 'package:flutter/material.dart';

class MemoryTestScreen extends StatefulWidget {
  const MemoryTestScreen({super.key});

  @override
  State<MemoryTestScreen> createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  final List<String> correctPattern = ['Red', 'Blue', 'Green'];
  List<String> userPattern = [];

  void pressColor(String color) {
    setState(() {
      userPattern.add(color);
    });

    if (userPattern.length == correctPattern.length) {
      final isCorrect = _isCorrectPattern();

      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'title': isCorrect ? 'Correct!' : 'Wrong Pattern',
          'message': isCorrect
              ? 'You repeated the pattern correctly.'
              : 'Try again and watch the order more carefully.',
        },
      );
    }
  }

  bool _isCorrectPattern() {
    for (int i = 0; i < correctPattern.length; i++) {
      if (correctPattern[i] != userPattern[i]) {
        return false;
      }
    }
    return true;
  }

  Widget colorButton(String label, Color color) {
    return SizedBox(
      width: 120,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: () => pressColor(label),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void resetInput() {
    setState(() {
      userPattern.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final typed = userPattern.isEmpty ? 'None yet' : userPattern.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Repeat the Pattern',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pattern to remember: Red, Blue, Green',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                colorButton('Red', Colors.red),
                colorButton('Blue', Colors.blue),
                colorButton('Green', Colors.green),
                colorButton('Yellow', Colors.amber),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Your input: $typed',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetInput,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}