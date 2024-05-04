import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/main.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';
import 'package:rpg_game/game/fetch_request.dart';

class WaitResultPage extends StatefulWidget {
  const WaitResultPage({super.key});

  @override
  State<WaitResultPage> createState() => _WaitResultPageState();
}

class _WaitResultPageState extends State<WaitResultPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      getBattleResult().then((value) {
        if (value != "playing") {
          timer.cancel();
          Navigator.popAndPushNamed(context, "/game/main");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battling"),
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
        const MyLoading(loadingText: "Waiting for the result"),
      ]),
    );
  }
}
