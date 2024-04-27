import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rpg_game/game/my_location.dart';
import 'package:http/http.dart' as http;

class ProgressBar extends StatefulWidget {
  final double dstLat;
  final double dstLng;
  final double width;
  final double height;
  final Color color;
  final Color backgroundColor;

  const ProgressBar({
    super.key,
    required this.dstLat,
    required this.dstLng,
    required this.width,
    required this.height,
    required this.color,
    required this.backgroundColor,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  late final Timer _timer;
  double total = 0.1;
  double current = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      getEstimatedTime().then((value) {
        print(value);
        print(total);
        print(current);
        if (total == 0.1) {
          setState(() {
            total = value;
            current = value;
          });
        } else {
          setState(() {
            // current = value;
            current -= 5;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                children: [
                  Container(
                    width: widget.width *
                        ((total - current) / total).clamp(0, total),
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text("${(((total - current) / total).clamp(0, total) * 100).toStringAsFixed(0)} %")
        ],
      );
  }

  Future<double> getEstimatedTime() async {
    LatLng latlng = await MyLocation.handleCurrentPosition();
    final curLat = latlng.latitude;
    final curLng = latlng.longitude;
    final dstLat = widget.dstLat;
    final dstLng = widget.dstLng;
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$curLng,$curLat;$dstLng,$dstLat?steps=true&access_token=$accessToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final durationSeconds = decodedResponse['routes'][0]['duration'];
      return durationSeconds;
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
