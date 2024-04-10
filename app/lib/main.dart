import 'package:flutter/material.dart';

import 'quiz.dart';
import 'quiz_result.dart';
import 'welcome.dart';
import 'game_settings/game_settings.dart';
import 'theme/theme_data.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(false, context),
      home: const WelcomePage(),
      routes: {
        '/home': (context) => const WelcomePage(),
        '/quiz': (context) => const QuizPage(),
        '/result': (context) => const ResultPage(),
        '/game_settings': (context) => const GameSettingsPage(),
      },
    );
  }
}