import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  final SpeechToText _userSpeechToText = SpeechToText();
  bool _userSpeechEnabled = false;
  String _userLastWords = '';
  final String language = "zh";
  final String locale = "zh-TW";
  List<String> sentences = [];

  List<String> generateText(String story, List<Map<String, dynamic>> options) {
    String text = story;
    // text += "現在，請從以下的選項進行選擇。";
    // for (int i = 0; i < options.length; i++) {
    //   text +=
    //       "選項${idx2Str(options[i]["idx"], language)}： ${options[i]["option"]}。";
    // }
    sentences = text.split("。");
    // split the last element from the list
    sentences.removeLast();
    print(sentences);
    return sentences;
  }

  void checkAnswer() async {
    print("user last words: $_userLastWords");
    if (language == "zh") {
      if (_userLastWords == "一" ||
          _userLastWords == widget.options[0]["option"]) {
        String newVoiceText = voice2str(widget.options[0], "zh");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else if (_userLastWords == "二" ||
          _userLastWords == widget.options[1]["option"]) {
        String newVoiceText = voice2str(widget.options[1], "zh");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else if (_userLastWords == "三" ||
          _userLastWords == "山" ||
          _userLastWords == widget.options[2]["option"]) {
        String newVoiceText = voice2str(widget.options[2], "zh");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else if (_userLastWords == "四" ||
          _userLastWords == "是" ||
          _userLastWords == widget.options[3]["option"]) {
        String newVoiceText = voice2str(widget.options[3], "zh");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else {
        appStateStore.dispatch(SetVoiceTextAction("選擇錯誤，請重新選擇！"));
        await appStateStore.dispatch(SpeakTextAction());
      }
    } else if (language == "en") {
      if (_userLastWords.toLowerCase() == "one" ||
          _userLastWords.toLowerCase() == widget.options[0]["option"]) {
        String newVoiceText = voice2str(widget.options[0], "en");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else if (_userLastWords.toLowerCase() == "two" ||
          _userLastWords.toLowerCase() == widget.options[1]["option"]) {
        String newVoiceText = voice2str(widget.options[1], "en");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else if (_userLastWords.toLowerCase() == "three" ||
          _userLastWords.toLowerCase() == widget.options[2]["option"]) {
        String newVoiceText = voice2str(widget.options[2], "en");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else if (_userLastWords.toLowerCase() == "four" ||
          _userLastWords.toLowerCase() == widget.options[3]["option"]) {
        String newVoiceText = voice2str(widget.options[3], "en");
        appStateStore.dispatch(SetVoiceTextAction(newVoiceText));
        await appStateStore.dispatch(SpeakTextAction());
      } else {
        appStateStore.dispatch(SetVoiceTextAction(
            "Invalid option! Please select a valid option!"));
        await appStateStore.dispatch(SpeakTextAction());
      }
    }
    appStateStore.dispatch(SetReadStoryAction(true));
    appStateStore.dispatch(SetCancelAction());
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    appStateStore.dispatch(
        SetStorySentencesAction(generateText(widget.story, widget.options)));
    appStateStore.dispatch(SetReadStoryAction(true));
    appStateStore.dispatch(SpeakTextAction());
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _userSpeechEnabled = await _userSpeechToText.initialize();
  }

  void _startListening() async {
    appStateStore.dispatch(SetReadStoryAction(false));
    print("user mode start listening");
    if (_userSpeechEnabled) {
      print("_userSpeechEnabled true");
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
                  appStateStore.dispatch(SetSentenceIndexAction(0));
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
