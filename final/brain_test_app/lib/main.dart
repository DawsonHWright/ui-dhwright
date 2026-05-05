import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const BrainTestApp());
}

class AppSettings extends ChangeNotifier {
  bool darkMode = true;
  bool soundOn = true;

  void toggleDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void toggleSound(bool value) {
    soundOn = value;
    notifyListeners();
  }

  void playClick() {}
  void playReady() {}
  void playSuccess() {}
  void playError() {}
}

final AppSettings appSettings = AppSettings();

class GameStats extends ChangeNotifier {
  final Map<String, int> played = {
    'Reaction': 0,
    'Memory': 0,
    'Pattern': 0,
  };

  final Map<String, int> wins = {
    'Memory': 0,
    'Pattern': 0,
  };

  int reactionTotalMs = 0;
  int reactionCompleted = 0;

  void recordReaction(int milliseconds) {
    played['Reaction'] = (played['Reaction'] ?? 0) + 1;
    reactionCompleted++;
    reactionTotalMs += milliseconds;
    notifyListeners();
  }

  void recordReactionTooEarly() {
    played['Reaction'] = (played['Reaction'] ?? 0) + 1;
    notifyListeners();
  }

  double averageReactionMs() {
    if (reactionCompleted == 0) return 0;
    return reactionTotalMs / reactionCompleted;
  }

  void recordGame(String game, bool won) {
    played[game] = (played[game] ?? 0) + 1;

    if (won) {
      wins[game] = (wins[game] ?? 0) + 1;
    }

    notifyListeners();
  }

  double winPercent(String game) {
    final total = played[game] ?? 0;
    final gameWins = wins[game] ?? 0;

    if (total == 0) return 0;
    return (gameWins / total) * 100;
  }

  void reset() {
    for (final game in played.keys) {
      played[game] = 0;
    }

    for (final game in wins.keys) {
      wins[game] = 0;
    }

    reactionTotalMs = 0;
    reactionCompleted = 0;

    notifyListeners();
  }
}

final GameStats gameStats = GameStats();

class BrainTestApp extends StatefulWidget {
  const BrainTestApp({super.key});

  @override
  State<BrainTestApp> createState() => _BrainTestAppState();
}

class _BrainTestAppState extends State<BrainTestApp> {
  @override
  void initState() {
    super.initState();
    appSettings.addListener(updateTheme);
  }

  void updateTheme() {
    setState(() {});
  }

  @override
  void dispose() {
    appSettings.removeListener(updateTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Test App',
      debugShowCheckedModeBanner: false,
      themeMode: appSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(0.08, 0.05),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = appSettings.darkMode
        ? const [
            Color(0xff5b2cff),
            Color(0xff8f5cff),
            Color(0xff1f1b4d),
          ]
        : const [
            Color(0xffc7d2fe),
            Color(0xffddd6fe),
            Color(0xfff5f3ff),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

class HomeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  HomeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void open(BuildContext context, Widget page) {
    appSettings.playClick();
    Navigator.of(context).push(createRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = appSettings.darkMode ? Colors.white : Colors.black87;
    final subtitleColor = appSettings.darkMode ? Colors.white70 : Colors.black54;

    final gameItems = [
      HomeItem(
        title: 'Reaction',
        subtitle: 'Speed',
        icon: Icons.flash_on,
        color: Colors.orange,
        screen: const ReactionTestScreen(),
      ),
      HomeItem(
        title: 'Memory',
        subtitle: 'Simon Says',
        icon: Icons.psychology,
        color: Colors.green,
        screen: const MemoryTestScreen(),
      ),
      HomeItem(
        title: 'Pattern',
        subtitle: 'Logic',
        icon: Icons.grid_view,
        color: Colors.blue,
        screen: const PatternMatchScreen(),
      ),
    ];

    final appOptionItems = [
      HomeItem(
        title: 'Stats',
        subtitle: 'Progress',
        icon: Icons.bar_chart,
        color: Colors.pink,
        screen: const StatsScreen(),
      ),
      HomeItem(
        title: 'Settings',
        subtitle: 'Options',
        icon: Icons.settings,
        color: Colors.deepPurple,
        screen: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brain Test',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Text(
                  'Test your mind with quick challenges',
                  style: TextStyle(fontSize: 16, color: subtitleColor),
                ),
                const SizedBox(height: 26),
                Text(
                  'Games',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;

                    if (constraints.maxWidth > 600) {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gameItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            constraints.maxWidth > 600 ? 1.55 : 3.4,
                      ),
                      itemBuilder: (context, index) {
                        final item = gameItems[index];

                        return GameCard(
                          title: item.title,
                          subtitle: item.subtitle,
                          icon: item.icon,
                          color: item.color,
                          onTap: () => open(context, item.screen),
                        );
                      },
                    );
                  },
                ),
                const Spacer(),
                Text(
                  'App Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GameCard(
                        title: appOptionItems[0].title,
                        subtitle: appOptionItems[0].subtitle,
                        icon: appOptionItems[0].icon,
                        color: appOptionItems[0].color,
                        onTap: () => open(context, appOptionItems[0].screen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GameCard(
                        title: appOptionItems[1].title,
                        subtitle: appOptionItems[1].subtitle,
                        icon: appOptionItems[1].icon,
                        color: appOptionItems[1].color,
                        onTap: () => open(context, appOptionItems[1].screen),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = appSettings.darkMode
        ? Colors.white.withOpacity(0.92)
        : Colors.white.withOpacity(0.96);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      elevation: 7,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const GameScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = appSettings.darkMode ? Colors.white : Colors.black87;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        appSettings.playClick();
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final String title;
  final String message;
  final Widget restartRoute;
  final String gameName;
  final bool success;
  final bool shouldRecordStats;

  const ResultScreen({
    super.key,
    required this.title,
    required this.message,
    required this.restartRoute,
    required this.gameName,
    this.success = true,
    this.shouldRecordStats = true,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.shouldRecordStats) {
      gameStats.recordGame(widget.gameName, widget.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.success ? Icons.emoji_events : Icons.error_outline;
    final iconColor = widget.success ? Colors.amber : Colors.redAccent;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 70, color: iconColor),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        appSettings.playClick();
                        Navigator.pushReplacement(
                          context,
                          createRoute(widget.restartRoute),
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                    TextButton(
                      onPressed: () {
                        appSettings.playClick();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Back Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReactionTestScreen extends StatefulWidget {
  const ReactionTestScreen({super.key});

  @override
  State<ReactionTestScreen> createState() => _ReactionTestScreenState();
}

class _ReactionTestScreenState extends State<ReactionTestScreen> {
  final Random random = Random();

  Color circleColor = Colors.red;
  String instruction = 'Tap the circle to start';
  bool started = false;
  bool ready = false;

  Timer? timer;
  final Stopwatch stopwatch = Stopwatch();

  void startTest() {
    setState(() {
      started = true;
      ready = false;
      circleColor = Colors.red;
      instruction = 'Wait for green...';
    });

    final delay = random.nextInt(3000) + 1500;

    timer?.cancel();
    timer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;

      setState(() {
        ready = true;
        circleColor = Colors.green;
        instruction = 'Tap now!';
      });

      stopwatch.reset();
      stopwatch.start();
    });
  }

  void handleTap() {
    if (!started) {
      appSettings.playClick();
      startTest();
      return;
    }

    if (!ready) {
      timer?.cancel();
      gameStats.recordReactionTooEarly();
      appSettings.playError();

      Navigator.push(
        context,
        createRoute(
          const ResultScreen(
            title: 'Too Early!',
            message: 'You tapped before the circle turned green.',
            restartRoute: ReactionTestScreen(),
            gameName: 'Reaction',
            success: false,
            shouldRecordStats: false,
          ),
        ),
      );
      return;
    }

    stopwatch.stop();
    final time = stopwatch.elapsedMilliseconds;

    gameStats.recordReaction(time);
    appSettings.playSuccess();

    Navigator.push(
      context,
      createRoute(
        ResultScreen(
          title: 'Your Time',
          message: '$time ms',
          restartRoute: const ReactionTestScreen(),
          gameName: 'Reaction',
          success: true,
          shouldRecordStats: false,
        ),
      ),
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
    final textColor = appSettings.darkMode ? Colors.white : Colors.black87;

    return GameScaffold(
      title: 'Reaction Time',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 45),
          GestureDetector(
            onTap: handleTap,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: circleColor.withOpacity(0.55),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'PRESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'The color change is instant for more accurate timing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appSettings.darkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

enum SimonColor {
  red,
  blue,
  green,
  yellow,
}

class MemoryTestScreen extends StatefulWidget {
  const MemoryTestScreen({super.key});

  @override
  State<MemoryTestScreen> createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  final Random random = Random();

  late List<SimonColor> pattern;
  List<SimonColor> userInput = [];

  SimonColor? activeColor;
  bool showingPattern = false;
  bool canTap = false;
  String instruction = 'Watch the pattern';

  @override
  void initState() {
    super.initState();

    final allColors = SimonColor.values;
    pattern = List.generate(
      4,
      (_) => allColors[random.nextInt(allColors.length)],
    );

    Future.delayed(const Duration(milliseconds: 700), showPattern);
  }

  Future<void> showPattern() async {
    setState(() {
      showingPattern = true;
      canTap = false;
      instruction = 'Watch carefully...';
      userInput.clear();
    });

    await Future.delayed(const Duration(milliseconds: 500));

    for (final color in pattern) {
      if (!mounted) return;

      setState(() {
        activeColor = color;
      });

      await Future.delayed(const Duration(milliseconds: 550));

      if (!mounted) return;

      setState(() {
        activeColor = null;
      });

      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!mounted) return;

    setState(() {
      showingPattern = false;
      canTap = true;
      instruction = 'Now repeat it!';
    });
  }

  void pressColor(SimonColor color) {
    if (!canTap || showingPattern) return;

    appSettings.playClick();

    setState(() {
      userInput.add(color);
      activeColor = color;
    });

    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        activeColor = null;
      });
    });

    final index = userInput.length - 1;

    if (userInput[index] != pattern[index]) {
      appSettings.playError();

      Navigator.push(
        context,
        createRoute(
          const ResultScreen(
            title: 'Wrong Pattern',
            message: 'You missed the sequence. Try watching the flashes closely.',
            restartRoute: MemoryTestScreen(),
            gameName: 'Memory',
            success: false,
          ),
        ),
      );
      return;
    }

    if (userInput.length == pattern.length) {
      appSettings.playSuccess();

      Navigator.push(
        context,
        createRoute(
          const ResultScreen(
            title: 'Correct!',
            message: 'You repeated the full pattern correctly.',
            restartRoute: MemoryTestScreen(),
            gameName: 'Memory',
            success: true,
          ),
        ),
      );
    }
  }

  Color baseColor(SimonColor color) {
    switch (color) {
      case SimonColor.red:
        return Colors.red;
      case SimonColor.blue:
        return Colors.blue;
      case SimonColor.green:
        return Colors.green;
      case SimonColor.yellow:
        return Colors.amber;
    }
  }

  String colorName(SimonColor color) {
    switch (color) {
      case SimonColor.red:
        return 'Red';
      case SimonColor.blue:
        return 'Blue';
      case SimonColor.green:
        return 'Green';
      case SimonColor.yellow:
        return 'Yellow';
    }
  }

  Widget simonButton(SimonColor color) {
    final isActive = activeColor == color;
    final actualColor = baseColor(color);

    return GestureDetector(
      onTap: () => pressColor(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 135,
        height: 135,
        decoration: BoxDecoration(
          color: isActive ? actualColor : actualColor.withOpacity(0.45),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(isActive ? 0.95 : 0.35),
            width: isActive ? 5 : 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: actualColor.withOpacity(0.8),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            colorName(color),
            style: TextStyle(
              color: Colors.white,
              fontSize: isActive ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appSettings.darkMode ? Colors.white : Colors.black87;
    final subTextColor = appSettings.darkMode ? Colors.white70 : Colors.black54;

    return GameScaffold(
      title: 'Memory Test',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            showingPattern
                ? 'The app is showing the sequence'
                : 'Progress: ${userInput.length}/${pattern.length}',
            style: TextStyle(color: subTextColor, fontSize: 17),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: [
              simonButton(SimonColor.red),
              simonButton(SimonColor.blue),
              simonButton(SimonColor.green),
              simonButton(SimonColor.yellow),
            ],
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: showingPattern ? null : showPattern,
            icon: const Icon(Icons.replay),
            label: const Text('Show Pattern Again'),
          ),
        ],
      ),
    );
  }
}

class PatternQuestion {
  final String question;
  final List<String> answers;
  final String correctAnswer;
  final String explanation;

  PatternQuestion({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
  });
}

class PatternMatchScreen extends StatefulWidget {
  const PatternMatchScreen({super.key});

  @override
  State<PatternMatchScreen> createState() => _PatternMatchScreenState();
}

class _PatternMatchScreenState extends State<PatternMatchScreen> {
  final Random random = Random();

  late PatternQuestion currentQuestion;
  late List<String> shuffledAnswers;

  final List<PatternQuestion> questions = [
    PatternQuestion(
      question: '1, 4, 9, 16, __',
      answers: ['25', '30', '27'],
      correctAnswer: '25',
      explanation: 'The numbers are squares: 1, 4, 9, 16, 25.',
    ),
    PatternQuestion(
      question: '2, 4, 8, 16, __',
      answers: ['24', '30', '32'],
      correctAnswer: '32',
      explanation: 'Each number doubles.',
    ),
    PatternQuestion(
      question: '3, 6, 9, 12, __',
      answers: ['15', '18', '21'],
      correctAnswer: '15',
      explanation: 'The pattern increases by 3.',
    ),
    PatternQuestion(
      question: '5, 10, 20, 40, __',
      answers: ['60', '80', '100'],
      correctAnswer: '80',
      explanation: 'Each number doubles.',
    ),
    PatternQuestion(
      question: '10, 8, 6, 4, __',
      answers: ['1', '2', '3'],
      correctAnswer: '2',
      explanation: 'The pattern decreases by 2.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    currentQuestion = questions[random.nextInt(questions.length)];
    shuffledAnswers = [...currentQuestion.answers]..shuffle();
  }

  void checkAnswer(String answer) {
    final correct = answer == currentQuestion.correctAnswer;

    if (correct) {
      appSettings.playSuccess();
    } else {
      appSettings.playError();
    }

    Navigator.push(
      context,
      createRoute(
        ResultScreen(
          title: correct ? 'Correct!' : 'Incorrect',
          message: correct
              ? currentQuestion.explanation
              : 'Correct answer: ${currentQuestion.correctAnswer}\n${currentQuestion.explanation}',
          restartRoute: const PatternMatchScreen(),
          gameName: 'Pattern',
          success: correct,
        ),
      ),
    );
  }

  Widget answerButton(String answer) {
    return SizedBox(
      width: 120,
      height: 85,
      child: ElevatedButton(
        onPressed: () => checkAnswer(answer),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          answer,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = appSettings.darkMode ? Colors.white : Colors.black87;

    return GameScaffold(
      title: 'Pattern Match',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Which Comes Next?',
            style: TextStyle(
              color: textColor,
              fontSize: 31,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                currentQuestion.question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 38),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            alignment: WrapAlignment.center,
            children: shuffledAnswers.map(answerButton).toList(),
          ),
        ],
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    gameStats.addListener(refresh);
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    gameStats.removeListener(refresh);
    super.dispose();
  }

  Widget reactionStatCard() {
    final total = gameStats.played['Reaction'] ?? 0;
    final avg = gameStats.averageReactionMs();

    final avgText = avg == 0 ? '---' : '${avg.toStringAsFixed(0)} ms';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.orange.withOpacity(0.18),
              child: const Icon(Icons.flash_on, color: Colors.orange, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reaction',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Games played: $total',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Completed attempts: ${gameStats.reactionCompleted}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'Average',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  avgText,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget winStatCard(String game, IconData icon, Color color) {
    final total = gameStats.played[game] ?? 0;
    final wins = gameStats.wins[game] ?? 0;
    final percent = gameStats.winPercent(game).toStringAsFixed(1);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Games played: $total',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Wins: $wins',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'Win Rate',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Stats',
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                reactionStatCard(),
                winStatCard('Memory', Icons.psychology, Colors.green),
                winStatCard('Pattern', Icons.grid_view, Colors.blue),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              appSettings.playClick();
              gameStats.reset();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Stats'),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Settings',
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(18),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings, size: 58),
                const SizedBox(height: 12),
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Change the app appearance'),
                  value: appSettings.darkMode,
                  onChanged: (value) {
                    appSettings.toggleDarkMode(value);
                    update();
                  },
                ),
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Prototype toggle for sound feedback'),
                  value: appSettings.soundOn,
                  onChanged: (value) {
                    appSettings.toggleSound(value);
                    update();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}