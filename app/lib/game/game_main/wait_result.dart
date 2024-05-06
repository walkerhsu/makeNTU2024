import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
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
          if (value == "win") {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: "You win! Let's proceed the story!",
            ).then((value) {
              if (mounted && context.mounted) {
                Navigator.popAndPushNamed(context, "/game/main");
              }
            });
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: "You lose~~ QAQ Let's continue the story!",
            ).then((value) {
              if (mounted && context.mounted) {
                Navigator.popAndPushNamed(context, "/game/main");
              }
            });
          }
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
          color: const Color.fromARGB(255, 249, 163, 3),
          backgroundColor: Colors.black,
        ),
        const MyLoading(loadingText: "Waiting for the result"),
      ]),
    );
  }
}
