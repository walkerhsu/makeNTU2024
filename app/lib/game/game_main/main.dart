import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
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
    required this.status,
  });
  final String story;
  final List<Map<String, dynamic>> options;
  final String status;

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
    text = text.replaceAll('\n', '');
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
        AppStateStore.dispatch(SetVoiceTextAction("選擇錯誤，請重新選擇！"));
        AppStateStore.dispatch(SpeakTextAction());
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
        AppStateStore.dispatch(SetVoiceTextAction(
            "Invalid option! Please select a valid option!"));
        AppStateStore.dispatch(SpeakTextAction());
        return;
      }
    }
    AppStateStore.dispatch(SetCancelAction());
    AppStateStore.dispatch(SetStorySentencesAction(['']));
    Navigator.popAndPushNamed(context, '/game/main');
  }

  void checkBattle() async {
    if (language == "zh") {
      if (_userLastWords == "戰鬥") {
        await setBattle();
      }
    }
  }

  void checkEnd() async {
    if (language == "zh") {
      if (_userLastWords == "結束") {
        await setEnd();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    AppStateStore.dispatch(SetStorySentencesAction(generateText(widget.story)));
    AppStateStore.dispatch(SetSentenceIndexAction(0));
    AppStateStore.dispatch(SpeakTextAction());
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
    AppStateStore.dispatch(StopSpeakAction());
    if (_userSpeechEnabled) {
      await _userSpeechToText.listen(
          localeId: locale, onResult: _onSpeechResult);
    }
  }

  void _stopListening() async {
    await _userSpeechToText.stop();
    if (widget.options[0]["idx"] == -1) {
      checkBattle();
    }
    checkAnswer();
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

  Future setEnd() async {
    await AppStateStore.dispatch(StopSpeakAction());
    await userStateStore.dispatch(SetOptionAction(""));
    await AppStateStore.dispatch(SetSentenceIndexAction(0));
    await AppStateStore.dispatch(SetStorySentencesAction(['']));
    await userStateStore.dispatch(SetDestinationAction(0.0, 0.0, "台北"));
    await userStateStore.dispatch(SetTimeAction(0.1, 0.1));
    await userStateStore.dispatch(SetHTTPAction("create"));
    if (!mounted || !context.mounted) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text: "The game has ended! Let's see the results ~~ ",
      barrierDismissible: true,
    ).then((_) => Navigator.popAndPushNamed(context, '/game/end'));
  }

  Future setBattle() async {
    AppStateStore.dispatch(StopSpeakAction());
    userStateStore.dispatch(SetOptionAction(""));
    setState(() {
      showCntNumber = true;
      _controller = AnimationController(
          duration: const Duration(seconds: 1), vsync: this);
      _controller.repeat();
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
              Navigator.popAndPushNamed(context, "/game/wait_result");
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: AppStateStore,
        child: StoreConnector<AppState, TTSViewModel>(
            converter: (Store<AppState> store) {
          return TTSViewModel.create(store);
        }, builder: (BuildContext context, TTSViewModel ttsViewModel) {
          return Scaffold(
              appBar: AppBar(
                title: const Text("Game"),
                leading: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () async {
                    AppStateStore.dispatch(ttsViewModel.stop());
                    bool confirm = false;
                    await QuickAlert.show(
                      context: context,
                      text: "Are you sure you want to leave this story?",
                      // confirmBtnText: 'Yes',
                      confirmBtnColor: Colors.green,
                      confirmBtnText: "Yes",
                      cancelBtnTextStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      type: QuickAlertType.warning,
                      onConfirmBtnTap: () {
                        confirm = true;
                        Navigator.pop(context);
                      },
                    );
                    if (!mounted || !context.mounted || !confirm) return;
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
                    story: '${sentences[AppStateStore.state.sentenceIndex]}。',
                    options: widget.options,
                  ),
                  const SizedBox(height: 30),
                  if (widget.status == "end")
                    Center(
                      child: InkWell(
                        onTap: () async {
                          await setEnd();
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.purple[100]!,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "結束",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.options[0]["idx"] == -1 && !showCntNumber)
                    Center(
                      child: InkWell(
                        onTap: () async {
                          await setBattle();
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.purple[100]!,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "戰鬥",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                              ),
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
                    ),
                    const SizedBox(height: 50),
                  Text(
                    _userSpeechToText.isListening
                        ? _userLastWords
                        : !_userSpeechEnabled
                            ? 'User Speech not available'
                            : widget.options[0]["idx"] != -1
                                ? 'Tap to choose your option...'
                                : widget.status == "end" 
                                ? 'Tap to see the results...'
                                : 'Tap to start the battle...',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall!.color),
                  ),
                  
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await AppStateStore.dispatch(
                      AppStateStore.dispatch(StopSpeakAction()));
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
