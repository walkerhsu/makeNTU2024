import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/story.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/game_main/ttsState/view_model.dart';

class GameMain extends StatefulWidget {
  const GameMain({
    super.key,
    required this.story,
    required this.options,
  });
  final String story;
  final List<Map<String, dynamic>> options;

  @override
  State<GameMain> createState() => _GameMainState();
}

class _GameMainState extends State<GameMain> {
  String generateText(String story, List<Map<String, dynamic>> options) {
    String text = story;
    text += " Now, please select an option from the following options! ";
    for (int i = 0; i < options.length; i++) {
      text += "Option ${options[i]["idx"]}: ${options[i]["option"]}. ";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    print("in");
    return StoreProvider<AppState>(
        store: appStateStore,
        child: StoreConnector<AppState, TTSViewModel>(
            converter: (Store<AppState> store) {
          return TTSViewModel.create(store);
        }, builder: (BuildContext context, TTSViewModel ttsViewModel) {
          appStateStore.dispatch(
              SetVoiceTextAction(generateText(widget.story, widget.options)));
          appStateStore.dispatch(SetSpeechParams(0.5, 1.0, 0.5));
          return Scaffold(
            appBar: AppBar(
              title: const Text('Game'),
              leading: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  appStateStore.dispatch(ttsViewModel.stop());
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: InkWell(
                      onTap: () {
                        print("ttsState : ${ttsViewModel.ttsState.toString()}");
                        if (ttsViewModel.ttsState == TtsState.stopped) {
                          ttsViewModel.speak();
                        } else if (ttsViewModel.ttsState == TtsState.playing ||
                            ttsViewModel.ttsState == TtsState.continued) {
                          ttsViewModel.pause();
                        } else if (ttsViewModel.ttsState == TtsState.paused) {
                          ttsViewModel.speak();
                        }
                      },
                      child: ttsViewModel.ttsState == TtsState.playing ||
                              ttsViewModel.ttsState == TtsState.continued
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
