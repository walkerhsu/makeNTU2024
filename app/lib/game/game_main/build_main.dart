import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/game_main/main.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';
import 'package:rpg_game/game/generate_story.dart';

class GameMainBuilder extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  const GameMainBuilder({super.key});

  @override
  State<GameMainBuilder> createState() => _GameMainBuilderState();
}

class _GameMainBuilderState extends State<GameMainBuilder> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: getGPTResponse(userStateStore.state.destination, userStateStore.state.gameType),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MyLoading();
            } else {
              return GameMain(
                  story: snapshot.data!["story"] as String,
                  options:
                      snapshot.data!["options"] as List<Map<String, dynamic>>);
            }
          });
  }
}
