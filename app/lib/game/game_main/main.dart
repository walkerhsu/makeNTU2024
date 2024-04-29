import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/story.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/game_main/ttsState/view_model.dart';
import 'package:rpg_game/game/generate_story.dart';

class GameMain extends StatefulWidget {
  const GameMain({
    super.key,
    required this.destination,
    required this.gameType,
    required this.dstLat,
    required this.dstLng,
    required this.story,
    required this.options,
  });
  final String destination;
  final String gameType;
  final double dstLat;
  final double dstLng;
  final String story;
  final List<String> options;

  @override
  State<GameMain> createState() => _GameMainState();
}

class _GameMainState extends State<GameMain> {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: StoreConnector<AppState, ViewModel>(
          converter: (Store<AppState> store) {
            return ViewModel.create(store);
          },
          builder: (BuildContext context, ViewModel viewModel) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Game'),
                leading: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: InkWell(
                        onTap: () {
                          print("ttsState : ${viewModel.ttsState.toString()}");
                          if (viewModel.ttsState == TtsState.stopped) {
                            viewModel.speak();
                            setState(() {});
                          } else if (viewModel.ttsState == TtsState.playing) {
                            viewModel.pause();
                            setState(() {});
                          } else if (viewModel.ttsState == TtsState.paused) {
                            viewModel.speak();
                            setState(() {});
                          }
                        },
                        child: viewModel.ttsState == TtsState.playing
                            ? Image.asset(
                                'assets/images/pause.png',
                                width: 25,
                              )
                            : Image.asset(
                                'assets/images/sound.png',
                                width: 25,
                              )),
                  ),
                ],
              ),
              body: FutureBuilder(
                future: getGPTResponse(widget.destination, widget.gameType),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MyLoading();
                  } else {
                    return Column(
                      children: [
                        ProgressBar(
                          dstLat: widget.dstLat,
                          dstLng: widget.dstLng,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 25,
                          color: Colors.blue,
                          backgroundColor: Colors.black,
                        ),
                        StoryBody(
                            story: snapshot.data!["story"] as String,
                            options: snapshot.data!["options"] as List<String>),
                      ],
                    );
                  }
                },
              ),
            );
          },
        ));
  }
}
