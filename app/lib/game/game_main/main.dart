import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:quickalert/quickalert.dart';
import 'package:redux/redux.dart';
import 'package:rpg_game/game/Components/progress_bar.dart';
import 'package:rpg_game/game/fetch_request.dart';
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

class _GameMainState extends State<GameMain> with TickerProviderStateMixin {
  late AnimationController _controller;
  final Tween<double> _tween = Tween(begin: 2, end: 0);

  final SpeechToText _userSpeechToText = SpeechToText();
  Timer? timer;
  bool _userSpeechEnabled = false;
  String _userLastWords = '';
  int _cntDown = 3;
  bool showCntNumber = false;

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
    Navigator.popAndPushNamed(context, '/game/main');
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    appStateStore.dispatch(SetStorySentencesAction(generateText(widget.story)));
    appStateStore.dispatch(SetSentenceIndexAction(0));
    appStateStore.dispatch(SpeakTextAction());
  }

  @override
  void dispose() {
    _userSpeechToText.stop();
    timer?.cancel();
    super.dispose();
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
                title: const Text("Game"),
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
                  const SizedBox(height: 30),
                  if (widget.options[0]["idx"] != -1)
                    Text(
                      _userSpeechToText.isListening
                          ? _userLastWords
                          : _userSpeechEnabled
                              ? 'Tap the microphone to choose your option...'
                              : 'User Speech not available',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodySmall!.color),
                    ),
                  if (widget.options[0]["idx"] == -1 && !showCntNumber)
                    Center(
                      child: InkWell(
                        onTap: () async {
                          appStateStore.dispatch(StopSpeakAction());
                          setState(() {
                            showCntNumber = true;
                            _controller = AnimationController(
                                duration: const Duration(seconds: 1),
                                vsync: this);
                            _controller.repeat();
                          });
                          timer =
                              Timer.periodic(const Duration(seconds: 1), (_) {
                            setState(() {
                              if (_cntDown > 0) {
                                _cntDown--;
                              } else {
                                timer!.cancel();
                                postHTTPResponse();
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.info,
                                  text: "Battle is in progress...",
                                  barrierDismissible: true,
                                  showConfirmBtn: false,
                                ).then((value) {
                                  if (mounted && context.mounted) {
                                    Navigator.popAndPushNamed(
                                        context, "/game/wait_result");
                                  }
                                });
                              }
                            });
                          });
                          if (!mounted || !context.mounted) {
                            return;
                          }

                          // Timer makePeriodicTimer(
                          //   Duration duration,
                          //   void Function(Timer timer) callback, {
                          //   bool fireNow = false,
                          // }) {
                          //   var timer = Timer.periodic(duration, callback);
                          //   if (fireNow) {
                          //     callback(timer);
                          //   }
                          //   return timer;
                          // }

                          // _timer = makePeriodicTimer(const Duration(seconds: 1),
                          //     (timer) {
                          //   getBattleResult().then((value) {
                          //     if (value == "playing") {
                          //       QuickAlert.show(
                          //         context: context,
                          //         type: QuickAlertType.info,
                          //         barrierDismissible: true,
                          //         showConfirmBtn: false,
                          //       );
                          //     } else {
                          //       Navigator.popAndPushNamed(
                          //           context, "/game/main");
                          //     }
                          //   });
                          // }, fireNow: true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple[100]!,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "BATTLE",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showCntNumber && _cntDown > 0)
                    ScaleTransition(
                      scale: _tween.animate(_controller),
                      child: Text(
                        '$_cntDown',
                        style: const TextStyle(fontSize: 60, color: Colors.red),
                      ),
                    )
                ],
              ),
              floatingActionButton: widget.options[0]["idx"] != -1
                  ? FloatingActionButton(
                      onPressed: () async {
                        await appStateStore.dispatch(
                            appStateStore.dispatch(StopSpeakAction()));
                        _userSpeechToText.isNotListening
                            ? _startListening()
                            : _stopListening();
                      },
                      tooltip: 'Listen',
                      child: Icon(_userSpeechToText.isNotListening
                          ? Icons.mic
                          : Icons.mic_off),
                    )
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterFloat);
        }));
  }
}
