import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/Components/loading.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/story.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
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
  String generateText(String story, List<String> options) {
    String text = story;
    text += " Now, please select an option from the following options! ";
    Map<int, String> num2words = {
      1: "one",
      2: "two",
      3: "three",
      4: "four",
    };
    for (int i = 1; i <= options.length; i++) {
      text += "Option ${num2words[i]}: ${options[i]}. ";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: StoreConnector<AppState, ViewModel>(
            converter: (Store<AppState> store) {
          return ViewModel.create(store);
        }, builder: (BuildContext context, ViewModel viewModel) {
          store.dispatch(
              SetVoiceTextAction(generateText(widget.story, widget.options)));
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
                        } else if (viewModel.ttsState == TtsState.playing) {
                          viewModel.pause();
                        } else if (viewModel.ttsState == TtsState.paused) {
                          viewModel.speak();
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
            body: Column(
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
                  story: widget.story,
                  options: widget.options,
                )
              ],
            ),
          );
        }));
  }
}
