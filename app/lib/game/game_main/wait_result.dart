import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';

class WaitResultPage extends StatefulWidget {
  const WaitResultPage({super.key});

  @override
  State<WaitResultPage> createState() => _WaitResultPageState();
}

class _WaitResultPageState extends State<WaitResultPage> {
  Timer? timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    userStateStore.dispatch(SetHealthAction(userStateStore.state.health - 1));
  });

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
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ProgressBar(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 25,
                        color: Colors.blue,
                        backgroundColor: Colors.black,
                      ),
                      Text(userStateStore.state.health.toString(),
                          style: TextStyle(fontSize: 30,
                              color: Theme.of(context).textTheme.bodySmall!.color),),
                    ],
                  ),
                ),
              );
            }));
  }
}
