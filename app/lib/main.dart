import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_search/mapbox_search.dart';

import 'quiz.dart';
import 'quiz_result.dart';
import 'welcome.dart';
import 'game/game_settings/game_settings.dart';
import 'game/game_main/build_main.dart';
import 'theme/theme_data.dart';

Future main() async {
  await dotenv.load(fileName: "assets/.env");
  MapBoxSearch.init(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print(dotenv.env['MAPBOX_ACCESS_TOKEN']);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(true, context),
      home: const WelcomePage(),
      routes: {
        '/home': (context) => const WelcomePage(),
        '/quiz': (context) => const QuizPage(),
        '/result': (context) => const ResultPage(),
        '/game/settings': (context) => const GameSettingsPage(),
        '/game/main': (context) => GameMainBuilder(),
      },
    );
  }
}
