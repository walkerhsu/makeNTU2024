import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class GameMainPage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  GameMainPage({super.key});

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
      body: Center(
        child: Text(
          "$_destination \n $_gameType \n ($_destLat , $_destLng)",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
