import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/story.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
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
    return StoreProvider<UserState>(
        store: userStateStore,
        child: StoreConnector<UserState, double>(
            converter: (store) => store.state.health,
            builder: (context, health) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Waiting for result'),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ProgressBar(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 25,
                      color: Colors.blue,
                      backgroundColor: Colors.black,
                    ),
                    FutureBuilder(
                        future: getGPTResponse(
                            userStateStore.state.destination,
                            userStateStore.state.gameType),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const MyLoading();
                          } else {
                            return StoryBody(story: snapshot.data!["story"] as String, options: [{"": ""}] as List<Map<String, dynamic>>);
                          }
                        })
                  ],
                ),
              );
            }));
  }
}
