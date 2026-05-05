import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ReactionTestScreen extends StatefulWidget {
  const ReactionTestScreen({super.key});

  @override
  State<ReactionTestScreen> createState() => _ReactionTestScreenState();
}

class _ReactionTestScreenState extends State<ReactionTestScreen> {
  Color buttonColor = Colors.red;
  String instruction = 'Press when button turns green';
  bool canTap = false;
  bool started = false;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  void startTest() {
    setState(() {
      buttonColor = Colors.red;
      instruction = 'Wait for green...';
      canTap = false;
      started = true;
    });

    final delay = Random().nextInt(3000) + 2000;

    timer?.cancel();
    timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;

      setState(() {
        buttonColor = Colors.green;
        instruction = 'Tap now!';
        canTap = true;
      });
      stopwatch.reset();
      stopwatch.start();
    });
  }

  void handleTap() {
    if (!started) {
      startTest();
      return;
    }

    if (!canTap) {
      timer?.cancel();
      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'title': 'Too Early!',
          'message': 'You tapped before the button turned green.',
        },
      );
      return;
    }

    stopwatch.stop();
    final time = stopwatch.elapsedMilliseconds;

    Navigator.pushNamed(
      context,
      '/result',
      arguments: {
        'title': 'Your Time',
        'message': '$time ms',
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Time'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                instruction,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: handleTap,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'Press',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Tap the circle once to begin.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}