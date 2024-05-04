import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/state.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';
import 'package:rpg_game/game/game_main/userState/view_model.dart';
import 'package:rpg_game/game/my_location.dart';
import 'package:http/http.dart' as http;

class ProgressBar extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Color backgroundColor;

  const ProgressBar({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.backgroundColor,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late final Timer _timer;
  double iconWidth = 30;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..repeat(reverse: true);
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      getEstimatedTime(userStateStore.state.dstLat, userStateStore.state.dstLng)
          .then((value) {
        if (userStateStore.state.totalTime == 0.1) {
          userStateStore.dispatch(SetTimeAction(value, value));
        } else {
          print("value: $value");
          userStateStore.dispatch(
              SetTimeAction(value, userStateStore.state.currentTime - 1));
        }
      });
    });
  }

  @override
  void dispose() {
    print("_timer canceling");
    _timer.cancel();
    print("_timer canceled");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<UserState>(
        store: userStateStore,
        child: StoreConnector<UserState, UserViewModel>(
            converter: (Store<UserState> store) {
          return UserViewModel.create(store);
        }, builder: (BuildContext context, UserViewModel userViewModel) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                  child: Container(
                width: widget.width + iconWidth,
                height: iconWidth,
                decoration: BoxDecoration(
                  // color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Transform.rotate(
                      angle: -90 * 3.14159 / 180,
                      child: Image.asset(
                        'assets/images/start-line.png',
                        width: iconWidth,
                        height: iconWidth,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/flag.png',
                      width: iconWidth,
                      height: iconWidth,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: widget.width *
                        ((userViewModel.totalTime - userViewModel.currentTime) /
                                userViewModel.totalTime)
                            .clamp(0, 1),
                    child: RotationTransition(
                      turns:
                          Tween(begin: -0.05, end: 0.05).animate(_controller),
                      child: Image.asset(
                        'assets/images/car.png',
                        width: iconWidth,
                        height: iconWidth,
                      ),
                    ),
                  ),
                ]),
              )),
              const SizedBox(height: 5),
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
                            ((userViewModel.totalTime -
                                        userViewModel.currentTime) /
                                    userViewModel.totalTime)
                                .clamp(0, 1),
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
            ],
          );
        }));
  }

  Future<double> getEstimatedTime(double dstLat, double dstLng) async {
    LatLng latlng = await MyLocation.handleCurrentPosition();
    final curLat = latlng.latitude;
    final curLng = latlng.longitude;
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$curLng,$curLat;$dstLng,$dstLat?steps=true&access_token=$accessToken';
    // TODO: Remove this line
    bool test = true;
    if (test) {
      return 1000;
    }
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
