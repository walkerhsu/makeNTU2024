import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:rpg_game/car_settings.dart';
import 'package:rpg_game/game/game_main/game_end.dart';
import 'package:rpg_game/game/game_main/wait_result.dart';
import 'package:rpg_game/memoirs.dart';

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
        '/memoirs': (context) => const MemoirsPage(),
        '/car_settings': (context) => const CarSettingsPage(),
        '/game/settings': (context) => const GameSettingsPage(),
        '/game/main': (context) => const GameMainBuilder(),
        '/game/wait_result': (context) => const WaitResultPage(),
        '/game/end': (context) => const GameEndPage(),
      },
    );
  }
}
