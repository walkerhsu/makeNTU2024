import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/main.dart';
import 'package:rpg_game/game/generate_story.dart';

class GameMainBuilder extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  GameMainBuilder({super.key});

  late final String _destination;
  late final String _gameType;
  late final double? _destLat;
  late final double? _destLng;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    _destination = arguments['destination'] as String;
    _gameType = arguments['gameType'] as String;
    _destLat = (arguments['destLatLng'] as LatLng?)?.latitude;
    _destLng = (arguments['destLatLng'] as LatLng?)?.longitude;
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Game'),
        // ),
        body: FutureBuilder(
            future: getGPTResponse(_destination, _gameType),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MyLoading();
              } else {
                return Column(
                  children: [
                    ProgressBar(
                      dstLat: _destLat!,
                      dstLng: _destLng!,
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 25,
                      color: Colors.blue,
                      backgroundColor: Colors.black,
                    ),
                    GameMain(
                        story: snapshot.data!["story"] as String,
                        options: snapshot.data!["options"] as List<String>),
                  ],
                );
              }
            }));
  }
}
