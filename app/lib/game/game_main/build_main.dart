import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/main.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';
import 'package:rpg_game/game/fetch_request.dart';

class GameMainBuilder extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  const GameMainBuilder({super.key});

  @override
  State<GameMainBuilder> createState() => _GameMainBuilderState();
}

class _GameMainBuilderState extends State<GameMainBuilder> {
  // final Key _progressBarKey = GlobalKey();

  final String language = "zh";
  final String locale = "zh-TW";
  List<String> sentences = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getHTTPResponse(
            userStateStore.state.destination, userStateStore.state.gameType, option: userStateStore.state.option),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Game"),
                leading: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
              body: Column(children: [
                ProgressBar(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 25,
                  color: Colors.blue,
                  backgroundColor: Colors.black,
                ),
                const MyLoading(),
              ]),
            );
          } else {
            return GameMain(
                story: snapshot.data!["story"] as String,
                options:
                    snapshot.data!["options"] as List<Map<String, dynamic>>);
          }
        });
  }
}
