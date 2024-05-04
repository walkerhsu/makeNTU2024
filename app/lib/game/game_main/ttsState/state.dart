import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rpg_game/game/game_main/ttsState/actions.dart';
import 'package:rpg_game/game/game_main/ttsState/store.dart';

enum TtsState { playing, stopped, paused, continued }
class AppState {
  final FlutterTts flutterTts = FlutterTts();
  String? language;
  String? engine;
  double volume;
  double pitch;
  double rate;
  bool isCurrentLanguageInstalled = false;

  List<String> storySentences;
  int sentenceIndex;
  String voiceText;

  TtsState ttsState;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  AppState({
    this.volume = 1.0,
    this.pitch = 1.1,
    this.rate = 0.5,
    this.storySentences = const [],
    this.sentenceIndex = 0,
    this.voiceText = "",
    this.ttsState = TtsState.playing,
  }) {
    Future.delayed(Duration.zero, () {
      AppStateStore.dispatch(SetAwaitOptionsAction(true));
    });
    flutterTts.setStartHandler(() {
      AppStateStore.dispatch(SetStartAction());
    });

    flutterTts.setCompletionHandler(() {
      print("complete handler");
      AppStateStore.dispatch(SetCompletedAction());
    });

    flutterTts.setCancelHandler(() {
      print("cancel handler");
      AppStateStore.dispatch(SetCancelAction());
    });

    flutterTts.setPauseHandler(() {
      AppStateStore.dispatch(SetPauseAction());
    });

    flutterTts.setContinueHandler(() {
      AppStateStore.dispatch(SetContinueAction());
    });

    flutterTts.setErrorHandler((msg) {
      AppStateStore.dispatch(SetErrorAction());
    });
  }

  AppState copyWith({
    double? volume,
    double? pitch,
    double? rate,
    List<String>? storySentences,
    int? sentenceIndex,
    String? voiceText,
    TtsState? ttsState,
  }) {
    return AppState(
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      rate: rate ?? this.rate,
      storySentences: storySentences ?? this.storySentences,
      sentenceIndex: sentenceIndex ?? this.sentenceIndex,
      voiceText: voiceText ?? this.voiceText,
      ttsState: ttsState ?? this.ttsState,
    );
  }
}
