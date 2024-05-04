import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/game_main/main.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';
import 'package:rpg_game/game/generate_Story.dart';

class WaitResultPage extends StatefulWidget {
  const WaitResultPage({super.key});

  @override
  State<WaitResultPage> createState() => _WaitResultPageState();
}

class _WaitResultPageState extends State<WaitResultPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getHTTPResponse(
            userStateStore.state.destination, userStateStore.state.gameType,
            option: userStateStore.state.option),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MyLoading();
          } else {
            print(snapshot.data);
            return GameMain(
                story: snapshot.data!["story"] as String,
                options:
                    snapshot.data!["options"] as List<Map<String, dynamic>>);
          }
        });
  }
}
