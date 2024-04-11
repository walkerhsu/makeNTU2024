import 'package:flutter/material.dart';

class GameMainPage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  GameMainPage({super.key});

  late final String _destination;
  late final String _gameType;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    _destination = arguments['destination'] as String;
    _gameType = arguments['gameType'] as String;
    return Scaffold(
      body: Center(
        child: Text("$_destination $_gameType",
        style: Theme.of(context).textTheme.bodySmall,
      )),
    );
  }
}
