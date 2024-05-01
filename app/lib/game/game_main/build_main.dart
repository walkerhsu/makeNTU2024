import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/game_main/main.dart';
import 'package:rpg_game/game/generate_story.dart';

class GameMainBuilder extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  const GameMainBuilder({super.key});

  @override
  State<GameMainBuilder> createState() => _GameMainBuilderState();
}

class _GameMainBuilderState extends State<GameMainBuilder> {
  late String _destination;
  late String _gameType;
  late double? _destLat;
  late double? _destLng;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    _destination = arguments['destination'] as String;
    _gameType = arguments['gameType'] as String;
    _destLat = (arguments['destLatLng'] as LatLng?)?.latitude;
    _destLng = (arguments['destLatLng'] as LatLng?)?.longitude;
    return FutureBuilder(
        future: getGPTResponse(_destination, _gameType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MyLoading();
          } else {
            return GameMain(
                destination: _destination,
                gameType: _gameType,
                dstLat: _destLat!,
                dstLng: _destLng!,
                story: snapshot.data!["story"] as String,
                options: snapshot.data!["options"] as List<String>);
          }
        });
  }
}
