import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/story.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/game_main/ttsState/view_model.dart';
import 'package:rpg_game/game/generate_Story.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  String generateText(String story, List<Map<String, dynamic>> options) {
    String text = story;
    text += " Now, please select an option from the following options! ";
    for (int i = 0; i < options.length; i++) {
      text += "Option ${idx2Str(options[i]["idx"])}: ${options[i]["option"]}. ";
    }
    return text;
  }

  void checkAnswer() {
    if (_lastWords.toLowerCase() == "option one" ||
        _lastWords.toLowerCase() == "option two" ||
        _lastWords.toLowerCase() == "option three" ||
        _lastWords.toLowerCase() == "option four") {
      String newVoiceText = "Your choice is : $_lastWords}";
      appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
      appStateStore.dispatch(SpeakTextAction(newVoiceText));
    } else {
      appStateStore.dispatch(
          SetVoiceTextAction("Invalid option! Please select a valid option!"));
      appStateStore.dispatch(
          SpeakTextAction("Invalid option! Please select a valid option!"));
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    print("start listening");
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    print("stop listening");
    print(_lastWords);
    checkAnswer();
    setState(() => _lastWords = "");
    await _speechToText.stop();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: appStateStore,
        child: StoreConnector<AppState, TTSViewModel>(
            converter: (Store<AppState> store) {
          return TTSViewModel.create(store);
        }, builder: (BuildContext context, TTSViewModel ttsViewModel) {
          appStateStore.dispatch(
              SetVoiceTextAction(generateText(widget.story, widget.options)));
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
                          if (ttsViewModel.ttsState == TtsState.stopped) {
                            ttsViewModel.speak();
                          } else if (ttsViewModel.ttsState ==
                                  TtsState.playing ||
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _speechToText.isListening
                        ? _lastWords
                        // If listening isn't active but could be tell the user
                        // how to start it, otherwise indicate that speech
                        // recognition is not yet ready or not supported on
                        // the target device
                        : _speechEnabled
                            ? 'Tap the microphone to start listening...'
                            : 'Speech not available',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodySmall!.color),
                  )
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  appStateStore.dispatch(ttsViewModel.stop());
                  _speechToText.isNotListening
                      ? _startListening()
                      : _stopListening();
                },
                tooltip: 'Listen',
                child: Icon(
                    _speechToText.isNotListening ? Icons.mic : Icons.mic_off),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterFloat);
        }));
  }
}
