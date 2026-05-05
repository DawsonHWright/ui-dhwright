import 'package:flutter/material.dart';

class PatternMatchScreen extends StatelessWidget {
  const PatternMatchScreen({super.key});

  void checkAnswer(BuildContext context, String answer) {
    final bool correct = answer == '25';

    Navigator.pushNamed(
      context,
      '/result',
      arguments: {
        'title': correct ? 'Correct!' : 'Incorrect',
        'message': correct
            ? 'Nice job. The next number is 25.'
            : 'The pattern is +3, +5, +7, +9, so the next answer is 25.',
      },
    );
  }

  Widget answerButton(BuildContext context, String text) {
    return SizedBox(
      width: 110,
      height: 80,
      child: ElevatedButton(
        onPressed: () => checkAnswer(context, text),
        child: Text(
          text,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Which Comes Next?',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              '1, 4, 9, 16, __',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 50),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                answerButton(context, '25'),
                answerButton(context, '30'),
                answerButton(context, '27'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}