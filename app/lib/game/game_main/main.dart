import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/game_main/story.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/state.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';
import 'package:rpg_game/game/game_main/ttsState/view_model.dart';
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';

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
  final SpeechToText _userSpeechToText = SpeechToText();
  bool _userSpeechEnabled = false;
  String _userLastWords = '';
  final String language = "zh";
  final String locale = "zh-TW";
  List<String> sentences = [];

  List<String> generateText(String story) {
    String text = story;
    sentences = text.split("。");
    sentences.removeLast();
    print(sentences);
    return sentences;
  }

  void checkAnswer() {
    if (language == "zh") {
      if (_userLastWords == "一" ||
          _userLastWords == widget.options[0]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[0]["option"]));
      } else if (_userLastWords == "二" ||
          _userLastWords == widget.options[1]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[1]["option"]));
      } else if (_userLastWords == "三" ||
          _userLastWords == "山" ||
          _userLastWords == widget.options[2]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[2]["option"]));
      } else if (_userLastWords == "四" ||
          _userLastWords == "是" ||
          _userLastWords == widget.options[3]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[3]["option"]));
      } else {
        appStateStore.dispatch(SetVoiceTextAction("選擇錯誤，請重新選擇！"));
        appStateStore.dispatch(SpeakTextAction());
        return;
      }
    } else if (language == "en") {
      if (_userLastWords.toLowerCase() == "one" ||
          _userLastWords.toLowerCase() == widget.options[0]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[0]["option"]));
      } else if (_userLastWords.toLowerCase() == "two" ||
          _userLastWords.toLowerCase() == widget.options[1]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[1]["option"]));
      } else if (_userLastWords.toLowerCase() == "three" ||
          _userLastWords.toLowerCase() == widget.options[2]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[2]["option"]));
      } else if (_userLastWords.toLowerCase() == "four" ||
          _userLastWords.toLowerCase() == widget.options[3]["option"]) {
        userStateStore.dispatch(SetOptionAction(widget.options[3]["option"]));
      } else {
        appStateStore.dispatch(SetVoiceTextAction(
            "Invalid option! Please select a valid option!"));
        appStateStore.dispatch(SpeakTextAction());
        return;
      }
    }
    appStateStore.dispatch(SetCancelAction());
    appStateStore.dispatch(SetStorySentencesAction(['']));
    Navigator.pop(context);
    Navigator.pushNamed(context, '/game/wait_result');
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    appStateStore.dispatch(SetStorySentencesAction(generateText(widget.story)));
    appStateStore.dispatch(SetSentenceIndexAction(0));
    appStateStore.dispatch(SpeakTextAction());
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _userSpeechEnabled = await _userSpeechToText.initialize();
  }

  void _startListening() async {
    appStateStore.dispatch(StopSpeakAction());
    if (_userSpeechEnabled) {
      await _userSpeechToText.listen(
          localeId: locale, onResult: _onSpeechResult);
    }
  }

  void _stopListening() async {
    checkAnswer();
    await _userSpeechToText.stop();
    setState(() {
      _userLastWords = "";
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _userLastWords = result.recognizedWords;
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
                    story: '${sentences[appStateStore.state.sentenceIndex]}。',
                    options: widget.options,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userSpeechToText.isListening
                        ? _userLastWords
                        : _userSpeechEnabled
                            ? 'Tap the microphone to start listening...'
                            : 'User Speech not available',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall!.color),
                  )
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await appStateStore.dispatch(ttsViewModel.stop());
                  _userSpeechToText.isNotListening
                      ? _startListening()
                      : _stopListening();
                },
                tooltip: 'Listen',
                child: Icon(_userSpeechToText.isNotListening
                    ? Icons.mic
                    : Icons.mic_off),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterFloat);
        }));
  }
}
